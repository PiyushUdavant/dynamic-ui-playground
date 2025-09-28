import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextTheme createTextTheme(
  BuildContext context,
  String bodyFontString,
  String displayFontString,
) {
  final baseTextTheme = Theme.of(context).textTheme;

  TextTheme _safeGet(String family, TextTheme base, String fallback) {
    try {
      final f = (family).trim();
      if (f.isEmpty) throw Exception('empty family');
      return GoogleFonts.getTextTheme(f, base);
    } catch (_) {
      // Fallback to a widely available Google Font
      return GoogleFonts.getTextTheme(fallback, base);
    }
  }

  // Robust fallbacks for body/display
  final bodyTextTheme = _safeGet(bodyFontString, baseTextTheme, 'Inter');
  final displayTextTheme = _safeGet(displayFontString, baseTextTheme, 'Bebas Neue');

  final textTheme = displayTextTheme.copyWith(
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}
