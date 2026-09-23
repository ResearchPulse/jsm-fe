import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/app/app.dart';

void main() {
  testWidgets('App smoke test: starts, settles unauthenticated on login',
      (tester) async {
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
    // No stored session at startup: the auth gate lands on login, never
    // on the authenticated home.
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Journal Dashboard'), findsNothing);
  });
}
