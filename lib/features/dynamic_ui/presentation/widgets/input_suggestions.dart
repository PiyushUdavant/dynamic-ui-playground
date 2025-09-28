import 'package:flutter/material.dart';

class InputSuggestions extends StatelessWidget {
  const InputSuggestions({
    super.key,
    required this.onSelected,
    required this.suggestions,
  });

  final ValueChanged<String> onSelected;
  final List<String> suggestions;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: suggestions
            .map(
              (e) => ActionChip(
                label: Text(e, overflow: TextOverflow.ellipsis),
                onPressed: () => onSelected(e),
              ),
            )
            .toList(),
      ),
    );
  }
}
