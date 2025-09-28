import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/ai_service/ai_service_provider.dart';
import '../../presentation/view_model/dynamic_ui_view_model.dart';
import '../widgets/dynamic_ui_builder.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/new_input_fab.dart';
import '../../../easter_egg/domain/providers/app_theme_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = DynamicUiViewModel.instance..attach(ref);
    final asyncJson = vm.watchJson();

    final isLoading = ref.watch(themeLoadingProvider);

    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= 1000;

    Widget buildCentered(Widget child) {
      if (!isWide) return child;
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: child,
          ),
        ),
      );
    }

    final bodyWidget = asyncJson.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) {
        final fallback = vm.lastValidOrDefault;
        final content = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Load error, showing last saved UI',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Expanded(child: DynamicUiBuilder(json: fallback)),
          ],
        );
        return buildCentered(content);
      },
      data: (json) {
        final content = Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom + 32,
          ),
          child: DynamicUiBuilder(json: json),
        );
        return buildCentered(content);
      },
    );

    Future<void> triggerRandomTheme() async {
      final ai = ref.read(aiServiceProvider);
      ref.read(themeLoadingProvider.notifier).state = true;
      try {
        await ref
            .read(appThemeProvider.notifier)
            .applyThemeFromPrompt(
              prompt:
                  'Generate a random cohesive app theme with mode, baseColor, bodyFont and displayFont.',
              ai: ai,
            );
      } finally {
        ref.read(themeLoadingProvider.notifier).state = false;
      }
    }

    final titleWidget = GestureDetector(
      onLongPress: triggerRandomTheme,
      child: Text(
        'Dynamic UI',
        style: Theme.of(context).textTheme.titleMedium,
        textAlign: TextAlign.center,
      ),
    );

    return Stack(
      children: [
        Scaffold(
          appBar: isWide
              ? null
              : AppBar(
                  title: titleWidget,
                  centerTitle: false,
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  actions: const [AppBarActions()],
                ),
          body: isWide
              ? Row(
                  children: [
                    Container(
                      width: 88,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: SafeArea(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 16,
                              ),
                              child: titleWidget,
                            ),
                            const Divider(height: 1),
                            const SizedBox(height: 8),
                            const AppBarActions(axis: Axis.vertical),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: bodyWidget),
                  ],
                )
              : bodyWidget,
          floatingActionButton: const NewInputFab(),
        ),
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
