import 'package:signal/signal.dart';
import 'package:xmpp_communication/xmpp_communication.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

class XmppManager {
  late xmpp.Jid _senderJid;
  late xmpp.Jid _receiverJid;
  late xmpp.MessageHandler _messageHandler;
  late ConnectionStateChangedListener _connectionStateChangedListener;
  late xmpp.PresenceManager _presenceManager;
  late SignalManager _signalManager;

  XmppManager({required signalManager}) : _signalManager = signalManager;

  MessagesListener get listener => _connectionStateChangedListener.listener;

  connect(String user, String password, String domain, String receiver) {
    // final userAtDomain = '$user@$domain';
    _senderJid = xmpp.Jid.fromFullJid(user);

    final account = xmpp.XmppAccountSettings(
        user, _senderJid.local, _senderJid.domain, password, 5222,
        resource: 'ec2-18-118-6-189.us-east-2.compute.amazonaws.com');
    account.host = domain;
    account.domain = 'localhost';

    final connection = xmpp.Connection(account);
    connection.connect();

    final messagesListener = MessagesListener(signalManager: _signalManager);

    _connectionStateChangedListener =
        ConnectionStateChangedListener(connection, messagesListener, receiver);

    _presenceManager = xmpp.PresenceManager.getInstance(connection);

    _presenceManager.subscriptionStream.listen((streamEvent) {
      if (streamEvent.type == xmpp.SubscriptionEventType.REQUEST) {
        _presenceManager.acceptSubscription(streamEvent.jid);
      }
    });

    _receiverJid = xmpp.Jid.fromFullJid(receiver);
    _messageHandler = xmpp.MessageHandler.getInstance(connection);

    _signalManager.install(
        sender: _senderJid.userAtDomain, receiver: _receiverJid.userAtDomain);
  }

  Future<void> sendMessage(String text) async {
    if (text.isNotEmpty) {
      print('Text: $text');

      _messageHandler.sendMessage(_receiverJid, text);

      final m = xmpp.MessageStanza('', xmpp.MessageStanzaType.CHAT);
      m.body = text;
      m.fromJid = _senderJid;
      m.toJid = _receiverJid;

      listener.onNewMessage(m);
    }
  }

  void dispose() {
    _connectionStateChangedListener.dispose();
  }
}
