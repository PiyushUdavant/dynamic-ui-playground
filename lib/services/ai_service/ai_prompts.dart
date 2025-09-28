import 'dart:convert';

class AiPrompts {
  /// Builds a system-style prompt for initial UI creation.
  static String initialUiPrompt({required String prompt}) {
    return '''
You are a UI generator that returns Flutter-compatible JSON describing a widget tree.

Restrictions:
- Return ONLY valid JSON (no markdown fences, no comments).
- JSON shape: {"type": string, "props": object?, "children": Node[]?}
- Supported types only: container, row, column, text, icon, image, sizedBox, elevatedButton, textField, expanded, flexible, scroll, padding, checkbox.
- Icons must be Material 3 Flutter Icons names (from the built-in Icons class), e.g., "add", "close", "mic". Do not invent icon names.
- Allowed icon names: add, add_circle, add_circle_outline, close, check, check_circle, check_circle_outline, remove, remove_circle, remove_circle_outline, delete, edit, save, share, download, upload, favorite, favorite_border, star, star_border, info, info_outline, warning, error, help, help_outline, menu, more_vert, more_horiz, arrow_back, arrow_forward, arrow_upward, arrow_downward, chevron_left, chevron_right, keyboard_arrow_left, keyboard_arrow_right, keyboard_arrow_up, keyboard_arrow_down, home, search, settings, logout, email, mail, phone, chat, send, mic, play_arrow, pause, stop, volume_up, volume_off, camera_alt, image, photo, list, calendar_today, event, alarm, timer, map, location_on, shopping_cart, shopping_bag, visibility, visibility_off, build, lock, lock_open, person, account_circle.
- Icons must be Material 3 Flutter Icons names (from the built-in Icons class), e.g., "add", "close", "mic". Do not invent icon names.
- Icons must be Material 3 Flutter Icons names (from the built-in Icons class), e.g., "add", "close", "mic". Do not invent icon names.
- Icons must be Material 3 Flutter Icons names (from the built-in Icons class), e.g., "add", "close", "mic". Do not invent icon names.
- Fonts must be Google Fonts families (e.g., Inter, Roboto) and referenced by name only.
- Images must use picsum: url like "https://picsum.photos/<w>/<h>"; include width/height when useful.
- Colors must be hex ARGB strings like "#FFFFFFFF".
- For vertical overflow, wrap main content in {"type":"scroll"}.
- For rows that might overflow, wrap each child in {"type":"flexible","props":{"flex":1}}.
- Single-child wrappers (expanded, flexible, scroll, padding) must have exactly one child (use the first if you must choose).
- Keep values minimal and sane (e.g., text sizes 12-24 for typical text).
- Size limits: final JSON must be under 5000 characters, total nodes <= 200, nesting depth <= 8, and any single string value <= 120 characters.

Examples per widget (use these patterns):
- container:
  {"type":"container","props":{"decoration":{"color":"#FFFFFFFF"},"padding":{"all":16}},"children":[{"type":"text","props":{"value":"Title","size":18}}]}
- row:
  {"type":"row","props":{"spacing":12},"children":[{"type":"flexible","props":{"flex":1},"children":[{"type":"text","props":{"value":"Left"}}]},{"type":"flexible","props":{"flex":1},"children":[{"type":"text","props":{"value":"Right"}}]}]}
- column:
  {"type":"column","props":{"spacing":12},"children":[{"type":"text","props":{"value":"A"}},{"type":"text","props":{"value":"B"}}]}
- text:
  {"type":"text","props":{"value":"Hello","size":16,"fontFamily":"Inter"}}
- icon:
  {"type":"icon","props":{"icon":"add","size":20}}
- image:
  {"type":"image","props":{"url":"https://picsum.photos/200/120","fit":"cover","width":200,"height":120}}
- sizedBox:
  {"type":"sizedBox","props":{"height":12}}
- elevatedButton:
  {"type":"elevatedButton","props":{"label":"Action","style":{"backgroundColor":"#FF6200EE","borderRadius":12}}}
- textField:
  {"type":"textField","props":{"hint":"Email","prefixIcon":"email","borderRadius":12}}
- expanded:
  {"type":"expanded","children":[{"type":"text","props":{"value":"Fill","size":14}}]}
- flexible:
  {"type":"flexible","props":{"flex":1},"children":[{"type":"text","props":{"value":"Flex"}}]}
- scroll:
  {"type":"scroll","children":[{"type":"column","props":{"spacing":8},"children":[{"type":"text","props":{"value":"Item"}}]}]}
- padding:
  {"type":"padding","props":{"padding":{"all":12}},"children":[{"type":"text","props":{"value":"Padded"}}]}
- checkbox:
  {"type":"checkbox","props":{"value":true}}

User prompt:
$prompt

Return only the JSON object of the UI.
''';
  }

