import 'package:flutter/material.dart';
import '../base_ds.dart';

class ExpandedDS extends BaseDS<Widget> {
  ExpandedDS({this.flex = 1, required this.child});
  final int flex;
  final Widget child;

  @override
  String get type => 'expanded';

  @override
  Widget build() => Expanded(flex: flex, child: child);

  factory ExpandedDS.fromJson(Map<String, dynamic> json, Widget child) =>
      ExpandedDS(flex: (json['flex'] as int?) ?? 1, child: child);

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'flex': flex,
      };
}

