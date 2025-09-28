// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:dynamic_ui_playground/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App builds with ProviderScope and shows MyHomePage', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Expect the app title in AppBar or general presence of MyHomePage scaffold
    expect(find.byType(MaterialApp), findsOneWidget);
    // The HomePage title is provided via MyHomePage(title: 'Dynamic UI')
    expect(find.text('Dynamic UI'), findsWidgets);
  });
}