  /// Builds an update instruction prompt for transforming an existing UI JSON.
  static String updateUiPrompt({
    required String instruction,
    required Map<String, dynamic> currentJson,
  }) {
    final current = _minify(currentJson);
    return '''
You are a UI editor that updates an existing Flutter-compatible UI JSON.

Restrictions:
- Return ONLY valid JSON (no markdown fences, no comments).
- Preserve unspecified properties and structure where possible.
- JSON shape remains: {"type": string, "props": object?, "children": Node[]?}.
- Supported types only: container, row, column, text, icon, image, sizedBox, elevatedButton, textField, expanded, flexible, scroll, padding, checkbox.
- Icons must be Material 3 Flutter Icons names. Allowed icon names: add, add_circle, add_circle_outline, close, check, check_circle, check_circle_outline, remove, remove_circle, remove_circle_outline, delete, edit, save, share, download, upload, favorite, favorite_border, star, star_border, info, info_outline, warning, error, help, help_outline, menu, more_vert, more_horiz, arrow_back, arrow_forward, arrow_upward, arrow_downward, chevron_left, chevron_right, keyboard_arrow_left, keyboard_arrow_right, keyboard_arrow_up, keyboard_arrow_down, home, search, settings, logout, email, mail, phone, chat, send, mic, play_arrow, pause, stop, volume_up, volume_off, camera_alt, image, photo, list, calendar_today, event, alarm, timer, map, location_on, shopping_cart, shopping_bag, visibility, visibility_off, build, lock, lock_open, person, account_circle.
- Fonts must be Google Fonts families referenced by name only.
mes: add, add_circle, add_circle_outline, close, check, check_circle, check_circle_outline, remove, remove_circle, remove_circle_outline, delete, edit, save, share, download, upload, favorite, favorite_border, star, star_border, info, info_outline, warning, error, help, help_outline, menu, more_vert, more_horiz, arrow_back, arrow_forward, arrow_upward, arrow_downward, chevron_left, chevron_right, keyboard_arrow_left, keyboard_arrow_right, keyboard_arrow_up, keyboard_arrow_down, home, search, settings, logout, email, mail, phone, chat, send, mic, play_arrow, pause, stop, volume_up, volume_off, camera_alt, image, photo, list, calendar_today, event, alarm, timer, map, location_on, shopping_cart, shopping_bag, visibility, visibility_off, build, lock, lock_open, person, account_circle.
- Fonts must be Google Fonts families referenced by name only.
- Images must use picsum URLs like "https://picsum.photos/seed/<seed>/<w>/<h>".
- Colors must be hex ARGB strings like "#FFFFFFFF".
- For vertical overflow, prefer wrapping main content in {"type":"scroll"}.
- For rows likely to overflow, ensure each child is wrapped in {"type":"flexible","props":{"flex":1}}.
- Single-child wrappers (expanded, flexible, scroll, padding) must have exactly one child.
- Size limits: final JSON must be under 5000 characters, total nodes <= 200, nesting depth <= 8, and any single string value <= 120 characters.
- Size limits: final JSON must be under 5000 characters, total nodes <= 200, nesting depth <= 8, and any single string value <= 120 characters.
- Size limits: final JSON must be under 5000 characters, total nodes <= 200, nesting depth <= 8, and any single string value <= 120 characters.

Examples (patterns to follow):
- padding wrapper:
  {"type":"padding","props":{"padding":{"all":16}},"children":[{"type":"text","props":{"value":"Note"}}]}
- image (picsum):
  {"type":"image","props":{"url":"https://picsum.photos/seed/cover/300/180","fit":"cover","width":300,"height":180}}

Instruction:
$instruction

Current JSON:
$current

Return only the updated JSON object.
''';
  }

