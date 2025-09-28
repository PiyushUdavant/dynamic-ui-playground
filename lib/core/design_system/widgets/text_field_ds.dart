import 'package:flutter/material.dart';
import '../base_ds.dart';

class TextFieldDS extends BaseDS<TextField> {
  TextFieldDS({
    this.hint,
    this.label,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText,
    this.borderRadius,
  });
  final String? hint;
  final String? label;
  final String? helperText;
  final String? prefixIcon; // basic names
  final String? suffixIcon;
  final bool? obscureText;
  final double? borderRadius;

  @override
  String get type => 'textField';

  @override
  TextField build() => TextField(
    decoration: InputDecoration(
      hintText: hint,
      labelText: label,
      helperText: helperText,
      prefixIcon: _iconFromName(prefixIcon),
      suffixIcon: _iconFromName(suffixIcon),
      border: OutlineInputBorder(
        borderRadius: borderRadius != null
            ? BorderRadius.circular(borderRadius!)
            : BorderRadius.zero,
      ),
    ),
    obscureText: obscureText ?? false,
  );

  factory TextFieldDS.fromJson(Map<String, dynamic> json) => TextFieldDS(
    hint: json['hint']?.toString(),
    label: json['label']?.toString(),
    helperText: json['helperText']?.toString(),
    prefixIcon: json['prefixIcon']?.toString(),
    suffixIcon: json['suffixIcon']?.toString(),
    obscureText: json['obscureText'] as bool?,
    borderRadius: (json['borderRadius'] as num?)?.toDouble(),
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (hint != null) 'hint': hint,
    if (label != null) 'label': label,
    if (helperText != null) 'helperText': helperText,
    if (prefixIcon != null) 'prefixIcon': prefixIcon,
    if (suffixIcon != null) 'suffixIcon': suffixIcon,
    if (obscureText != null) 'obscureText': obscureText,
    if (borderRadius != null) 'borderRadius': borderRadius,
  };
}

Widget? _iconFromName(String? name) {
  if (name == null || name.isEmpty) return null;
  switch (name) {
    case 'email':
      return const Icon(Icons.email);
    case 'lock':
      return const Icon(Icons.lock);
    default:
      return const Icon(Icons.circle);
  }
}
