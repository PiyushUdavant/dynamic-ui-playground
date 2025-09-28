import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Default JSON that defines the initial UI layout when the app starts.
///
/// This serves as the home screen for the Dynamic UI Playground app, showcasing
/// a welcome header, instructions for using the app, and a placeholder image.
/// The structure demonstrates various widget types like containers, columns,
/// rows, texts, and images that can be dynamically generated and modified.
///
/// The JSON follows the app's widget schema where each node has:
/// - `type`: The widget type (container, column, text, image, etc.)
/// - `props`: Properties specific to that widget (colors, sizes, alignment)
/// - `children`: Optional array of child widgets for layout containers
const Map<String, dynamic> kDefaultDynamicUiJson = {
  'type': 'container',
  'props': {
    'padding': {'all': 16},
  },
  'children': [
    {
      'type': 'column',
      'props': {
        'spacing': 0,
        'mainAxisAlignment': 'center',
        'crossAxisAlignment': 'center',
      },
      'children': [
        // Hero header
        {
          'type': 'container',
          'props': {
            'decoration': {'color': '#FFFFB100'},
            'padding': {'all': 24},
            'alignment': 'center',
          },
          'children': [
            {
              'type': 'column',
              'props': {
                'spacing': 8,
                'mainAxisAlignment': 'center',
                'crossAxisAlignment': 'center',
              },
              'children': [
                {
'type': 'icon',
                  'props': {
                    'icon': 'star',
                    'size': 36,
                    'color': '#FFFFFFFF',
                    'material3': true,
                    'm3Style': 'outlined',
                    'm3Weight': 700,
                    'm3OpticalSize': 48,
                  },
                },
                {
                  'type': 'text',
                  'props': {
                    'value': 'Dynamic UI Playground',
                    'size': 22,
                    'align': 'center',
                    'fontFamily': 'Inter',
                    'color': '#FFFFFFFF',
                  },
                },
                {
                  'type': 'text',
                  'props': {
                    'value': 'Build and evolve your UI from JSON',
                    'size': 14,
                    'align': 'center',
                    'color': '#FFFFFFFF',
                  },
                },
              ],
            },
          ],
        },

        {
          'type': 'sizedBox',
          'props': {'height': 12},
        },

        // Content card
        {
          'type': 'container',
          'props': {
            'decoration': {
              'borderRadius': {'all': 16},
            },
            'padding': {'all': 16},
          },
          'children': [
            {
              'type': 'column',
              'props': {'spacing': 12},
              'children': [
                {
                  'type': 'text',
                  'props': {
                    'value': 'How it works',
                    'size': 18,
                    'fontFamily': 'Inter',
                  },
                },
                {
                  'type': 'column',
                  'props': {'spacing': 8},
                  'children': [
                    {
                      'type': 'row',
                      'props': {'spacing': 8},
                      'children': [
                        {
                          'type': 'icon',
                          'props': {'icon': 'add', 'size': 20},
                        },
                        {
                          'type': 'text',
                          'props': {
                            'value': 'Tap the button to open the input sheet',
                            'size': 14,
                          },
                        },
                      ],
                    },
                    {
                      'type': 'row',
                      'props': {'spacing': 8},
                      'children': [
                        {
                          'type': 'icon',
                          'props': {'icon': 'add', 'size': 20},
                        },
                        {
                          'type': 'text',
                          'props': {
                            'value':
                                'Choose Create to load a beautiful sample screen',
                            'size': 14,
                          },
                        },
                      ],
                    },
                    {
                      'type': 'row',
                      'props': {'spacing': 8},
                      'children': [
                        {
                          'type': 'icon',
                          'props': {'icon': 'add', 'size': 20},
                        },
                        {
                          'type': 'expanded',
                          'children': [
                            {
                              'type': 'text',
                              'props': {
                                'value':
                                    'Choose Update to tweak borders, colors, fonts, and layout',
                                'size': 14,
                                'fontFamily': 'Inter',
                                'overFlow': 'ellipsis',
                                'maxLines': 2,
                              },
                            },
                          ],
                        },
                      ],
                    },
                  ],
                },

                {
                  'type': 'sizedBox',
                  'props': {'height': 8},
                },

                {
                  'type': 'text',
                  'props': {'value': 'Tips', 'size': 18, 'fontFamily': 'Inter'},
                },
                {
                  'type': 'column',
                  'props': {'spacing': 8},
                  'children': [
                    {
                      'type': 'row',
                      'props': {'spacing': 8},
                      'children': [
                        {
                          'type': 'icon',
                          'props': {'icon': 'add', 'size': 20},
                        },
                        {
                          'type': 'text',
                          'props': {
                            'value':
                                'Try: "Change the background color to #FFF2F2F2"',
                            'size': 14,
                          },
                        },
                      ],
                    },
                    {
                      'type': 'row',
                      'props': {'spacing': 8},
                      'children': [
                        {
                          'type': 'icon',
                          'props': {'icon': 'add', 'size': 20},
                        },
                        {
                          'type': 'text',
                          'props': {
                            'value': 'Try: "Round the input borders by 20"',
                            'size': 14,
                          },
                        },
                      ],
                    },
                    {
                      'type': 'row',
                      'props': {'spacing': 8},
                      'children': [
                        {
                          'type': 'icon',
                          'props': {'icon': 'add', 'size': 20},
                        },
                        {
                          'type': 'text',
                          'props': {
                            'value':
                                'Try: "Add a text widget after image widget"',
                            'size': 14,
                          },
                        },
                      ],
                    },
                  ],
                },
              ],
            },
          ],
        },

        {
          'type': 'sizedBox',
          'props': {'height': 12},
        },

        // Footer logo
        {
          'type': 'image',
          'props': {
            'url':
                'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif',
            'fit': 'contain',
            'height': 150,
          },
        },

        {
          'type': 'sizedBox',
          'props': {'height': 24},
        },
      ],
    },
  ],
};

/// Async notifier that simulates fetching the JSON from a backend.
/// Exposes a reset method to invalidate and restore defaults.
class DynamicUiJsonNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  FutureOr<Map<String, dynamic>> build() async {
    return kDefaultDynamicUiJson;
  }

  Future<void> refreshFromServer() async {
    state = const AsyncLoading();
    state = AsyncData({
      ...kDefaultDynamicUiJson,
      'children': [
        ...kDefaultDynamicUiJson['children'] as List,
        {
          'type': 'text',
          'props': {
            'value': 'Fetched at ${DateTime.now().toIso8601String()}',
            'size': 12,
            'align': 'center',
          },
        },
      ],
    });
  }

  void resetToDefault() {
    state = const AsyncLoading();
    // No delay needed, but we keep a micro delay to yield the event loop
    Future<void>.microtask(
      () => state = const AsyncData(kDefaultDynamicUiJson),
    );
  }

  void applyJson(Map<String, dynamic> json) {
    state = AsyncData(json);
  }

  void setLoading() {
    state = const AsyncLoading();
  }
}

final dynamicUiJsonProvider =
    AsyncNotifierProvider<DynamicUiJsonNotifier, Map<String, dynamic>>(
      () => DynamicUiJsonNotifier(),
    );
