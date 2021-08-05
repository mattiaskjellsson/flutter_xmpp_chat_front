import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';
import 'package:signal/signal.dart';
import 'package:user_repository/user_repository.dart';
import 'package:xmpp_communication/xmpp_communication.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    UserRepository _userRepository;
    SignalManager _signalManager;
    AuthenticationRepository _authenticationRepository;
    XmppManager _xmppManager;
    _userRepository = UserRepository();
    _signalManager = SignalManager();
    _xmppManager = XmppManager(signalManager: _signalManager);
    _authenticationRepository =
        AuthenticationRepository(userRepository: _userRepository);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      authenticationRepository: _authenticationRepository,
      userRepository: _userRepository,
      xmppManager: _xmppManager,
    ));

    // Verify that our counter starts at 0.
    expect(find.text('username'), findsOneWidget);
    expect(find.text('password'), findsOneWidget);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byTooltip('Submit'));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('UserId'), findsOneWidget);
    // expect(find.text('1'), findsOneWidget);
  });
}
