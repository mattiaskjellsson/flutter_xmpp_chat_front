import 'package:flutter/material.dart';

class SplashPage extends StatelessWidget {
  static Route<void> route() =>
      MaterialPageRoute<void>(builder: (_) => SplashPage());

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
