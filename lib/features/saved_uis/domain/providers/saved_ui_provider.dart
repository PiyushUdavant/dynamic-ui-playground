import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/saved_ui_repository.dart';
import '../models/saved_ui.dart';

final savedUiRepositoryProvider = Provider<SavedUiRepository>((ref) {
  // Use SharedPreferences-backed repository for persistence
  return SharedPreferencesSavedUiRepository();
});

class SavedUiListNotifier extends StateNotifier<AsyncValue<List<SavedUi>>> {
  SavedUiListNotifier(this._repo) : super(const AsyncValue.data([]));
  final SavedUiRepository _repo;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final items = await _repo.listAll();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<SavedUi> saveCurrent(String name, Map<String, dynamic> json) async {
    final item = await _repo.save(name: name, json: json);
    await refresh();
    return item;
  }
}

final savedUiListProvider =
    StateNotifierProvider<SavedUiListNotifier, AsyncValue<List<SavedUi>>>((
      ref,
    ) {
      return SavedUiListNotifier(ref.read(savedUiRepositoryProvider));
    });
