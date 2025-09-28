import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme contrast variants supported by MaterialTheme in theme.dart
enum ThemeContrast {
  normal,
  medium,
  high,
}

/// Holds the current theme contrast selection. Defaults to [ThemeContrast.normal].
final themeContrastProvider = StateProvider<ThemeContrast>((ref) => ThemeContrast.normal);
