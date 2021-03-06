import 'dart:typed_data';

import 'package:xmpp_communication/xmpp_communication.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;
import 'package:signal/signal.dart';
import 'dart:async';

class MessagesListener implements xmpp.MessagesListener {
  final _streamController = StreamController<Message>();
  SignalManager _signalManager;
  MessagesListener({signalManager}) : _signalManager = signalManager;

  Stream<Message> get messageStream async* {
    yield* _streamController.stream;
  }

  @override
  void onNewMessage(xmpp.MessageStanza message) async {
    if (message.body != null) {
      print(
          'New Message from ${message.fromJid.userAtDomain} message: ${message.body}');

      RegExp regExp = new RegExp("[0-9]{1,3}");

      final list = <int>[];
      regExp.allMatches(message.body).forEach((element) {
        list.add(int.parse(message.body.substring(element.start, element.end)));
      });

      final decrypted =
          await _signalManager.decryptMessage(Uint8List.fromList(list));

      print(
          'Decrypted message: ${message.fromJid.userAtDomain} message: $decrypted');

      _streamController.add(Message(message.fromJid.userAtDomain, decrypted));
    }
  }

  dispose() {
    _streamController.close();
  }
}
