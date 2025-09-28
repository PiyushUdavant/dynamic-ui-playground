// ignore_for_file: unintended_html_in_doc_comment

/// Default "Create" suggestions shown in the input sheet.
///
/// These correspond to richer, hand-crafted JSON mocks returned by
/// [getCreateMockForPrompt] to instantly demonstrate the system without
/// calling the AI service.
const List<String> kDefaultCreateSuggestions = [
  'Create a login screen with email and password',
  'Add a profile header with avatar and name',
  'Build a 2x2 grid of product cards',
  'Show a list of news articles with images',
  'Compose a settings page with toggles',
];

/// Return a full UI JSON mock that matches an exact Create [prompt],
/// or null if no mock is defined.
Map<String, dynamic>? getCreateMockForPrompt(String prompt) {
  switch (prompt) {
    case 'Create a login screen with email and password':
      return _loginScreen();
    case 'Add a profile header with avatar and name':
      return _profileHeader();
    case 'Build a 2x2 grid of product cards':
      return _productGrid();
    case 'Show a list of news articles with images':
      return _newsList();
    case 'Compose a settings page with toggles':
      return _settingsPage();
    default:
      return null;
  }
}

// Update suggestions and mocks
/// Default "Update" suggestions. The list is combined with contextual
/// suggestions produced by [getUpdateSuggestionsForJson].
const List<String> kDefaultUpdateSuggestions = [
  'Change the background color to #3d2d01',
  'Change the fontfamily to Open Sans',
  'Round the input borders by 20',
  'Remove the last item',
  'Add a text widget after image widget',
  'Change the image fit to cover',
];

/// Build context-aware update suggestions based on the current JSON.
///
/// Walks the tree and records which widget types are present, then combines a
/// small set of defaults with context-specific entries (e.g., if an image
/// exists, propose changing its fit or adding text after it). The output is
/// de-duplicated and capped by [max].
List<String> getUpdateSuggestionsForJson(
  Map<String, dynamic> current, {
  int max = 5,
}) {
  bool hasImage = false;
  bool hasTextField = false;
  bool hasContainer = false;
  bool hasText = false;
  final types = <String>{};

  void visit(Map<String, dynamic> n) {
    final t = (n['type'] as String?)?.toLowerCase() ?? '';
    types.add(t);
    if (t == 'image') hasImage = true;
    if (t == 'textfield' || t == 'text_field') hasTextField = true;
    if (t == 'container') hasContainer = true;
    if (t == 'text') hasText = true;
    final children =
        (n['children'] as List?)?.whereType<Map>() ??
        const Iterable<Map>.empty();
    for (final c in children) {
      visit(c.cast<String, Object?>());
    }
  }

  visit(current);

  final suggestions = <String>[];
  // Always useful
  suggestions.add('Remove the last item');

  if (hasContainer) {
    suggestions.add('Change the background color to #3d2d01');
  }
  if (hasTextField) {
    suggestions.add('Round the input borders by 20');
  }

  if (hasImage) {
    suggestions.add('Change the image fit to cover');
    suggestions.add('Change the image size to 300x180');
  }
  if (hasText) {
    suggestions.add('Change the fontfamily to Bebas Neue');
  }

  // Relative insert: try to anchor to an existing type
  if (hasImage) {
    suggestions.add('Add a text widget after image widget');
  } else if (types.contains('text')) {
    suggestions.add('Add a icon widget before text widget');
  } else {
    suggestions.add('Add a text widget before elevatedButton widget');
  }

  // De-duplicate and cap
  final deduped = <String>{...suggestions};
  return deduped.take(max).toList();
}

