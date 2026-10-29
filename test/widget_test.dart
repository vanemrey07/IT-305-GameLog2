import 'package:flutter_test/flutter_test.dart';

import 'package:gamelog/main.dart';

void main() {
  testWidgets('login screen renders main fields', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('create account button opens registration page', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.text('Create your account'), findsOneWidget);
  });

  testWidgets('login button opens dashboard', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsOneWidget);
  });
}
