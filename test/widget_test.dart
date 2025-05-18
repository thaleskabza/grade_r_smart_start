import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:grade_r_smart_start/main.dart';
import 'package:grade_r_smart_start/screens/welcome_screen.dart';

void main() {
  testWidgets('Welcome screen loads and has button', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const SmartStartApp());

    // Expect welcome text
    expect(find.text('Welcome to\nSmart Start!'), findsOneWidget);

    // Expect Let's Begin button
    expect(find.text("Let's Begin"), findsOneWidget);

    // Tap the button
    await tester.tap(find.text("Let's Begin"));
    await tester.pumpAndSettle();

    // You can expand this once the navigation logic is mocked
  });
}
