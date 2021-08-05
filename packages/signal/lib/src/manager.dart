import 'dart:convert';
import 'dart:typed_data';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart'
    as libSignal;

class SignalManager {
  // late final _sessionChyper;
  // libSignal.SessionCipher get sessionCipher => _sessionChyper;

  late final generatePreKeyStart;
  late final generatePreKeyCount;
  late final signedKeyId;

  late final String receiverName; // = 'bob';
  late final int receiverDeviceId; // = 1;

  late final libSignal.SessionCipher _sessionCipher;

  // late final int registrationId;

  late final String senderName; // = 'alice';
  late final int senderDeviceId; // = 1;

  late final remotePreKeyStart; // = 0;
  late final remotePreKeyCount; // = 110;
  late final remoteSignedPreKeyId; // = 0;

  late final List<libSignal.PreKeyRecord> _preKeys;
  late final int _registrationId;
  late final libSignal.IdentityKeyPair _identityKeyPair;

  late final int _remoteRegId;
  late final List<libSignal.PreKeyRecord> _remotePreKeys;
  late final libSignal.SignedPreKeyRecord _remoteSignedPreKey;
  late final libSignal.IdentityKeyPair _remoteIdentityKeyPair;

  SignalManager({
    this.generatePreKeyStart = 0,
    this.generatePreKeyCount = 110,
    this.signedKeyId = 0,
    // this.receiverName = 'bob',
    this.receiverDeviceId = 1,
    // this.registrationId = 1,
    // this.senderName = 'alice',
    this.senderDeviceId = 1,
    this.remotePreKeyStart = 0,
    this.remotePreKeyCount = 110,
    this.remoteSignedPreKeyId = 0,
  }) {
    this._preKeys =
        libSignal.generatePreKeys(generatePreKeyStart, generatePreKeyCount);
    this._registrationId = libSignal.generateRegistrationId(false);
    this._identityKeyPair = libSignal.generateIdentityKeyPair();
  }

  Future<void> install({required sender, required receiver}) async {
    senderName = sender;
    receiverName = receiver;

    final signedPreKey =
        libSignal.generateSignedPreKey(_identityKeyPair, signedKeyId);

    final sessionStore = libSignal.InMemorySessionStore();
    final preKeyStore = libSignal.InMemoryPreKeyStore();
    final signedPreKeyStore = libSignal.InMemorySignedPreKeyStore();
    final identityStore =
        libSignal.InMemoryIdentityKeyStore(_identityKeyPair, _registrationId);

    for (var p in _preKeys) {
      await preKeyStore.storePreKey(p.id, p);
    }

    await signedPreKeyStore.storeSignedPreKey(signedPreKey.id, signedPreKey);

    final receiverAddress =
        libSignal.SignalProtocolAddress(receiverName, receiverDeviceId);
    final sessionBuilder = libSignal.SessionBuilder(sessionStore, preKeyStore,
        signedPreKeyStore, identityStore, receiverAddress);

    // Should get remote from the server
    libSignal.PreKeyBundle retrievedPreKey = await getRemotePreKey();

    await sessionBuilder.processPreKeyBundle(retrievedPreKey);

    _sessionCipher = libSignal.SessionCipher(sessionStore, preKeyStore,
        signedPreKeyStore, identityStore, receiverAddress);
  }

  Future<libSignal.PreKeyBundle> getRemotePreKey() async {
    _remoteRegId = libSignal.generateRegistrationId(false);
    _remotePreKeys =
        libSignal.generatePreKeys(remotePreKeyStart, remotePreKeyCount);
    _remoteIdentityKeyPair = libSignal.generateIdentityKeyPair();
    _remoteSignedPreKey = libSignal.generateSignedPreKey(
        _remoteIdentityKeyPair, remoteSignedPreKeyId);

    final libSignal.PreKeyBundle retrievedPreKey = libSignal.PreKeyBundle(
        _remoteRegId,
        receiverDeviceId,
        _remotePreKeys[0].id,
        _remotePreKeys[0].getKeyPair().publicKey,
        _remoteSignedPreKey.id,
        _remoteSignedPreKey.getKeyPair().publicKey,
        _remoteSignedPreKey.signature,
        _remoteIdentityKeyPair.getPublicKey());

    return retrievedPreKey;
  }

  Future<String> decryptMessage(
    Uint8List text,
  ) async {
    final ciphertext = libSignal.SignalMessage.fromSerialized(text);
    final signalProtocolStore = libSignal.InMemorySignalProtocolStore(
        _remoteIdentityKeyPair, _registrationId);

    final senderAddress =
        libSignal.SignalProtocolAddress(senderName, senderDeviceId);

    final remoteSessionCipher =
        libSignal.SessionCipher.fromStore(signalProtocolStore, senderAddress);

    for (var p in _remotePreKeys) {
      await signalProtocolStore.storePreKey(p.id, p);
    }

    await signalProtocolStore.storeSignedPreKey(
        _remoteSignedPreKey.id, _remoteSignedPreKey);

    if (ciphertext.getType() == libSignal.CiphertextMessage.prekeyType) {
      final plainText = await remoteSessionCipher
          .decrypt(ciphertext as libSignal.PreKeySignalMessage);
      return plainText.toString();
    }

    throw Exception('CiphertextMessage is of wrong type...');
  }

  Future<libSignal.CiphertextMessage> encryptMessage(String clearText) async {
    final ciphertext = await _sessionCipher
        .encrypt(Uint8List.fromList(utf8.encode(clearText)));

    print(ciphertext);
    print(ciphertext.serialize());

    return ciphertext;
  }
}
