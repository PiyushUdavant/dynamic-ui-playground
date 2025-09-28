import 'package:flutter_test/flutter_test.dart';
import 'package:dynamic_ui_playground/features/dynamic_ui/domain/mocks/ui_json_mocks.dart';

void main() {
  group('getUpdateMockForPrompt', () {
    Map<String, dynamic> makeCurrentJson() => {
          'type': 'container',
          'props': {
            'decoration': {'color': '#FFFFFFFF'},
          },
          'children': [
            {
              'type': 'column',
              'props': {'spacing': 8},
              'children': [
                {
                  'type': 'image',
                  'props': {
                    'url': 'https://picsum.photos/seed/foo/100/60',
                    'fit': 'contain',
                    'height': 60,
                    'width': 100,
                  },
                },
                {
                  'type': 'text',
                  'props': {'value': 'Hello', 'size': 14},
                },
                {
                  'type': 'textField',
                  'props': {'hint': 'Email', 'borderRadius': 4},
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
              ],
            },
          ],
        };

    test('changes background color without mutating original', () {
      final current = makeCurrentJson();
      final updated = getUpdateMockForPrompt(
        'Change the background color to #3d2d01',
        current,
      );

      expect(updated, isNotNull);
      expect(
        (updated!['props'] as Map)['decoration']['color'],
        '#3d2d01',
      );

      // original is unchanged
      expect(
        (current['props'] as Map)['decoration']['color'],
        '#FFFFFFFF',
      );
    });

    test('rounds input borders by radius', () {
      final current = makeCurrentJson();
      final updated = getUpdateMockForPrompt(
        'Round the input borders by 20',
        current,
      )!;

      // find textField node
      final column = (updated['children'] as List).first as Map;
      final children = (column['children'] as List).cast<Map>();
      final tf = children.firstWhere((e) => e['type'] == 'textField');
      expect((tf['props'] as Map)['borderRadius'], 20);
    });

    test('removes the last item from the first node with children', () {
      final current = makeCurrentJson();
      final updated = getUpdateMockForPrompt(
        'Remove the last item',
        current,
      )!;

      final column = (updated['children'] as List).first as Map;
      final children = (column['children'] as List);
      // original had 4 children, now should have 3
      expect(children.length, 3);
    });

    test('adds a text widget after image widget', () {
      final current = makeCurrentJson();
      final updated = getUpdateMockForPrompt(
        'Add a text widget after image widget',
        current,
      )!;

      final column = (updated['children'] as List).first as Map;
      final children = (column['children'] as List).cast<Map>();
      final imageIndex = children.indexWhere((e) => e['type'] == 'image');
      expect(imageIndex, isNonNegative);
      final next = children[imageIndex + 1];
      expect(next['type'], 'text');
    });

    test('changes image fit to cover', () {
      final current = makeCurrentJson();
      final updated = getUpdateMockForPrompt(
        'Change the image fit to cover',
        current,
      )!;

      final column = (updated['children'] as List).first as Map;
      final children = (column['children'] as List).cast<Map>();
      final img = children.firstWhere((e) => e['type'] == 'image');
      expect((img['props'] as Map)['fit'], 'cover');
    });

    test('changes image size to 300x180', () {
      final current = makeCurrentJson();
      final updated = getUpdateMockForPrompt(
        'Change the image size to 300x180',
        current,
      )!;

      final column = (updated['children'] as List).first as Map;
      final children = (column['children'] as List).cast<Map>();
      final img = children.firstWhere((e) => e['type'] == 'image');
      expect((img['props'] as Map)['width'], 300);
      expect((img['props'] as Map)['height'], 180);
    });

    test('changes the fontfamily to Bebas Neue', () {
      final current = makeCurrentJson();
      final updated = getUpdateMockForPrompt(
        'Change the fontfamily to Bebas Neue',
        current,
      )!;

      final column = (updated['children'] as List).first as Map;
      final children = (column['children'] as List).cast<Map>();
      final txt = children.firstWhere((e) => e['type'] == 'text');
      expect((txt['props'] as Map)['fontFamily'], 'Bebas Neue');
    });

    test('returns null for unsupported prompt', () {
      final current = makeCurrentJson();
      final updated = getUpdateMockForPrompt(
        'Unsupported change please',
        current,
      );
      expect(updated, isNull);
    });
  });
}

