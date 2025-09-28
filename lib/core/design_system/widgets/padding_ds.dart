import 'package:flutter/material.dart';
import '../base_ds.dart';
import '../../utils/common_props.dart';

class PaddingDS extends BaseDS<Widget> {
  const PaddingDS({required this.padding, required this.child});
  final EdgeInsets padding;
  final Widget child;

  @override
  String get type => 'padding';

  @override
  Widget build() => Padding(padding: padding, child: child);

  factory PaddingDS.fromJson(Map<String, dynamic> json, Widget child) {
    final p = CommonProps.parsePadding(json['padding']) ?? EdgeInsets.zero;
    return PaddingDS(padding: p, child: child);
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'padding': CommonProps.paddingToJson(padding),
      };
}

