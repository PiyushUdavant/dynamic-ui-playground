import 'package:dynamic_ui_playground/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create flow via FAB and bottom sheet applies login mock', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    // Tap FAB to open input sheet
    final fab = find.byTooltip('New input');
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    // Switch to Create mode if not already selected
    final createChip = find.text('Create');
    expect(createChip, findsWidgets);
    await tester.tap(createChip.first);
    await tester.pumpAndSettle();

    // Tap the first create suggestion: 'Create a login screen with email and password'
    final suggestion = find.text('Create a login screen with email and password');
    expect(suggestion, findsWidgets);
    await tester.tap(suggestion.first);

    // Send the prompt
    final sendBtn = find.text('Send');
    expect(sendBtn, findsOneWidget);
    await tester.tap(sendBtn);
    await tester.pumpAndSettle();

    // Assert that the login mock content is present
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
  });
}

