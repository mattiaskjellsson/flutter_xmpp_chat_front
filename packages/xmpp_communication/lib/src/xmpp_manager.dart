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
    final userAtDomain = '$user@$domain';
    _senderJid = xmpp.Jid.fromFullJid(userAtDomain);

    final account = xmpp.XmppAccountSettings(
        userAtDomain, _senderJid.local, _senderJid.domain, password, 5222,
        resource: 'xmppstone');

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
      final cypherText = await _signalManager.encryptMessage(text);
      print(cypherText.toString());

      _messageHandler.sendMessage(
          _receiverJid, cypherText.serialize().toString());

      final m = xmpp.MessageStanza('', xmpp.MessageStanzaType.CHAT);
      m.body = cypherText.serialize().toString();
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
