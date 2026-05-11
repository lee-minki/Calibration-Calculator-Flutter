// Smoke test: ensure the app builds and the home screen renders without
// throwing. AdMob and SharedPreferences are intentionally NOT initialised here
// to keep the test hermetic.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:calibration_calculator/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    // First frame settles; just verify a Scaffold rendered.
    expect(find.byType(Scaffold), findsWidgets);
  });
}
