import 'package:flutter/material.dart';

/// Common prop helpers: alignment, padding, color parsing
class CommonProps {
  // Parse
  static Alignment? parseAlignment(dynamic value) {
    if (value is String) {
      switch (value) {
        case 'center':
          return Alignment.center;
        case 'topCenter':
          return Alignment.topCenter;
        case 'bottomCenter':
          return Alignment.bottomCenter;
        case 'centerLeft':
          return Alignment.centerLeft;
        case 'centerRight':
          return Alignment.centerRight;
      }
    }
    return null;
  }

  static EdgeInsets? parsePadding(dynamic value) {
    if (value is Map) {
      if (value['all'] != null) {
        final d = (value['all'] as num).toDouble();
        return EdgeInsets.all(d);
      }
      return EdgeInsets.fromLTRB(
        (value['left'] as num? ?? 0).toDouble(),
        (value['top'] as num? ?? 0).toDouble(),
        (value['right'] as num? ?? 0).toDouble(),
        (value['bottom'] as num? ?? 0).toDouble(),
      );
    }
    if (value is num) return EdgeInsets.all(value.toDouble());
    return null;
  }

  static Color? parseColor(dynamic value) {
    if (value is int) return Color(value);
    if (value is String) {
      var hex = value.replaceAll('#', '').toUpperCase();
      if (hex.length == 6) hex = 'FF$hex';
      if (hex.length == 8) {
        final intVal = int.tryParse(hex, radix: 16);
        if (intVal != null) return Color(intVal);
      }
    }
    return null;
  }

  // To JSON helpers
  static String? alignmentToString(Alignment? alignment) {
    if (alignment == null) return null;
    if (alignment == Alignment.center) return 'center';
    if (alignment == Alignment.topCenter) return 'topCenter';
    if (alignment == Alignment.bottomCenter) return 'bottomCenter';
    if (alignment == Alignment.centerLeft) return 'centerLeft';
    if (alignment == Alignment.centerRight) return 'centerRight';
    return null;
  }

  static dynamic paddingToJson(EdgeInsets? padding) {
    if (padding == null) return null;
    if (padding.left == padding.top &&
        padding.top == padding.right &&
        padding.right == padding.bottom) {
      return {'all': padding.left};
    }
    return {
      'left': padding.left,
      'top': padding.top,
      'right': padding.right,
      'bottom': padding.bottom,
    };
  }

  static String? colorToHex(Color? color) {
    if (color == null) return null;
    final value = color.toARGB32();
    return '#${value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
  }
}
