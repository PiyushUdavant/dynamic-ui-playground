import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/mocks/ui_json_mocks.dart';
import '../view_model/dynamic_ui_view_model.dart';
import 'input_bottom_sheet.dart';

class NewInputFab extends ConsumerWidget {
  const NewInputFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = DynamicUiViewModel.instance..attach(ref);

    return FloatingActionButton(
      onPressed: () async {
        final currentJson = vm.getCurrentJson();
        final updateSuggestions = getUpdateSuggestionsForJson(currentJson);

        final width = MediaQuery.sizeOf(context).width;
        final isWide = width >= 900;

        Future<dynamic> openInput() {
          if (isWide) {
            return showDialog(
              context: context,
              builder: (_) => AlertDialog(
                contentPadding: const EdgeInsets.all(24),
                title: const Text('New input'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ],
                content: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: DynamicInputBottomSheet(
                    createSuggestions: kDefaultCreateSuggestions,
                    updateSuggestions: updateSuggestions,
                  ),
                ),
              ),
            );
          }
          return showModalBottomSheet(
            context: context,
            useSafeArea: true,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (_) => DynamicInputBottomSheet(
              createSuggestions: kDefaultCreateSuggestions,
              updateSuggestions: updateSuggestions,
            ),
          );
        }

        final result = await openInput();
        if (result is Map) {
          final mode = result['mode'] as String? ?? 'create';
          final prompt = (result['prompt'] as String?)?.trim() ?? '';
          if (prompt.isNotEmpty) {
            try {
              await vm.processInput(mode: mode, prompt: prompt);
            } catch (e) {
              if (context.mounted) {
                final action = mode == 'create' ? 'create' : 'update';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to $action UI: $e')),
                );
              }
            }
          }
        }
      },
      tooltip: 'New input',
      child: const Icon(Icons.add_comment),
    );
  }
}
