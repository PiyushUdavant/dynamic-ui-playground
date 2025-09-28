import 'dart:convert';

import '../domain/models/saved_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SavedUiRepository {
  Future<SavedUi> save({
    required String name,
    required Map<String, dynamic> json,
  });
  Future<List<SavedUi>> listAll();
  Future<SavedUi?> getById(String id);
  Future<void> deleteById(String id);
  Future<void> clearAll();
  Future<void> rename({required String id, required String name});
}

class InMemorySavedUiRepository implements SavedUiRepository {
  final List<SavedUi> _items = [];

  // Deep copy helper to avoid aliasing
  Map<String, dynamic> _deepCopy(Map<String, dynamic> m) =>
      jsonDecode(jsonEncode(m)) as Map<String, dynamic>;

  @override
  Future<SavedUi> save({
    required String name,
    required Map<String, dynamic> json,
  }) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = SavedUi(
      id: id,
      name: name.isEmpty ? 'UI $id' : name,
      json: _deepCopy(json),
      createdAt: DateTime.now(),
    );
    _items.insert(0, item);
    return item;
  }

  @override
  Future<List<SavedUi>> listAll() async => List.unmodifiable(_items);

  @override
  Future<SavedUi?> getById(String id) async =>
      _items.firstWhere((e) => e.id == id);

  @override
  Future<void> deleteById(String id) async {
    _items.removeWhere((e) => e.id == id);
  }

  @override
  Future<void> clearAll() async {
    _items.clear();
  }

  @override
  Future<void> rename({required String id, required String name}) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(name: name);
    }
  }
}

class SharedPreferencesSavedUiRepository implements SavedUiRepository {
  static const String _storageKey = 'saved_uis';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<SavedUi>> _loadAll() async {
    final prefs = await _prefs;
    final list = prefs.getStringList(_storageKey) ?? const [];
    return list
        .map((s) {
          try {
            return SavedUi.fromJsonString(s);
          } catch (_) {
            return null;
          }
        })
        .whereType<SavedUi>()
        .toList(growable: true);
  }

  Future<void> _persistAll(List<SavedUi> items) async {
    final prefs = await _prefs;
    final list = items.map((e) => e.toJsonString()).toList(growable: false);
    await prefs.setStringList(_storageKey, list);
  }

  Map<String, dynamic> _deepCopy(Map<String, dynamic> m) =>
      jsonDecode(jsonEncode(m)) as Map<String, dynamic>;

  @override
  Future<SavedUi> save({required String name, required Map<String, dynamic> json}) async {
    final items = await _loadAll();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = SavedUi(
      id: id,
      name: name.isEmpty ? 'UI $id' : name,
      json: _deepCopy(json),
      createdAt: DateTime.now(),
    );
    items.insert(0, item);
    await _persistAll(items);
    return item;
  }

  @override
  Future<List<SavedUi>> listAll() async => await _loadAll();

  @override
  Future<SavedUi?> getById(String id) async {
    final items = await _loadAll();
    try {
      return items.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteById(String id) async {
    final items = await _loadAll();
    items.removeWhere((e) => e.id == id);
    await _persistAll(items);
  }

  @override
  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_storageKey);
  }

  @override
  Future<void> rename({required String id, required String name}) async {
    final items = await _loadAll();
    final idx = items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      items[idx] = items[idx].copyWith(name: name);
      await _persistAll(items);
    }
  }
}
