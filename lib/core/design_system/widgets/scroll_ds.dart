import 'package:flutter/material.dart';
import '../base_ds.dart';

class ScrollDS extends BaseDS<Widget> {
  const ScrollDS({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  String get type => 'scroll';

  @override
  Widget build() {
    final content = padding != null ? Padding(padding: padding!, child: child) : child;
    return SingleChildScrollView(child: content);
  }

  factory ScrollDS.fromJson(Map<String, dynamic> json, Widget child) => ScrollDS(
        child: child,
        padding: _paddingFromJson(json['padding']),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (padding != null) 'padding': {
          'left': padding!.left,
          'top': padding!.top,
          'right': padding!.right,
          'bottom': padding!.bottom,
        }
      };
}

EdgeInsets? _paddingFromJson(dynamic value) {
  if (value is Map) {
    return EdgeInsets.fromLTRB(
      (value['left'] as num? ?? 0).toDouble(),
      (value['top'] as num? ?? 0).toDouble(),
      (value['right'] as num? ?? 0).toDouble(),
      (value['bottom'] as num? ?? 0).toDouble(),
    );
  }
  return null;
}

