import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dynamic_ui_playground/services/ai_service/ai_service_provider.dart';
import 'package:dynamic_ui_playground/services/ai_service/ai_service.dart';
import '../../domain/providers/ui_json_provider.dart';
import '../../domain/mocks/ui_json_mocks.dart';
import '../../../saved_uis/domain/providers/saved_ui_provider.dart';
import '../../../saved_uis/domain/models/saved_ui.dart';

/// DynamicUiViewModel
///
/// A lightweight singleton that centralizes all interactions between UI widgets
/// and the underlying Riverpod providers that manage Dynamic UI JSON, AI flows,
/// history (undo/redo), and saved UI operations.
///
/// Why a singleton? The app uses a single access point from widgets rather than
/// exposing Riverpod providers everywhere. Widgets call methods here (e.g.,
/// processInput, applyTextPrompt), and this ViewModel talks to providers
/// internally, keeping UI code simpler and consistent.
///
/// Responsibilities
/// - Hold a reference to the latest WidgetRef used by the UI
/// - Expose read/watch helpers for the current UI JSON
/// - Manage history stacks for undo/redo with a configurable cap
/// - Orchestrate AI create/update flows (text and audio)
/// - Save and reset UI JSON via domain providers
///
/// Threading/async: All async methods return Futures that complete when the
/// corresponding provider updates are applied or an error is thrown. Errors are
/// intentionally rethrown to let the caller surface them in the UI (SnackBars,
/// dialogs, etc.).
class DynamicUiViewModel {
  DynamicUiViewModel._internal();

  /// Global instance used across the app.
  static final DynamicUiViewModel instance = DynamicUiViewModel._internal();

  /// Last attached WidgetRef from a widget using this ViewModel.
  ///
  /// Many methods accept an optional [ref] to override this, but in normal
  /// usage widgets call [attach] once (e.g., in build) and then rely on this
  /// stored reference.
  WidgetRef? _ref;

  /// Cache of the last known valid UI JSON produced/observed.
  ///
  /// Used as a fallback when the provider is loading or when no ref is
  /// currently attached.
  Map<String, dynamic>? _lastValid;

  // History stacks for undo/redo
  /// Stack of past UI JSON snapshots used by [undo]. New states are pushed
  /// when [applyNewJson] is called with a JSON different from the current.
  final List<Map<String, dynamic>> _past = [];

  /// Stack of future UI JSON snapshots used by [redo]. Cleared whenever a new
  /// state is applied via [applyNewJson].
  final List<Map<String, dynamic>> _future = [];

  /// Maximum number of snapshots kept in [_past]. Defaults to 50.
  int _maxHistory = 50;

  /// Attach a [WidgetRef] so this ViewModel can read/watch providers.
  ///
  /// Typically called by a root screen or a widget that owns this ViewModel
  /// access. You can pass a different [ref] to individual methods to temporarily
  /// override this attachment when needed.
  void attach(WidgetRef ref) {
    _ref = ref;
  }

  /// Configure the history size cap used for undo/redo.
  ///
  /// If the new [value] is smaller than the current amount of history, the
  /// oldest snapshots are discarded until the size fits the cap. Values <= 0
  /// are ignored.
  set maxHistory(int value) {
    if (value <= 0) return;
    _maxHistory = value;
    while (_past.length > _maxHistory) {
      _past.removeAt(0);
    }
  }

  /// Whether there are past states available to undo.
  bool get canUndo => _past.isNotEmpty;

  /// Whether there are future states available to redo.
  bool get canRedo => _future.isNotEmpty;

  /// Watch the async UI JSON.
  ///
  /// Use from a ConsumerWidget/ConsumerState to rebuild on changes.
  /// Keeps [_lastValid] in sync when new data arrives. If no [WidgetRef] is
  /// currently attached, returns an immediate AsyncValue with the default JSON
  /// to avoid null handling in the UI.
  AsyncValue<Map<String, dynamic>> watchJson() {
    final ref = _ref;
    if (ref == null) {
      return const AsyncValue.data(kDefaultDynamicUiJson);
    }

    final value = ref.watch(dynamicUiJsonProvider);
    // Update last valid if data
    value.whenData((data) => _lastValid = data);
    return value;
  }

