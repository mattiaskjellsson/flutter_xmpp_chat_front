import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/authentication/bloc/authentication_bloc.dart';
import 'package:frontend/authentication/bloc/authentication_event.dart';
import 'package:xmpp_communication/xmpp_communication.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => HomePage());
  }

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double height;
  late double width;
  late TextEditingController edit;
  late ScrollController scroll;
  late XmppManager _xmpp;
  late bool _connected;

  @override
  initState() {
    _connected = false;
    scroll = new ScrollController();
    edit = new TextEditingController();
    _xmpp = XmppManager();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    if (!_connected) {
      final u = context.select((AuthenticationBloc bloc) => bloc.state.user);
      final receiver = u.username == 'mattias' ? 'mattias2' : 'mattias';
      _xmpp.connect(u.username, u.password, '127.0.0.1', receiver);
      _connected = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Home'), actions: <Widget>[
        ElevatedButton(
          child: const Text('Logout'),
          onPressed: () {
            context
                .read<AuthenticationBloc>()
                .add(AuthenticationLogoutRequested());
          },
        ),
      ]),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Builder(
              builder: (context) {
                final user = context.select(
                  (AuthenticationBloc bloc) => bloc.state.user,
                );
                print(user);
                final userId = context.select(
                  (AuthenticationBloc bloc) => bloc.state.user.id,
                );

                return Text('UserID: $userId');
              },
            ),
            Expanded(
              child: Container(),
            ),
            Row(
              children: [
                Container(
                    width: width * 0.7,
                    padding: const EdgeInsets.all(2.0),
                    margin: const EdgeInsets.only(left: 40.0),
                    child: TextField(
                        decoration: InputDecoration.collapsed(
                          hintText: 'Send a message...',
                        ),
                        controller: edit)),
                FloatingActionButton(
                  backgroundColor: Colors.deepPurple,
                  onPressed: _sendMessage,
                  child: Icon(
                    Icons.send,
                    size: 32,
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  _sendMessage() {
    if (edit.text.isNotEmpty) {
      _xmpp.sendMessage(edit.text);
    }
    //   if (edit.text.isNotEmpty) {
    //     final m = {
    //       "id": socket.id,
    //       "timestamp": DateTime.now().millisecondsSinceEpoch,
    //       'message': edit.text
    //     };

    //     socket.emit('send_message', json.encode(m));
    //     this.setState(() => messages.add(m));
    //     edit.text = '';
    //     scroll.animateTo(
    //       scroll.position.maxScrollExtent,
    //       duration: Duration(milliseconds: 600),
    //       curve: Curves.ease,
    //     );
    //   }
  }
}
