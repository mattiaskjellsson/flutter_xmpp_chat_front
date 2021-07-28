import 'package:flutter/material.dart';
import 'package:xmpp_communication/xmpp_communication.dart' as xmpp;

class Messsage extends StatelessWidget {
  final xmpp.Message message;
  final bool fromMe;
  const Messsage({Key? key, required this.message, required this.fromMe})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width * 0.6;
    final a = fromMe ? Alignment.centerRight : Alignment.centerLeft;
    final c = fromMe ? Colors.blue : Colors.blueAccent;
    return Container(
        alignment: a,
        child: Padding(
            padding: EdgeInsets.all(8),
            child: Container(
                width: w,
                color: c,
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Text(message.body),
                      Text(message.from),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ))));
  }
}
