import 'package:xmpp_communication/xmpp_communication.dart';

// ignore: import_of_legacy_library_into_null_safe
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

class XmppManager {
  late xmpp.Jid _senderJid;
  late xmpp.Jid _receiverJid;
  late xmpp.MessageHandler _messageHandler;
  late ConnectionStateChangedListener _connectionStateChangedListener;
  late xmpp.PresenceManager _presenceManager;

  MessagesListener get listener => _connectionStateChangedListener.listener;

  connect(String user, String password, String domain, String receiver) {
    final userAtDomain = '$user@$domain';
    _senderJid = xmpp.Jid.fromFullJid(userAtDomain);

    final account = xmpp.XmppAccountSettings(
        userAtDomain, _senderJid.local, _senderJid.domain, password, 5222,
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

      final m = xmpp.MessageStanza('', xmpp.MessageStanzaType.CHAT);
      m.body = text;
      m.fromJid = _senderJid;
      m.toJid = _receiverJid;

      listener.onNewMessage(m);
    }
  }
//
  // @override
  // void onConnectionStateChanged(xmpp.XmppConnectionState state) {
  //   print(state);

  //   if (state == xmpp.XmppConnectionState.Ready) {
  //     final vCardManager = xmpp.VCardManager(_connection);
  //     vCardManager.getSelfVCard().then((vCard) {
  //       print('Your info ${vCard.buildXmlString()}');
  //     });

  //     _messageHandler = xmpp.MessageHandler.getInstance(_connection);
  //     _rosterManager = xmpp.RosterManager.getInstance(_connection);
  //     _messageHandler.messagesStream.listen(_messagesListener.onNewMessage);

  //     sleep(const Duration(seconds: 1));

  //     final receiverJid = xmpp.Jid.fromFullJid(_receiver);

  //     _rosterManager.addRosterItem(xmpp.Buddy(receiverJid)).then((result) {
  //       if (result.description != null) {
  //         print('add roster ${result.description}');
  //       }
  //     });

  //     _presenceManager = xmpp.PresenceManager.getInstance(_connection);
  //     _presenceManager.presenceStream.listen(onPresence);
  //   }
  // }

  // void onPresence(xmpp.PresenceData event) {
  //   print(
  //       'presence Event from ${event.jid.fullJid} PRESENCE: ${event.showElement.toString()}');
  // }

//
  void dispose() {
    _connectionStateChangedListener.dispose();
  }
}
