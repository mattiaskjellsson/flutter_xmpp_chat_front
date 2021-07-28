import 'package:flutter/material.dart';
import 'package:xmpp_communication/xmpp_communication.dart' as xmpp;

class Messsage extends StatelessWidget {
  final xmpp.Message message;
  const Messsage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(message.body),
        Text(message.from),
        SizedBox(height: 10.0),
      ],
    );
  }
}
