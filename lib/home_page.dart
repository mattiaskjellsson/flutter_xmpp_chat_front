import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/authentication/bloc/authentication_bloc.dart';
import 'package:frontend/authentication/bloc/authentication_event.dart';
import 'package:frontend/messages/bloc/messages_bloc.dart';

import 'messages/widgets/messages.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  static Route<dynamic> route() =>
      MaterialPageRoute<void>(builder: (_) => HomePage());

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double height;
  late double width;
  late TextEditingController edit;
  late ScrollController scroll;

  @override
  initState() {
    scroll = ScrollController();

    edit = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    final user = context.select(
      (AuthenticationBloc bloc) => bloc.state.user,
    );
    final userId = context.select(
      (AuthenticationBloc bloc) => bloc.state.user.id,
    );
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
                return Text('UserID: $userId');
              },
            ),
            Messages(scroll: scroll, me: user.username),
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
                  backgroundColor: Colors.blue,
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

  _sendMessage() async {
    if (edit.text.isNotEmpty) {
      final messageBloc = BlocProvider.of<MessagesBloc>(context);
      await messageBloc.send(edit.text);
      edit.text = '';
      // scroll.animateTo(double.infinity,
      //     duration: Duration(milliseconds: 300), curve: Curves.bounceIn);
      // scroll.position.maxScrollExtent;
    }
  }
}