/// Return an updated JSON derived from [current] if the Update [prompt]
/// matches a supported pattern. Otherwise returns null so the AI flow can run.
///
/// Supported patterns include:
/// - Change the background color to <color>
/// - Round the input borders by <radius>
/// - Remove the last item
/// - Add a <type> widget (before|after) <anchor> widget
/// - Change the image fit to <fit>
/// - Change the image size to <w>x<h>
/// - Change the fontfamily to <family>
Map<String, dynamic>? getUpdateMockForPrompt(
  String prompt,
  Map<String, dynamic> current,
) {
  // Normalize
  final p = prompt.trim();

  // Change background color
  final bgMatch = RegExp(
    r'^Change the background color to\s+([#A-Za-z0-9]+)$',
    caseSensitive: false,
  ).firstMatch(p);
  if (bgMatch != null) {
    final color = bgMatch.group(1)!;
    return _setBackgroundColor(_clone(current), color);
  }

  // Round input borders by N
  final roundMatch = RegExp(
    r'^Round (?:the )?input borders by\s+(\d+)$',
    caseSensitive: false,
  ).firstMatch(p);
  if (roundMatch != null) {
    final radius = double.tryParse(roundMatch.group(1)!) ?? 12;
    return _roundInputBorders(_clone(current), radius);
  }

  // Remove the last item
  if (RegExp(r'^Remove the last item$', caseSensitive: false).hasMatch(p)) {
    return _removeLastChild(_clone(current));
  }

  // Add a X widget before/after Y widget
  final addMatch = RegExp(
    r'^Add a\s+(\w+)\s+widget\s+(before|after)\s+(\w+)\s+widget$',
    caseSensitive: false,
  ).firstMatch(p);
  if (addMatch != null) {
    final newType = addMatch.group(1)!.toLowerCase();
    final pos = addMatch.group(2)!.toLowerCase();
    final anchor = addMatch.group(3)!.toLowerCase();
    return _addWidgetRelative(_clone(current), newType, anchor, pos);
  }

  // Change the image fit to X
  final fitMatch = RegExp(
    r'^Change the image fit to\s+(\w+)$',
    caseSensitive: false,
  ).firstMatch(p);
  if (fitMatch != null) {
    final fit = fitMatch.group(1)!.toLowerCase();
    return _changeImageFit(_clone(current), fit);
  }

  // Change the image size to WxH
  final sizeMatch = RegExp(
    r'^Change the image size to\s*(\d+)x(\d+)$',
    caseSensitive: false,
  ).firstMatch(p);
  if (sizeMatch != null) {
    final w = double.tryParse(sizeMatch.group(1)!);
    final h = double.tryParse(sizeMatch.group(2)!);
    return _changeImageSize(_clone(current), w, h);
  }

  // Change the fontfamily to Name
  final fontMatch = RegExp(
    r'^Change the fontfamily to\s+(.+)$',
    caseSensitive: false,
  ).firstMatch(p);
  if (fontMatch != null) {
    final family = fontMatch.group(1)!.trim();
    return _changeFontFamily(_clone(current), family);
  }

  return null;
}

/// Deep-clone a JSON-like map to avoid shared references when producing
/// mock updates.
Map<String, dynamic> _clone(Map<String, dynamic> src) {
  Map<String, dynamic> newMap = {};
  src.forEach((key, value) {
    if (value is Map) {
      newMap[key] = _clone(value.cast<String, dynamic>());
    } else if (value is List) {
      newMap[key] = _cloneList(value);
    } else {
      newMap[key] = value;
    }
  });
  return newMap;
}

/// Deep-clone a JSON-like list.
List<dynamic> _cloneList(List<dynamic> srcList) {
  List<dynamic> newList = [];
  for (var item in srcList) {
    if (item is Map) {
      newList.add(_clone(item.cast<String, dynamic>()));
    } else if (item is List) {
      newList.add(_cloneList(item));
    } else {
      newList.add(item);
    }
  }
  return newList;
}

