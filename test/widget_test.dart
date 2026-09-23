import 'package:flutter_test/flutter_test.dart';
import 'package:jsm_fe/app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const App());
    expect(find.text('Journal Dashboard'), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
