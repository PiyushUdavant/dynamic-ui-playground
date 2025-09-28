import 'package:flutter/material.dart';
import '../base_ds.dart';

class SizedBoxDS extends BaseDS<SizedBox> {
  SizedBoxDS({this.width, this.height, this.child});
  final double? width;
  final double? height;
  final Widget? child;

  @override
  String get type => 'sizedBox';

  @override
  SizedBox build() => SizedBox(width: width, height: height, child: child);

  factory SizedBoxDS.fromJson(Map<String, dynamic> json, Widget? child) =>
      SizedBoxDS(width: (json['width'] as num?)?.toDouble(), height: (json['height'] as num?)?.toDouble(), child: child);

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (width != null) 'width': width,
        if (height != null) 'height': height,
      };
}

