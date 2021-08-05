import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:signal/signal.dart';
import 'package:user_repository/user_repository.dart';
import 'package:xmpp_communication/xmpp_communication.dart';

import 'package:frontend/messages/bloc/messages_bloc.dart';

import 'AppView.dart';
import 'authentication/bloc/authentication_bloc.dart';

void main() {
  final userRepository = UserRepository();
  final signalManager = SignalManager();
  final xmppManager = XmppManager(
    signalManager: signalManager,
  );
  runApp(MyApp(
    authenticationRepository:
        AuthenticationRepository(userRepository: userRepository),
    userRepository: userRepository,
    xmppManager: xmppManager,
  ));
}

class MyApp extends StatelessWidget {
  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;
  final XmppManager xmppManager;

  MyApp({
    Key? key,
    required this.authenticationRepository,
    required this.userRepository,
    required this.xmppManager,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: authenticationRepository,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
              create: (_) => AuthenticationBloc(
                    authenticationRepository: authenticationRepository,
                    userRepository: userRepository,
                  )),
          BlocProvider(
            lazy: false,
            create: (context) => MessagesBloc(
              authenticationRepository: authenticationRepository,
              userRepository: userRepository,
              xmppManager: xmppManager,
            ),
          )
        ],
        child: AppView(),
      ),
    );
  }
}
