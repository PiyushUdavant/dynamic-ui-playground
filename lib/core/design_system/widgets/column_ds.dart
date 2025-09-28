import 'package:flutter/material.dart';
import '../base_ds.dart';
import '../ds_helpers.dart';

class ColumnDS extends BaseDS<Column> {
  ColumnDS({
    this.mainAxisAlignment,
    this.crossAxisAlignment,
    this.mainAxisSize,
    this.spacing,
    this.children = const [],
  });

  final MainAxisAlignment? mainAxisAlignment;
  final CrossAxisAlignment? crossAxisAlignment;
  final MainAxisSize? mainAxisSize;
  final double? spacing;
  final List<Widget> children;

  @override
  String get type => 'column';

  @override
  Column build() => Column(
    mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
    crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
    mainAxisSize: mainAxisSize ?? MainAxisSize.max,
    children: spacing == null ? children : _withSpacing(children, spacing!),
  );

  factory ColumnDS.fromJson(Map<String, dynamic> json, List<Widget> children) =>
      ColumnDS(
        mainAxisAlignment: stringToMainAxis(json['mainAxisAlignment']),
        crossAxisAlignment: stringToCrossAxis(json['crossAxisAlignment']),
        mainAxisSize: _stringToMainAxisSize(json['mainAxisSize']),
        spacing: (json['spacing'] as num?)?.toDouble(),
        children: children,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (mainAxisAlignment != null)
      'mainAxisAlignment': mainAxisToString(mainAxisAlignment!),
    if (crossAxisAlignment != null)
      'crossAxisAlignment': crossAxisToString(crossAxisAlignment!),
    if (mainAxisSize != null)
      'mainAxisSize': _mainAxisSizeToString(mainAxisSize!),
    if (spacing != null) 'spacing': spacing,
  };
}

List<Widget> _withSpacing(List<Widget> children, double spacing) {
  if (children.isEmpty) return children;
  final result = <Widget>[];
  for (var i = 0; i < children.length; i++) {
    result.add(children[i]);
    if (i != children.length - 1) result.add(SizedBox(height: spacing));
  }
  return result;
}

MainAxisSize? _stringToMainAxisSize(dynamic s) {
  switch (s) {
    case 'min':
      return MainAxisSize.min;
    case 'max':
      return MainAxisSize.max;
    default:
      return null;
  }
}

String _mainAxisSizeToString(MainAxisSize v) {
  switch (v) {
    case MainAxisSize.min:
      return 'min';
    case MainAxisSize.max:
      return 'max';
  }
}
