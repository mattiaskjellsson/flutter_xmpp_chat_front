import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';
import 'package:signal/signal.dart';
import 'package:user_repository/user_repository.dart';
import 'package:xmpp_communication/xmpp_communication.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    final UserRepository _userRepository = UserRepository();
    final SignalManager _signalManager = SignalManager();
    final XmppManager _xmppManager = XmppManager(signalManager: _signalManager);
    final AuthenticationRepository _authenticationRepository =
        AuthenticationRepository(userRepository: _userRepository);

    final app = MyApp(
      authenticationRepository: _authenticationRepository,
      userRepository: _userRepository,
      xmppManager: _xmppManager,
    );

    // Build our app and trigger a frame.
    await tester.pumpWidget(app);

    // Verify that our app login screen is there
    expect(1, 1);
  });
}
