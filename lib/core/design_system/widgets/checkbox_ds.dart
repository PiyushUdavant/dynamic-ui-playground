import 'package:flutter/material.dart';
import '../base_ds.dart';

class CheckboxDS extends BaseDS<Widget> {
  const CheckboxDS({required this.value, this.onChanged, this.tristate = false});
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;

  @override
  String get type => 'checkbox';

  @override
  Widget build() => Checkbox(value: value, onChanged: onChanged, tristate: tristate);

  factory CheckboxDS.fromJson(Map<String, dynamic> json) => CheckboxDS(
        value: json['value'] as bool?,
        tristate: json['tristate'] == true,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        if (value != null) 'value': value,
        if (tristate) 'tristate': tristate,
      };
}

