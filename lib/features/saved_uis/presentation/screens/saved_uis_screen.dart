import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../dynamic_ui/presentation/view_model/dynamic_ui_view_model.dart';
import '../../domain/providers/saved_ui_provider.dart';
import '../../domain/models/saved_ui.dart';

class SavedUisScreen extends ConsumerStatefulWidget {
  const SavedUisScreen({super.key});

  @override
  ConsumerState<SavedUisScreen> createState() => _SavedUisScreenState();
}

class _SavedUisScreenState extends ConsumerState<SavedUisScreen> {
  @override
  void initState() {
    super.initState();
    // initial load
    Future.microtask(() => ref.read(savedUiListProvider.notifier).refresh());
  }

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(savedUiListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Saved UIs')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(savedUiListProvider.notifier).refresh(),
        child: listAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Failed to load saved UIs',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text('$e', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () =>
                        ref.read(savedUiListProvider.notifier).refresh(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return _EmptyState(
                onCreate: () async {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Use the "Save UI" button on the Home app bar to save your current UI.',
                      ),
                    ),
                  );
                },
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (ctx, i) => _SavedUiCard(item: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmarks_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              'No saved pages yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'When you craft a UI you like, tap the "Save UI" button in the top bar to keep it here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.info_outline),
              label: const Text('How to save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SavedUiCard extends ConsumerWidget {
  const _SavedUiCard({required this.item});
  final SavedUi item;

  int _countNodes(Map<String, dynamic> node) {
    int count = 1;
    final children =
        (node['children'] as List?)?.whereType<Map>().toList() ?? const [];
    for (final c in children) {
      count += _countNodes(c.cast<String, dynamic>());
    }
    return count;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nodes = _countNodes(item.json);
    final vm = DynamicUiViewModel.instance;

    return Card(
      elevation: 1.5,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            item.name.isNotEmpty
                ? item.name.substring(0, 1).toUpperCase()
                : 'U',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(width: 4),
            Text(_formatDate(item.createdAt)),
            const SizedBox(width: 12),
            Icon(
              Icons.account_tree,
              size: 14,
              color: Theme.of(context).hintColor,
            ),
            const SizedBox(width: 4),
            Text('$nodes nodes'),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'load':
                vm.applyNewJson(item.json, ref: ref);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Loaded "${item.name}"')),
                  );
                  Navigator.of(context).maybePop();
                }
                break;
              case 'rename':
                final controller = TextEditingController(text: item.name);
                final newName = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Rename saved UI'),
                    content: TextField(
                      controller: controller,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(null),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(ctx).pop(controller.text.trim()),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
                if (newName != null && newName.isNotEmpty) {
                  await ref
                      .read(savedUiRepositoryProvider)
                      .rename(id: item.id, name: newName);
                  await ref.read(savedUiListProvider.notifier).refresh();
                }
                break;
              case 'delete':
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete saved UI?'),
                    content: Text(
                      'This will remove "${item.name}" permanently.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => Navigator.of(ctx).pop(true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await ref.read(savedUiRepositoryProvider).deleteById(item.id);
                  await ref.read(savedUiListProvider.notifier).refresh();
                }
                break;
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'load',
              child: ListTile(
                leading: Icon(Icons.playlist_add),
                title: Text('Load'),
              ),
            ),
            const PopupMenuItem(
              value: 'rename',
              child: ListTile(leading: Icon(Icons.edit), title: Text('Rename')),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline),
                title: Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
