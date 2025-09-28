import 'package:flutter/material.dart';
import '../base_ds.dart';
import '../../utils/common_props.dart';

class ContainerDS extends BaseDS<Container> {
  ContainerDS({this.decoration, this.alignment, this.padding, this.child});

  final BoxDecoration? decoration;
  final Alignment? alignment;
  final EdgeInsets? padding;
  final Widget? child;

  @override
  String get type => 'container';

  @override
  Container build() {
    Widget? c = child;
    if (padding != null && c != null) c = Padding(padding: padding!, child: c);
    if (alignment != null && c != null) {
      c = Align(alignment: alignment!, child: c);
    }
    return Container(decoration: decoration, child: c);
  }

  factory ContainerDS.fromJson(Map<String, dynamic> json, Widget? child) {
    // Backward compatibility: if only 'color' exists, wrap into a BoxDecoration
    final BoxDecoration? deco =
        _boxDecorationFromJson(json['decoration']) ??
        (json['color'] != null
            ? BoxDecoration(color: CommonProps.parseColor(json['color']))
            : null);

    return ContainerDS(
      decoration: deco,
      alignment: CommonProps.parseAlignment(json['alignment']),
      padding: CommonProps.parsePadding(json['padding']),
      child: child,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (decoration != null) 'decoration': _boxDecorationToJson(decoration!),
    if (alignment != null)
      'alignment': CommonProps.alignmentToString(alignment),
    if (padding != null) 'padding': CommonProps.paddingToJson(padding),
  };
}

BoxDecoration? _boxDecorationFromJson(dynamic value) {
  if (value is! Map) return null;
  final map = value;
  final color = CommonProps.parseColor(map['color']);
  final radius = _borderRadiusFromJson(map['borderRadius']);
  final border = _borderFromJson(map['border']);
  return BoxDecoration(color: color, borderRadius: radius, border: border);
}

Map<String, dynamic>? _boxDecorationToJson(BoxDecoration? deco) {
  if (deco == null) return null;
  return {
    if (deco.color != null) 'color': CommonProps.colorToHex(deco.color),
    if (deco.border != null) 'border': _borderToJson(deco.border!),
  };
}

BorderRadius? _borderRadiusFromJson(dynamic value) {
  if (value is Map) {
    if (value['all'] != null) {
      final d = (value['all'] as num).toDouble();
      return BorderRadius.circular(d);
    }
  }
  if (value is num) return BorderRadius.circular(value.toDouble());
  return null;
}

Border? _borderFromJson(dynamic value) {
  if (value is! Map) return null;
  final color = CommonProps.parseColor(value['color']);
  final width = (value['width'] as num?)?.toDouble() ?? 1.0;
  if (color == null) return null;
  return Border.all(color: color, width: width);
}

Map<String, dynamic>? _borderToJson(BoxBorder border) {
  if (border is Border) {
    // Assume uniform border for simplicity
    final side = border.top;
    return {'color': CommonProps.colorToHex(side.color), 'width': side.width};
  }
  return null;
}
