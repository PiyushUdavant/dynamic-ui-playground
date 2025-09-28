import 'package:dynamic_ui_playground/features/dynamic_ui/presentation/widgets/dynamic_ui_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DynamicUiBuilder', () {
    testWidgets('builds a composite tree from JSON (text, textField, button, icon)', (tester) async {
      final json = <String, dynamic>{
        'type': 'container',
        'props': {
          'padding': {'all': 8},
        },
        'children': [
          {
            'type': 'column',
            'props': {
              'spacing': 8,
              'crossAxisAlignment': 'start',
            },
            'children': [
              {
                'type': 'text',
                'props': {'value': 'Hello Dynamic UI', 'size': 16},
              },
              {
                'type': 'textField',
                'props': {'hint': 'Email', 'borderRadius': 8},
              },
              {
                'type': 'elevatedButton',
                'props': {'label': 'Tap'},
              },
              {
                'type': 'row',
                'props': {'spacing': 4},
                'children': [
                  {
                    'type': 'icon',
                    'props': {'icon': 'add', 'size': 20},
                  },
                ],
              },
              {
                'type': 'sizedBox',
                'props': {'height': 10, 'width': 10},
              },
            ],
          },
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicUiBuilder(json: json),
          ),
        ),
      );

      // Let implicit animations (fadeIn) start
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Hello Dynamic UI'), findsOneWidget);

      // Ensure any implicit animations/timers settle to avoid leaks
      await tester.pumpAndSettle(const Duration(milliseconds: 10));
      // Rely on label text presence for the button
      expect(find.text('Tap'), findsOneWidget);
      // A TextField should be present
      expect(find.byType(TextField), findsOneWidget);
      // An icon (built by DS) should eventually render to an Icon
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('supports wrapper widgets like padding and scroll', (tester) async {
      final json = <String, dynamic>{
        'type': 'padding',
        'props': {
          'all': 12,
        },
        'children': [
          {
            'type': 'scroll',
            'props': {},
            'children': [
              {
                'type': 'column',
                'props': {'spacing': 8},
                'children': [
                  {
                    'type': 'text',
                    'props': {'value': 'Wrapped Text'},
                  }
                ],
              },
            ],
          },
        ],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DynamicUiBuilder(json: json),
          ),
        ),
      );

      await tester.pump();
      expect(find.text('Wrapped Text'), findsOneWidget);

      // Let flutter_animate timers complete to avoid pending timers after dispose
      await tester.pumpAndSettle();
    });
  });
}

