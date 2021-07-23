import 'dart:async';
import 'dart:io';

// ignore: import_of_legacy_library_into_null_safe
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

const TAG = 'example';

class ConnectionStateChangedListener
    implements xmpp.ConnectionStateChangedListener {
  late final xmpp.Connection _connection;
  late final xmpp.MessagesListener _messagesListener;
  late final StreamSubscription<String> _subscription;
  late final _presenceManager;
  late final _rosterManager;
  late final _messageHandler;
  late final _receiver;

  ConnectionStateChangedListener(
    xmpp.Connection connection,
    xmpp.MessagesListener messagesListener,
    String receiver,
  ) {
    xmpp.Log.logLevel = xmpp.LogLevel.VERBOSE;
    xmpp.Log.logXmpp = true;

    _connection = connection;
    _messagesListener = messagesListener;
    _connection.connectionStateStream.listen(onConnectionStateChanged);
    _receiver = receiver;
  }

  @override
  void onConnectionStateChanged(xmpp.XmppConnectionState state) {
    print(state);

    if (state == xmpp.XmppConnectionState.Ready) {
      print('Connected');

      final vCardManager = xmpp.VCardManager(_connection);
      vCardManager.getSelfVCard().then((vCard) {
        print('Your info ${vCard.buildXmlString()}');
      });

      _messageHandler = xmpp.MessageHandler.getInstance(_connection);
      _rosterManager = xmpp.RosterManager.getInstance(_connection);
      _messageHandler.messagesStream.listen(_messagesListener.onNewMessage);

      sleep(const Duration(seconds: 1));

      final receiverJid = xmpp.Jid.fromFullJid(_receiver);

      _rosterManager.addRosterItem(xmpp.Buddy(receiverJid)).then((result) {
        if (result.description != null) {
          print('add roster ${result.description}');
        }
      });

      _presenceManager = xmpp.PresenceManager.getInstance(_connection);
      _presenceManager.presenceStream.listen(onPresence);
    }
  }

  void onPresence(xmpp.PresenceData event) {
    print(
        'presence Event from ${event.jid.fullJid} PRESENCE: ${event.showElement.toString()}');
  }

  void dispose() {
    _subscription.cancel();
    _connection.close();

    _presenceManager.close();
    _rosterManager.dispose();
    _messageHandler.close();
  }
}
