import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/view_model/dynamic_ui_view_model.dart';
import '../../../saved_uis/presentation/screens/saved_uis_screen.dart';

class AppBarActions extends ConsumerWidget {
  const AppBarActions({super.key, this.axis = Axis.horizontal});

  final Axis axis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = DynamicUiViewModel.instance..attach(ref);

    final children = <Widget>[
      IconButton(
        tooltip: 'Saved UIs',
        icon: const Icon(Icons.bookmarks),
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SavedUisScreen()));
        },
      ),
      IconButton(
        tooltip: 'Save UI',
        icon: const Icon(Icons.bookmark_add),
        onPressed: () async {
          final textController = TextEditingController();
          final name = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Save current UI'),
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(
                  labelText: 'Name (optional)',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(ctx).pop(textController.text.trim()),
                  child: const Text('Save'),
                ),
              ],
            ),
          );
          if (name != null) {
            final saved = await vm.saveCurrentUi(name, ref: ref);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Saved "${saved.name}"')),
              );
            }
          }
        },
      ),
      IconButton(
        tooltip: 'Undo',
        icon: const Icon(Icons.undo),
        onPressed: vm.canUndo ? () => vm.undo(ref: ref) : null,
      ),
      IconButton(
        tooltip: 'Redo',
        icon: const Icon(Icons.redo),
        onPressed: vm.canRedo ? () => vm.redo(ref: ref) : null,
      ),
      IconButton(
        tooltip: 'Reset',
        icon: const Icon(Icons.refresh),
        onPressed: () => vm.resetToDefault(ref: ref),
      ),
    ];

    if (axis == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}