  /// The last valid JSON or the default JSON when none has been established.
  Map<String, dynamic> get lastValidOrDefault =>
      _lastValid ?? kDefaultDynamicUiJson;

  /// Read the current UI JSON from the provider if possible.
  ///
  /// Returns the provider's current value when available, otherwise falls back
  /// to [lastValidOrDefault]. This helper keeps provider access contained within
  /// the ViewModel. You may pass an override [ref] if needed.
  Map<String, dynamic> getCurrentJson({WidgetRef? ref}) {
    final useRef = ref ?? _ref;
    if (useRef == null) return lastValidOrDefault;
    final current = useRef.read(dynamicUiJsonProvider).value;
    return current ?? lastValidOrDefault;
  }

  /// Save the current UI JSON with the provided [name].
  ///
  /// Returns the created [SavedUi]. Throws [StateError] if no [WidgetRef] is
  /// attached or provided.
  Future<SavedUi> saveCurrentUi(String name, {WidgetRef? ref}) async {
    final useRef = ref ?? _ref;
    if (useRef == null) {
      throw StateError('WidgetRef not attached to ViewModel');
    }
    final currentJson = getCurrentJson(ref: useRef);
    final notifier = useRef.read(savedUiListProvider.notifier);
    final saved = await notifier.saveCurrent(name, currentJson);
    return saved;
  }

  /// Process user input to either create a new UI or update the current one.
  ///
  /// Parameters:
  /// - [mode]: 'create' to generate a fresh UI, any other value implies update.
  /// - [prompt]: The natural-language instruction.
  /// - [voice]: If true, uses audio-based flows; otherwise text-based.
  /// - [ref]: Optional override of the attached [WidgetRef].
  ///
  /// Behavior:
  /// - If a matching mock is found for the [prompt], it is applied immediately.
  /// - Otherwise, dispatches to the appropriate AI flow (text/audio) while
  ///   setting provider loading state and handling errors by restoring the last
  ///   valid JSON before rethrowing.
  Future<void> processInput({
    required String mode,
    required String prompt,
    WidgetRef? ref,
  }) async {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    if (mode == 'create') {
      final json = getCreateMockForPrompt(prompt);
      if (json != null) {
        applyNewJson(json, ref: useRef);
        return;
      }
      await applyCreateText(prompt);
    } else {
      final curr = getCurrentJson(ref: useRef);
      final updated = getUpdateMockForPrompt(prompt, curr);
      if (updated != null) {
        applyNewJson(updated, ref: useRef);
        return;
      }
      await applyTextPrompt(prompt);
    }
  }

  /// Deep copy a JSON map to avoid accidental shared mutations in history.
  Map<String, dynamic> _deepCopy(Map<String, dynamic> m) =>
      json.decode(json.encode(m)) as Map<String, dynamic>;

  /// Deep structural equality for JSON maps via normalized JSON encoding.
  bool _deepEquals(Map<String, dynamic> a, Map<String, dynamic> b) =>
      json.encode(a) == json.encode(b);

  /// Apply a new JSON to the provider while recording history and clearing redo.
  ///
  /// Pushes the current state to [_past], enforces the history cap, clears
  /// [_future], updates [_lastValid], and notifies the provider with [newJson].
  /// No-op if [newJson] is structurally equal to the current state.
  void applyNewJson(Map<String, dynamic> newJson, {WidgetRef? ref}) {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    _ref = useRef; // keep latest valid ref
    final current =
        useRef.read(dynamicUiJsonProvider).value ?? lastValidOrDefault;
    if (_deepEquals(current, newJson)) {
      // No change, don't spam history
      return;
    }
    _past.add(_deepCopy(current));
    while (_past.length > _maxHistory) {
      _past.removeAt(0);
    }
    _future.clear();
    _lastValid = _deepCopy(newJson);
    useRef.read(dynamicUiJsonProvider.notifier).applyJson(newJson);
  }