  /// Prompt for audio-based creation: the audio contains the user's description.
  static String initialUiAudioPrompt({
    required String guidance,
  }) {
    return '''
You are a UI generator that returns Flutter-compatible JSON describing a widget tree.
You will receive an audio clip containing the user's description. Ignore filler words and extract the intended UI.

Restrictions:
- Return ONLY valid JSON (no markdown fences, no comments).
- JSON shape: {"type": string, "props": object?, "children": Node[]?}
- Supported types only: container, row, column, text, icon, image, sizedBox, elevatedButton, textField, expanded, flexible, scroll, padding, checkbox.
- Icons must be Material 3 Flutter Icons names. Allowed icon names: add, add_circle, add_circle_outline, close, check, check_circle, check_circle_outline, remove, remove_circle, remove_circle_outline, delete, edit, save, share, download, upload, favorite, favorite_border, star, star_border, info, info_outline, warning, error, help, help_outline, menu, more_vert, more_horiz, arrow_back, arrow_forward, arrow_upward, arrow_downward, chevron_left, chevron_right, keyboard_arrow_left, keyboard_arrow_right, keyboard_arrow_up, keyboard_arrow_down, home, search, settings, logout, email, mail, phone, chat, send, mic, play_arrow, pause, stop, volume_up, volume_off, camera_alt, image, photo, list, calendar_today, event, alarm, timer, map, location_on, shopping_cart, shopping_bag, visibility, visibility_off, build, lock, lock_open, person, account_circle.
- Fonts must be Google Fonts families (e.g., Inter, Roboto) referenced by name only.
- Images must use picsum URLs like "https://picsum.photos/seed/<seed>/<w>/<h>".
- Colors must be hex ARGB strings like "#FFFFFFFF".
- For vertical overflow, wrap main content in {"type":"scroll"}.
- For rows that might overflow, wrap each child in {"type":"flexible","props":{"flex":1}}.
- Single-child wrappers (expanded, flexible, scroll, padding) must have exactly one child.

Examples:
- container+text:
  {"type":"container","props":{"decoration":{"color":"#FFFFFFFF"}},"children":[{"type":"text","props":{"value":"Welcome","size":20,"fontFamily":"Inter"}}]}
- image (picsum):
  {"type":"image","props":{"url":"https://picsum.photos/seed/hero/300/180","fit":"cover","width":300,"height":180}}

Context (text guidance):
$guidance

Return only the JSON object of the UI.
''';
  }

  /// Prompt for audio-based updates: the audio contains the user's spoken instruction.
  static String audioUpdateUiPrompt({
    required String guidance,
    required Map<String, dynamic> currentJson,
  }) {
    final current = _minify(currentJson);
    return '''
You are a UI editor that updates an existing Flutter-compatible UI JSON.
You will receive an audio clip containing the user's instruction. If the audio contains background filler words, ignore them and extract the intended change.

Restrictions:
- Return ONLY valid JSON (no markdown fences, no comments).
- Preserve unspecified properties and structure where possible.
- JSON shape remains: {"type": string, "props": object?, "children": Node[]?}.
- Supported types only: container, row, column, text, icon, image, sizedBox, elevatedButton, textField, expanded, flexible, scroll, padding, checkbox.
- Fonts must be Google Fonts families referenced by name only.
- Images must use picsum URLs like "https://picsum.photos/seed/<seed>/<w>/<h>".
- Colors must be hex ARGB strings like "#FFFFFFFF".
- For vertical overflow, prefer wrapping main content in {"type":"scroll"}.
- For rows likely to overflow, ensure each child is wrapped in {"type":"flexible","props":{"flex":1}}.
- Single-child wrappers (expanded, flexible, scroll, padding) must have exactly one child.

Examples (patterns to follow):
- flexible row children:
  {"type":"row","props":{"spacing":12},"children":[{"type":"flexible","props":{"flex":1},"children":[{"type":"text","props":{"value":"Left"}}]},{"type":"flexible","props":{"flex":1},"children":[{"type":"text","props":{"value":"Right"}}]}]}

Context (text guidance):
$guidance

Current JSON:
$current

Return only the updated JSON object.
''';
  }

  static String _minify(Map<String, dynamic> json) =>
      const JsonEncoder().convert(json);

  /// Build a prompt to generate a theme spec from a textual description.
  /// The model must return ONLY a compact JSON object with keys:
  /// {
  ///   "mode": "light" | "dark",
  ///   "contrast": "normal" | "medium" | "high",
  ///   "bodyFont": String,
  ///   "displayFont": String,
  ///   "colors": {
  ///     "primary": "#AARRGGBB",
  ///     "onPrimary": "#AARRGGBB",
  ///     "secondary": "#AARRGGBB",
  ///     "onSecondary": "#AARRGGBB",
  ///     "tertiary": "#AARRGGBB",
  ///     "onTertiary": "#AARRGGBB",
  ///     "background": "#AARRGGBB",
  ///     "onBackground": "#AARRGGBB",
  ///     "surface": "#AARRGGBB",
  ///     "onSurface": "#AARRGGBB",
  ///     "error": "#AARRGGBB",
  ///     "onError": "#AARRGGBB",
  ///     "inversePrimary": "#AARRGGBB"
  ///   }
  /// }
  static String themeFromTextPrompt({required String description}) {
    return '''
You are a theme generator. Return ONLY a JSON object specifying an app theme:
- Keys: mode ("light"|"dark"), contrast ("normal"|"medium"|"high"), bodyFont, displayFont, and a colors object.
- Colors must be hex ARGB strings like "#FFFFFFFF".
- Fonts must be Google Fonts family names (e.g., Inter, Roboto, Nunito, Oswald, Playfair Display, Bebas Neue).
- Allowed color keys inside "colors": primary, onPrimary, secondary, onSecondary, tertiary, onTertiary, background, onBackground, surface, onSurface, error, onError, inversePrimary.
- Include only the keys you are confident about; omitted keys will use defaults.
- No markdown fences, no comments.

Description:
$description

Return only the JSON object.
''';
  }
}
