import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:xmpp_stone/xmpp_stone.dart' as xmpp;

import 'connectionStateChangedListener.dart';
import 'MessageListner.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final _receiverJid;
  late final _messageHandler;
  late final _edit = TextEditingController();
  late final _connectionStateChangedListener;
  late final _presenceManager;

  final _receiver = 'mattias2';
  final _user = 'mattias';
  final _domain = '127.0.0.1';
  final _password = 'abc123';

  @override
  void initState() {
    super.initState();
    _connect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Container(
                  //TODO: Add messages here.
                  ),
            ),
            SizedBox(height: 20.0),
            Row(
              children: [
                Expanded(
                  child: Container(
                      padding: const EdgeInsets.all(2.0),
                      margin: const EdgeInsets.only(left: 40.0),
                      child: TextField(
                          decoration: InputDecoration.collapsed(
                            hintText: 'Send a message...',
                          ),
                          controller: _edit)),
                ),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  tooltip: 'Send',
                  child: Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _connect() {
    final userAtDomain = '$_user@$_domain';

    final jid = xmpp.Jid.fromFullJid(userAtDomain);
    final account = xmpp.XmppAccountSettings(
        userAtDomain, jid.local, jid.domain, _password, 5222,
        resource: 'xmppstone');

    final connection = xmpp.Connection(account);
    connection.connect();

    xmpp.MessagesListener messagesListener = MessagesListener();
    _connectionStateChangedListener = ConnectionStateChangedListener(
        connection, messagesListener, '$_receiver@$_domain');

    _presenceManager = xmpp.PresenceManager.getInstance(connection);

    _presenceManager.subscriptionStream.listen((streamEvent) {
      if (streamEvent.type == xmpp.SubscriptionEventType.REQUEST) {
        _presenceManager.acceptSubscription(streamEvent.jid);
      }
    });

    _receiverJid = xmpp.Jid.fromFullJid('$_receiver@$_domain');
    _messageHandler = xmpp.MessageHandler.getInstance(connection);
  }

  _sendMessage() {
    if (_edit.text.isNotEmpty) {
      final message = _edit.text;
      _messageHandler.sendMessage(_receiverJid, message);
      _edit.text = '';
    }
  }

  @override
  void dispose() {
    super.dispose();
    _connectionStateChangedListener.dispose();
  }
}
