import 'package:flutter/material.dart';
import '../../utils/common_props.dart';
import '../base_ds.dart';

class ElevatedButtonDS extends BaseDS<ElevatedButton> {
  ElevatedButtonDS({required this.label, this.onPressed, this.style});
  final String label;
  final VoidCallback? onPressed;
  final ButtonStyle? style;

  @override
  String get type => 'elevatedButton';

  @override
  ElevatedButton build() => ElevatedButton(
    onPressed: onPressed ?? () {},
    style: style,
    child: Text(label),
  );

  factory ElevatedButtonDS.fromJson(Map<String, dynamic> json) =>
      ElevatedButtonDS(
        label: (json['label'] ?? '').toString(),
        style: _buttonStyleFromJson(json['style']),
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'label': label,
    if (style != null) 'style': _buttonStyleToJson(style!),
  };
}

ButtonStyle? _buttonStyleFromJson(dynamic value) {
  if (value is! Map) return null;
  final map = value;
  final bg = CommonProps.parseColor(map['backgroundColor']);
  final fg = CommonProps.parseColor(map['foregroundColor']);
  final radius = (map['borderRadius'] as num?)?.toDouble();
  final padding = CommonProps.parsePadding(map['padding']);
  return ElevatedButton.styleFrom(
    backgroundColor: bg,
    foregroundColor: fg,
    padding: padding,
    shape: radius != null
        ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))
        : null,
  );
}

dynamic _buttonStyleToJson(ButtonStyle style) {
  // Cannot fully serialize arbitrary ButtonStyle; include the fields we set via styleFrom
  return {};
}
