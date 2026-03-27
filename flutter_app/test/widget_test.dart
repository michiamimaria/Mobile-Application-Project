import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_app/main.dart';

void main() {
  testWidgets('Auth screen shows sign in and create account', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Create account'), findsWidgets);
    expect(find.text('Welcome back'), findsOneWidget);
  });
}