  /// Undo the last change, if available.
  ///
  /// Moves the current state to [_future] and restores the most recent entry
  /// from [_past]. Does nothing if there is no history.
  void undo({WidgetRef? ref}) {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    _ref = useRef;
    if (_past.isEmpty) return;
    final current =
        useRef.read(dynamicUiJsonProvider).value ?? lastValidOrDefault;
    _future.add(_deepCopy(current));
    final prev = _past.removeLast();
    _lastValid = _deepCopy(prev);
    useRef.read(dynamicUiJsonProvider.notifier).applyJson(prev);
  }

  /// Redo the last undone change, if available.
  ///
  /// Pushes the current state onto [_past] and applies the most recent entry
  /// from [_future]. Does nothing if there is no redo state.
  void redo({WidgetRef? ref}) {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    _ref = useRef;
    if (_future.isEmpty) return;
    final current =
        useRef.read(dynamicUiJsonProvider).value ?? lastValidOrDefault;
    _past.add(_deepCopy(current));
    final next = _future.removeLast();
    _lastValid = _deepCopy(next);
    useRef.read(dynamicUiJsonProvider.notifier).applyJson(next);
  }

  /// Refresh the UI JSON from the source (simulated fetch).
  Future<void> refresh({WidgetRef? ref}) async {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    _ref = useRef;
    await useRef.read(dynamicUiJsonProvider.notifier).refreshFromServer();
  }

  /// Reset the provider back to the default JSON.
  void resetToDefault({WidgetRef? ref}) {
    final useRef = ref ?? _ref;
    if (useRef == null) return;
    _ref = useRef;
    useRef.read(dynamicUiJsonProvider.notifier).resetToDefault();
  }

  /// Lazily read the AI service from the attached [WidgetRef]. May be null
  /// when no ref is attached.
  AiService? get _ai => _ref?.read(aiServiceProvider);

  // CREATE flows
  /// Create a new UI from a text [prompt] via the AI service.
  ///
  /// Sets provider loading state, awaits AI completion, then applies the
  /// generated JSON via [applyNewJson]. On error, restores [lastValidOrDefault]
  /// and rethrows for the caller to handle.
  Future<void> applyCreateText(String prompt) async {
    final ref = _ref;
    final ai = _ai;
    if (ref == null || ai == null) return;
    ref.read(dynamicUiJsonProvider.notifier).setLoading();
    try {
      final created = await ai.createUiFromText(prompt: prompt);
      applyNewJson(created);
    } catch (e) {
      // fallback to last valid and rethrow for UI handling (no history change)
      ref.read(dynamicUiJsonProvider.notifier).applyJson(lastValidOrDefault);
      rethrow;
    }
  }

  // UPDATE flows
  /// Apply a text [prompt] to update the current UI via the AI service.
  ///
  /// Captures the current state, sets loading, awaits the AI update, and then
  /// applies the new JSON. On error, restores the captured state and rethrows.
  Future<void> applyTextPrompt(String prompt) async {
    final ref = _ref;
    final ai = _ai;
    if (ref == null || ai == null) return;
    // set loading
    ref.read(dynamicUiJsonProvider.notifier).setLoading();
    final current = lastValidOrDefault;
    try {
      final updated = await ai.updateUiFromText(
        prompt: prompt,
        currentJson: current,
      );
      applyNewJson(updated);
    } catch (e) {
      // on error, restore last valid and bubble up
      ref.read(dynamicUiJsonProvider.notifier).applyJson(current);
      rethrow;
    }
  }

}

/// Kept for backward-compatibility in case anything references default JSON here.
Map<String, dynamic> get legacyDefaultJson => kDefaultDynamicUiJson;
