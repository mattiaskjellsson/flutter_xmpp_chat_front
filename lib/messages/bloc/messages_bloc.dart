import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';
import 'package:xmpp_communication/xmpp_communication.dart';

part 'messages_event.dart';
part 'messages_state.dart';

class MessagesBloc extends Bloc<MessagesEvent, MessagesState> {
  late StreamSubscription<AuthenticationStatus> _authStreamSubscription;
  late StreamSubscription<Message> _messageStreamSubscription;

  final UserRepository _userRepo;
  final XmppManager _xmppManager;
  final AuthenticationRepository _authRepo;

  UserRepository get userRepository => _userRepo;

  MessagesBloc({
    required AuthenticationRepository authenticationRepository,
    required UserRepository userRepository,
    required XmppManager xmppManager,
  })  : _userRepo = userRepository,
        _xmppManager = xmppManager,
        _authRepo = authenticationRepository,
        super(MessagesStateInitial()) {
    _authStreamSubscription = _authRepo.status
        .listen((AuthenticationStatus status) => authEvents(status));
  }

  authEvents(AuthenticationStatus e) async {
    if (e == AuthenticationStatus.authenticated) {
      // final String serverIp = '18.118.6.189';
      final String serverIp = '127.0.0.1';

      final User user = await _userRepo.getUser();

      // final String receiver = user.username == 'ardian@localhost'
      //     ? 'sean@localhost'
      //     : 'ardian@localhost';

      final String receiver = user.username == 'mattias'
          ? 'mattias2@shakespeare.lit'
          : 'mattias@shakespeare.lit';

      _xmppManager.connect(user.username, user.password, serverIp, receiver);

      _messageStreamSubscription =
          _xmppManager.listener.messageStream.listen((e) => messageHandler(e));
    }
  }

  messageHandler(Message m) {
    add(NewMessagesEvent(m));
  }

  Future<void> send(String message) async {
    await _xmppManager.sendMessage(message);
  }

  @override
  Stream<MessagesState> mapEventToState(
    MessagesEvent event,
  ) async* {
    yield state.copyWith(
        messages: List.of(state.messages)
          ..add(Message(event.message.from, event.message.body)));
  }

  @override
  Future<void> close() {
    _authRepo.dispose();
    _xmppManager.dispose();

    _authStreamSubscription.cancel();
    _messageStreamSubscription.cancel();
    return super.close();
  }
}
