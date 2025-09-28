import 'package:flutter/material.dart';
import '../base_ds.dart';

class FlexibleDS extends BaseDS<Widget> {
  FlexibleDS({this.flex = 1, this.fit = FlexFit.loose, required this.child});
  final int flex;
  final FlexFit fit;
  final Widget child;

  @override
  String get type => 'flexible';

  @override
  Widget build() => Flexible(flex: flex, fit: fit, child: child);

  factory FlexibleDS.fromJson(Map<String, dynamic> json, Widget child) =>
      FlexibleDS(
        flex: (json['flex'] as int?) ?? 1,
        fit: _fitFromString(json['fit']) ?? FlexFit.loose,
        child: child,
      );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'flex': flex,
    'fit': _fitToString(fit),
  };
}

FlexFit? _fitFromString(dynamic s) {
  switch (s) {
    case 'tight':
      return FlexFit.tight;
    case 'loose':
      return FlexFit.loose;
    default:
      return null;
  }
}

String _fitToString(FlexFit f) {
  switch (f) {
    case FlexFit.tight:
      return 'tight';
    case FlexFit.loose:
      return 'loose';
  }
}
