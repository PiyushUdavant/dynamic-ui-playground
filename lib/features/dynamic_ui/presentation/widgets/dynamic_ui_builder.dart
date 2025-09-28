import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/design_system/widgets_ds.dart';

/// Builds a widget tree recursively from a JSON node using DS widgets.
class DynamicUiBuilder extends StatelessWidget {
  const DynamicUiBuilder({super.key, required this.json});

  final Map<String, dynamic> json;

  @override
  Widget build(BuildContext context) {
    return _buildFromJson(json).animate().fadeIn(
      duration: const Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }
}

Widget _buildFromJson(Map<String, dynamic> node) {
  final type = (node['type'] as String?)?.toLowerCase() ?? 'unknown';
  final props = (node['props'] as Map?)?.cast<String, Object?>() ?? const {};
  final childrenJson = (node['children'] as List?)?.cast<dynamic>() ?? const [];

  List<Widget> childrenWidgets = childrenJson
      .whereType<Map>()
      .map((c) => _buildFromJson(c.cast<String, Object?>()))
      .toList();

  // Optional wrapper handling for flex and scroll
  Widget wrapIfNeeded(String t, Map<String, dynamic> props, List<Widget> kids) {
    // Single-child wrappers: expanded, flexible, scroll expect at most one child.
    if (t == 'expanded') {
      final child = kids.isNotEmpty ? kids.first : const SizedBox.shrink();
      return ExpandedDS.fromJson(props, child).build();
    }
    if (t == 'flexible') {
      final child = kids.isNotEmpty ? kids.first : const SizedBox.shrink();
      return FlexibleDS.fromJson(props, child).build();
    }
    if (t == 'scroll') {
      final child = kids.isNotEmpty ? kids.first : const SizedBox.shrink();
      return ScrollDS.fromJson(props, child).build();
    }
    if (t == 'padding') {
      final child = kids.isNotEmpty ? kids.first : const SizedBox.shrink();
      return PaddingDS.fromJson(props, child).build();
    }
    return const SizedBox.shrink();
  }

  switch (type) {
    case 'row':
      return RowDS.fromJson(props, childrenWidgets).build();
    case 'column':
      return ColumnDS.fromJson(props, childrenWidgets).build();
    case 'expanded':
    case 'flexible':
    case 'scroll':
    case 'padding':
      return wrapIfNeeded(type, props, childrenWidgets);
    case 'container':
      final Widget? child = childrenWidgets.isNotEmpty
          ? childrenWidgets.first
          : null;
      return ContainerDS.fromJson(props, child).build();
    case 'sizedbox':
    case 'sized_box':
      final Widget? child = childrenWidgets.isNotEmpty
          ? childrenWidgets.first
          : null;
      return SizedBoxDS.fromJson(props, child).build();
    case 'text':
      return TextDS.fromJson(props).build();
    case 'icon':
      return IconDS.fromJson(props).build();
    case 'image':
      return ImageDS.fromJson(props).build();
    case 'checkbox':
      return CheckboxDS.fromJson(props).build();
    case 'elevatedbutton':
    case 'elevated_button':
      return ElevatedButtonDS.fromJson(props).build();
    case 'textfield':
    case 'text_field':
      return TextFieldDS.fromJson(props).build();
    default:
      return const SizedBox.shrink();
  }
}
