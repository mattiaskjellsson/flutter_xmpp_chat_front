import 'package:xmpp_communication/xmpp_communication.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

class XmppManager {
  late final _receiverJid;
  late final _messageHandler;
  late final _connectionStateChangedListener;
  late final _presenceManager;

  MessagesListener get listener => _connectionStateChangedListener.listener;

  connect(String user, String password, String domain, String receiver) {
    final userAtDomain = '$user@$domain';

    final jid = xmpp.Jid.fromFullJid(userAtDomain);
    final account = xmpp.XmppAccountSettings(
        userAtDomain, jid.local, jid.domain, password, 5222,
        resource: 'xmppstone');

    final connection = xmpp.Connection(account);
    connection.connect();

    final messagesListener = MessagesListener();

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
  }

  sendMessage(String text) {
    if (text.isNotEmpty) {
      _messageHandler.sendMessage(_receiverJid, text);
    }
  }

  void dispose() {
    _connectionStateChangedListener.dispose();
  }
}