/// Set the background color on container nodes to [color].
Map<String, dynamic> _setBackgroundColor(
  Map<String, dynamic> node,
  String color,
) {
  if (node['type'] == 'container') {
    final props =
        (node['props'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    final deco =
        (props['decoration'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    deco['color'] = color;
    props['decoration'] = deco;
    node['props'] = props;
  }
  return node;
}

/// Round borders on textField nodes by [radius].
Map<String, dynamic> _roundInputBorders(
  Map<String, dynamic> node,
  double radius,
) {
  void visit(Map<String, dynamic> n) {
    if (n['type'] == 'textField') {
      final props =
          (n['props'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      props['borderRadius'] = radius;
      n['props'] = props;
    }
    final children = (n['children'] as List?)?.cast<dynamic>() ?? const [];
    for (final c in children.whereType<Map>()) {
      visit(c.cast<String, Object?>());
    }
  }

  visit(node);
  return node;
}

/// Insert a default [newType] widget before/after the first [anchorType]
/// occurrence found in a depth-first traversal.
Map<String, dynamic> _addWidgetRelative(
  Map<String, dynamic> node,
  String newType,
  String anchorType,
  String pos,
) {
  bool inserted = false;

  List<dynamic>? tryInsert(List<dynamic>? list) {
    if (list == null) return null;
    for (int i = 0; i < list.length; i++) {
      final item = list[i];
      if (item is Map &&
          (item['type'] as String?)?.toLowerCase() == anchorType) {
        final toAdd = _defaultWidgetForType(newType);
        if (toAdd == null) return list;
        final idx = pos == 'before' ? i : i + 1;
        list.insert(idx, toAdd);
        inserted = true;
        return list;
      }
    }
    return list;
  }

  void visit(Map<String, dynamic> n) {
    if (inserted) return;
    final children = (n['children'] as List?)?.cast<dynamic>();
    if (children != null) {
      final updated = tryInsert(children);
      if (inserted) return;
      for (final c in children.whereType<Map>()) {
        visit(c.cast<String, Object?>());
        if (inserted) return;
      }
      if (updated != null) n['children'] = updated;
    }
  }

  visit(node);
  return node;
}

/// Produce a minimal JSON node for a given widget [t], or null if unknown.
Map<String, Object>? _defaultWidgetForType(String t) {
  switch (t) {
    case 'text':
      return <String, Object>{
        'type': 'text',
        'props': <String, Object>{'value': 'New text', 'size': 14},
      };
    case 'icon':
      return <String, Object>{
        'type': 'icon',
        'props': <String, Object>{'icon': 'add', 'size': 20},
      };
    case 'image':
      return <String, Object>{
        'type': 'image',
        'props': <String, Object>{
          'url': 'https://picsum.photos/seed/new/100/60',
          'fit': 'cover',
          'height': 60,
        },
      };
    case 'sizedbox':
    case 'sized_box':
      return <String, Object>{
        'type': 'sizedBox',
        'props': <String, Object>{'height': 8},
      };
    case 'elevatedbutton':
    case 'elevated_button':
      return <String, Object>{
        'type': 'elevatedButton',
        'props': <String, Object>{'label': 'Action'},
      };
    default:
      return null;
  }
}

/// Change the `fit` property for all image nodes to [fit].
Map<String, dynamic> _changeImageFit(Map<String, dynamic> node, String fit) {
  void visit(Map<String, dynamic> n) {
    if (n['type'] == 'image') {
      final props =
          (n['props'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      props['fit'] = fit;
      n['props'] = props;
    }
    final children = (n['children'] as List?)?.cast<dynamic>() ?? const [];
    for (final c in children.whereType<Map>()) {
      visit(c.cast<String, Object?>());
    }
  }

  visit(node);
  return node;
}

/// Change the width/height of all image nodes to [w] and/or [h].
Map<String, dynamic> _changeImageSize(
  Map<String, dynamic> node,
  double? w,
  double? h,
) {
  void visit(Map<String, dynamic> n) {
    if (n['type'] == 'image') {
      final props =
          (n['props'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
      if (w != null) props['width'] = w;
      if (h != null) props['height'] = h;
      n['props'] = props;
    }
    final children = (n['children'] as List?)?.cast<dynamic>() ?? const [];
    for (final c in children.whereType<Map>()) {
      visit(c.cast<String, Object?>());
    }
  }

  visit(node);
  return node;
}

/// Set the `fontFamily` for all text nodes to [family].
Map<String, dynamic> _changeFontFamily(
  Map<String, dynamic> node,
  String family,
) {
  if (node['type'] == 'text') {
    final props =
        (node['props'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    props['fontFamily'] = family;
    node['props'] = props;
  }

  final children = (node['children'] as List?)?.cast<dynamic>() ?? const [];
  for (final c in children.whereType<Map>()) {
    _changeFontFamily(c.cast<String, Object?>(), family);
  }

  return node;
}

/// Remove the last child from the first node that has children.
Map<String, dynamic> _removeLastChild(Map<String, dynamic> node) {
  final map = Map<String, dynamic>.from(node);
  void visit(Map<String, dynamic> n) {
    final list = (n['children'] as List?)?.cast<dynamic>().toList();
    if (list != null && list.isNotEmpty) {
      if (list.first is Map && (list.first as Map)['children'].length > 1) {
        list.first['children'].removeLast();
        n['children'] = list;
        return;
      }

      list.removeLast();
      n['children'] = list;
    }
  }

  visit(map);
  return map;
}

/// Mock: a simple login screen with email/password fields and a primary button.
Map<String, dynamic> _loginScreen() => {
  'type': 'container',
  'props': {
    'padding': {'all': 16},
  },
  'children': [
    {
      'type': 'scroll',
      'props': {},
      'children': [
        {
          'type': 'column',
          'props': {
            'mainAxisAlignment': 'center',
            'crossAxisAlignment': 'center',
            'spacing': 16,
          },
          'children': [
            {
              'type': 'text',
              'props': {'value': 'Welcome back', 'size': 26},
            },
            {
              'type': 'textField',
              'props': {
                'hint': 'Email',
                'prefixIcon': 'email',
                'borderRadius': 12,
              },
            },
            {
              'type': 'textField',
              'props': {
                'hint': 'Password',
                'prefixIcon': 'lock',
                'obscureText': true,
                'borderRadius': 12,
              },
            },
            {
              'type': 'sizedBox',
              'props': {'width': 250},
              'children': [
                {
                  'type': 'elevatedButton',
                  'props': {
                    'label': 'Sign In',
                    'style': {
                      'padding': {'all': 12},
                      'borderRadius': 12,
                    },
                  },
                },
              ],
            },
          ],
        },
      ],
    },
  ],
};

/// Mock: a profile header with avatar, name, and actions row.
Map<String, dynamic> _profileHeader() => {
  'type': 'container',
  'props': {
    'padding': {'all': 24},
  },
  'children': [
    {
      'type': 'column',
      'props': {
        'spacing': 12,
        'mainAxisAlignment': 'start',
        'crossAxisAlignment': 'start',
      },
      'children': [
        {
          'type': 'container',
          'props': {'alignment': 'center'},
          'children': [
            {
              'type': 'image',
              'props': {
                'url': 'https://i.pravatar.cc/150?img=5',
                'fit': 'cover',
                'height': 250,
                'width': 250,
              },
            },
          ],
        },
        {
          'type': 'text',
          'props': {'value': 'Jane Doe', 'size': 22},
        },
        {
          'type': 'row',
          'props': {'spacing': 12, 'mainAxisAlignment': 'start'},
          'children': [
            {
              'type': 'flexible',
              'props': {'flex': 1},
              'children': [
                {
                  'type': 'icon',
                  'props': {'icon': 'add', 'size': 20},
                },
              ],
            },
            {
              'type': 'flexible',
              'props': {'flex': 1},
              'children': [
                {
                  'type': 'text',
                  'props': {'value': 'Follow', 'size': 16},
                },
              ],
            },
          ],
        },
      ],
    },
  ],
};

/// Mock: a 2x2 grid of product cards.
Map<String, dynamic> _productGrid() => {
  'type': 'container',
  'props': {
    'padding': {'all': 12},
  },
  'children': [
    {
      'type': 'column',
      'props': {'spacing': 12, 'crossAxisAlignment': 'center'},
      'children': [
        {
          'type': 'row',
          'props': {'spacing': 12, 'mainAxisAlignment': 'center'},
          'children': [
            {
              'type': 'flexible',
              'props': {'flex': 1},
              'children': [
                _productCard(
                  'Coffee Beans',
                  'https://picsum.photos/seed/coffee/200/120',
                  '#FFB388FF',
                ),
              ],
            },
            {
              'type': 'flexible',
              'props': {'flex': 1},
              'children': [
                _productCard(
                  'Matcha Tea',
                  'https://picsum.photos/seed/tea/200/120',
                  '#FF81C784',
                ),
              ],
            },
          ],
        },
        {
          'type': 'row',
          'props': {'spacing': 12, 'mainAxisAlignment': 'center'},
          'children': [
            {
              'type': 'flexible',
              'props': {'flex': 1},
              'children': [
                _productCard(
                  'Dark Chocolate',
                  'https://picsum.photos/seed/choco/200/120',
                  '#FF90CAF9',
                ),
              ],
            },
            {
              'type': 'flexible',
              'props': {'flex': 1},
              'children': [
                _productCard(
                  'Granola',
                  'https://picsum.photos/seed/granola/200/120',
                  '#FFFFF59D',
                ),
              ],
            },
          ],
        },
      ],
    },
  ],
};

/// Helper: build a colored product card with [title] and [imageUrl].
Map<String, dynamic> _productCard(
  String title,
  String imageUrl,
  String color,
) => {
  'type': 'container',
  'props': {
    'decoration': {
      'borderRadius': {'all': 12},
    },
    'padding': {'all': 12},
  },
  'children': [
    {
      'type': 'column',
      'props': {'spacing': 8},
      'children': [
        {
          'type': 'image',
          'props': {'url': imageUrl, 'fit': 'cover', 'height': 100},
        },
        {
          'type': 'text',
          'props': {'value': title, 'size': 16},
        },
      ],
    },
  ],
};

/// Mock: a list of 5 news items with thumbnail and text.
Map<String, dynamic> _newsList() => {
  'type': 'column',
  'props': {'spacing': 12},
  'children': List.generate(5, (i) => _newsItem(i)),
};

/// Helper: build a single news row for index [i].
Map<String, dynamic> _newsItem(int i) => {
  'type': 'row',
  'props': {'spacing': 12},
  'children': [
    {
      'type': 'flexible',
      'props': {'flex': 1},
      'children': [
        {
          'type': 'image',
          'props': {
            'url': 'https://picsum.photos/seed/news$i/120/80',
            'fit': 'cover',
            'height': 80,
            'width': 120,
          },
        },
      ],
    },
    {
      'type': 'flexible',
      'props': {'flex': 1},
      'children': [
        {
          'type': 'column',
          'props': {'spacing': 6, 'mainAxisSize': 'min'},
          'children': [
            {
              'type': 'text',
              'props': {'value': 'Headline $i', 'size': 16},
            },
            {
              'type': 'sizedBox',
              'props': {'height': 40, 'width': 250},
              'children': [
                {
                  'type': 'text',
                  'props': {
                    'value':
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
                    'size': 12,
                    'overflow': 'ellipsis',
                    'maxLines': 2,
                  },
                },
              ],
            },
          ],
        },
      ],
    },
  ],
};

/// Mock: a basic settings page with a handful of toggles (simulated).
Map<String, dynamic> _settingsPage() => {
  'type': 'column',
  'props': {'spacing': 12},
  'children': [
    _settingsTile('Notifications', true),
    _settingsTile('Dark Mode', false),
    _settingsTile('Location Services', true),
    _settingsTile('Backup over Wi-Fi', true),
  ],
};

/// Helper: build a settings row displaying [label] and a simulated toggle.
Map<String, dynamic> _settingsTile(String label, bool value) => {
  'type': 'row',
  'props': {
    'mainAxisAlignment': 'spaceBetween',
    'crossAxisAlignment': 'center',
  },
  'children': [
    {
      'type': 'flexible',
      'props': {'flex': 1},
      'children': [
        {
          'type': 'text',
          'props': {'value': label, 'size': 16},
        },
      ],
    },
    // we don't have a switch DS yet, simulate with icon
    {
      'type': 'flexible',
      'props': {'flex': 1},
      'children': [
        {
          'type': 'icon',
          'props': {'icon': value ? 'add' : 'close', 'size': 20},
        },
      ],
    },
  ],
};
