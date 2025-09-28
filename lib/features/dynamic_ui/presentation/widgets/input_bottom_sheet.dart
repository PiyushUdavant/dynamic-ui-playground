import 'package:flutter/material.dart';
import 'input_suggestions.dart';

class DynamicInputBottomSheet extends StatefulWidget {
  const DynamicInputBottomSheet({
    super.key,
    this.createSuggestions = const [],
    this.updateSuggestions = const [],
  });

  final List<String> createSuggestions;
  final List<String> updateSuggestions;

  @override
  State<DynamicInputBottomSheet> createState() =>
      _DynamicInputBottomSheetState();
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.mode, required this.onChanged});
  final String mode; // 'create' or 'update'
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ChoiceChip(
          label: const Text('Create'),
          selected: mode == 'create',
          onSelected: (_) => onChanged('create'),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Update'),
          selected: mode == 'update',
          onSelected: (_) => onChanged('update'),
        ),
      ],
    );
  }
}

class _DynamicInputBottomSheetState extends State<DynamicInputBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  String _mode = 'create';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom + 16;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Manual tab-like toggle
            _ModeToggle(
              onChanged: (m) => setState(() => _mode = m),
              mode: _mode,
            ),
            const SizedBox(height: 8),
            SizedBox(
              child: InputSuggestions(
                suggestions: _mode == 'create'
                    ? widget.createSuggestions
                    : widget.updateSuggestions,
                onSelected: (value) {
                  _controller.text = value;
                  _controller.selection = TextSelection(
                    baseOffset: value.length,
                    extentOffset: value.length,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Type a prompt...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      final text = _controller.text.trim();
                      if (text.isNotEmpty) {
                        final mode = _mode;
                        Navigator.of(
                          context,
                        ).pop({'mode': mode, 'prompt': text});
                      }
                    },
                    child: const Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
