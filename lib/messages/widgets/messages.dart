import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/messages/bloc/messages_bloc.dart';
import './message.dart' as widget;

class Messages extends StatefulWidget {
  late final ScrollController scroll;
  Messages({Key? key, required this.scroll}) : super(key: key);

  @override
  _MessagesState createState() => _MessagesState(scroll);
}

class _MessagesState extends State<Messages> {
  late ScrollController scroll;

  _MessagesState(this.scroll);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BlocBuilder<MessagesBloc, MessagesState>(
        bloc: BlocProvider.of<MessagesBloc>(context),
        builder: (context, state) {
          return Container(
            child: ListView.builder(
              controller: scroll,
              itemCount: state.messages.length,
              itemBuilder: (BuildContext context, int index) {
                return widget.Messsage(message: state.messages[index]);
              },
            ),
          );
        },
      ),
    );
  }
}
