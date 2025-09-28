import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../base_ds.dart';
import '../../utils/common_props.dart';
import '../ds_helpers.dart';

class TextDS extends BaseDS<Text> {
  TextDS({
    required this.value,
    this.color,
    this.size,
    this.align,
    this.fontFamily,
    this.overflow,
    this.maxLines,
  });
  final String value;
  final Color? color;
  final double? size;
  final TextAlign? align;
  final String? fontFamily;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  String get type => 'text';

  @override
  Text build() => Text(
    value,
    textAlign: align,
    overflow: overflow,
    maxLines: maxLines,
    style: GoogleFonts.getFont(
      fontFamily ?? 'Inter',
      textStyle: TextStyle(color: color, fontSize: size),
    ),
  );

  factory TextDS.fromJson(Map<String, dynamic> json) => TextDS(
    value: (json['value'] ?? '').toString(),
    color: CommonProps.parseColor(json['color']),
    size: (json['size'] as num?)?.toDouble(),
    align: stringToTextAlign(json['align']),
    fontFamily: json['fontFamily'] as String?,
    overflow: stringToTextOverflow(json['overflow']),
    maxLines: json['maxLines'] as int?,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
    if (color != null) 'color': CommonProps.colorToHex(color),
    if (size != null) 'size': size,
    if (align != null) 'align': textAlignToString(align!),
    if (fontFamily != null) 'fontFamily': fontFamily,
    if (overflow != null) 'overflow': overflow!.name,
    if (maxLines != null) 'maxLines': maxLines,
  };
}
