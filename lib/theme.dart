import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;
  final Color seedColor;

  const MaterialTheme(
    this.textTheme, {
    this.seedColor = const Color(0xFF6750A4),
  });

  ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
    );
    return theme(scheme);
  }

  ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return theme(scheme);
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.surface,
    canvasColor: colorScheme.surface,
  );
}
