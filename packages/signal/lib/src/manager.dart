import 'dart:convert';
import 'dart:typed_data';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart'
    as libSignal;

import 'key_server.dart';

class SignalManager {
  int _generatePreKeyStart;
  int _generatePreKeyCount;

  late final libSignal.IdentityKeyPair _identityKeyPair;
  late int _registrationId;
  late final List<libSignal.PreKeyRecord> _preKeys;
  late final libSignal.SignedPreKeyRecord _signedPreKey;

  late final libSignal.SessionBuilder _sessionBuilder;
  late final libSignal.InMemoryPreKeyStore _preKeyStore;
  late final libSignal.InMemorySignedPreKeyStore _signedPreKeyStore;
  late final libSignal.InMemoryIdentityKeyStore _identityStore;

  final KeyServer _keyServer = KeyServer();

  late final libSignal.InMemorySessionStore _sessionStore;
  late libSignal.SessionCipher _sessionCipher;

  SignalManager({
    generatePreKeyStart = 0,
    generatePreKeyCount = 110,
  })  : _generatePreKeyStart = generatePreKeyStart,
        _generatePreKeyCount = generatePreKeyCount;

  Future<void> install({required String username}) async {
    _identityKeyPair = libSignal.generateIdentityKeyPair();
    _registrationId = libSignal.generateRegistrationId(false);
    _preKeys =
        libSignal.generatePreKeys(_generatePreKeyStart, _generatePreKeyCount);
    _signedPreKey = libSignal.generateSignedPreKey(_identityKeyPair, 0);

    // Store _identityKeyPair somewhere durable and safe.
    // Store _registrationId somewhere durable and safe.
    await _keyServer.storeKey(KeyObject(
      username: username,
      identityKeyPair: _identityKeyPair.serialize().toString(),
      deviceId: 1.toString(),
      preKeyId: 0.toString(),
      signedPreKeyId: 0.toString(),
      preKey: _preKeys.first.serialize().toString(),
      registrationId: _registrationId.toString(),
    ));

    _sessionStore = libSignal.InMemorySessionStore();
    _preKeyStore = libSignal.InMemoryPreKeyStore();
    _signedPreKeyStore = libSignal.InMemorySignedPreKeyStore();

    // Store preKeys in PreKeyStore.
    _identityStore =
        libSignal.InMemoryIdentityKeyStore(_identityKeyPair, _registrationId);

    for (final p in _preKeys) {
      await _preKeyStore.storePreKey(p.id, p);
    }

    // Store signed prekey in SignedPreKeyStore.
    await _signedPreKeyStore.storeSignedPreKey(_signedPreKey.id, _signedPreKey);
  }

  Future<void> buildSession(
      {required String sender, required String receiver}) async {
    final recipientId = libSignal.SignalProtocolAddress(receiver, 1);

    _sessionBuilder = libSignal.SessionBuilder(_sessionStore, _preKeyStore,
        _signedPreKeyStore, _identityStore, recipientId);

    // Get key from server
    final remoteKey = await _keyServer.fetchKey(receiver);

    libSignal.IdentityKeyPair bobIdentityKeyPair =
        libSignal.IdentityKeyPair.fromSerialized(
            stringToList(remoteKey.identityKeyPair));

    int bobRegistrationId = int.parse(remoteKey.registrationId); //1
    int bobDeviceId = int.parse(remoteKey.deviceId);
    int bobPreKeyId = int.parse(remoteKey.preKeyId); //1;
    int bobSignedPreKeyId = int.parse(remoteKey.signedPreKeyId); //1;

    libSignal.PreKeyRecord bobPreKey =
        libSignal.PreKeyRecord.fromBuffer(stringToList(remoteKey.preKey));

    libSignal.SignedPreKeyRecord bobSignedPreKey =
        libSignal.generateSignedPreKey(_identityKeyPair, 0);

    final libSignal.InMemoryIdentityKeyStore bobStore =
        libSignal.InMemoryIdentityKeyStore(
            bobIdentityKeyPair, bobRegistrationId);

    libSignal.PreKeyBundle retreivedPreKey = libSignal.PreKeyBundle(
        await bobStore.getLocalRegistrationId(),
        bobDeviceId,
        bobPreKeyId,
        bobPreKey.getKeyPair().publicKey,
        bobSignedPreKeyId,
        bobSignedPreKey.getKeyPair().publicKey,
        bobSignedPreKey.signature,
        await bobStore
            .getIdentityKeyPair()
            .then((value) => value.getPublicKey()));

    // Build a session with a PreKey retrieved from the server.
    _sessionBuilder.processPreKeyBundle(retreivedPreKey);

    _sessionCipher = libSignal.SessionCipher(_sessionStore, _preKeyStore,
        _signedPreKeyStore, _identityStore, recipientId);
  }

  Future<String> encryptMessage(String text) async {
    final m = await _sessionCipher.encrypt(stringToList(text));
    return m.serialize().toString();
  }

  Future<String> decryptMessage(String text) async {
    Uint8List l = stringToList(text);
    libSignal.SignalMessage k = libSignal.SignalMessage.fromSerialized(l);
    final f = await _sessionCipher.decryptFromSignal(k);
    final g = utf8.decode(f, allowMalformed: true);
    return g;
  }

  Uint8List stringToList(String str) {
    return Uint8List.fromList(utf8.encode(str));
  }
}
