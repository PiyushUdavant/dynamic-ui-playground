import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Contrast variants removed; using seed-based theme only

class AppThemeState {
  final ThemeMode mode;
  final String bodyFont;
  final String displayFont;
  final String baseColor; // hex ARGB string used as seed

  const AppThemeState({
    required this.mode,
    required this.bodyFont,
    required this.displayFont,
    required this.baseColor,
  });

  AppThemeState copyWith({
    ThemeMode? mode,
    String? bodyFont,
    String? displayFont,
    String? baseColor,
  }) => AppThemeState(
        mode: mode ?? this.mode,
        bodyFont: bodyFont ?? this.bodyFont,
        displayFont: displayFont ?? this.displayFont,
        baseColor: baseColor ?? this.baseColor,
      );
}

class AppThemeNotifier extends Notifier<AppThemeState> {
  @override
  AppThemeState build() {
    // Default from system light/dark, with normal contrast & baseline fonts
    final platformBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final defaultMode = platformBrightness == Brightness.light ? ThemeMode.light : ThemeMode.dark;
    return AppThemeState(
      mode: defaultMode,
      bodyFont: 'Albert Sans',
      displayFont: 'AR One Sans',
      baseColor: '#FFFFC107',
    );
  }

  void toggleMode() {
    state = state.copyWith(
      mode: state.mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

  // contrast removed

  void setFonts({required String bodyFont, required String displayFont}) {
    state = state.copyWith(bodyFont: bodyFont, displayFont: displayFont);
  }

  /// Placeholder for AI-driven application: choose a fun pre-baked combo.
  /// For now we just rotate through a couple of font pairs and toggle mode/contrast.
  void applyEasterEggShuffle() {
    // Rotate mode
    toggleMode();
    // Rotate fonts from a larger curated list
    final candidates = <(String body, String display)>[
      ('Inter', 'Bebas Neue'),
      ('Nunito', 'Playfair Display'),
      ('Open Sans', 'Oswald'),
      ('Roboto', 'Playfair Display'),
      ('Poppins', 'Bebas Neue'),
      ('Lato', 'Oswald'),
      ('Source Sans 3', 'Merriweather'),
      ('Montserrat', 'Abril Fatface'),
    ];
    final idx = (candidates.indexWhere(
              (e) => e.$1 == state.bodyFont && e.$2 == state.displayFont,
            ) + 1) %
        candidates.length;
    final next = candidates[idx];
    setFonts(bodyFont: next.$1, displayFont: next.$2);
  }

  /// Apply a theme spec map returned by the AI.
  /// Supports both the new seed-based schema and the legacy schema with a colors map.
  void applyThemeSpec(Map<String, dynamic> spec) {
    final modeStr = (spec['mode'] as String?)?.toLowerCase();
    final body = (spec['bodyFont'] as String?)?.trim();
    final display = (spec['displayFont'] as String?)?.trim();

    // Prefer explicit baseColor; otherwise derive from legacy colors.primary/inversePrimary
    String? base = (spec['baseColor'] as String?)?.trim();
    final colors = spec['colors'];
    if (base == null && colors is Map) {
      final cmap = colors.cast<String, dynamic>();
      base = (cmap['primary'] as String?) ?? (cmap['inversePrimary'] as String?);
      base = base?.trim();
    }

    // Normalize to #AARRGGBB
    String normalizeHex(String hex) {
      final cleaned = hex.replaceFirst('#', '');
      if (cleaned.length == 8) return '#$cleaned';
      if (cleaned.length == 6) return '#FF$cleaned';
      // Fallback to default seed if unexpected
      return state.baseColor;
    }

    ThemeMode? mode;
    if (modeStr == 'light') mode = ThemeMode.light;
    if (modeStr == 'dark') mode = ThemeMode.dark;

    state = state.copyWith(
      mode: mode ?? state.mode,
      bodyFont: body ?? state.bodyFont,
      displayFont: display ?? state.displayFont,
      baseColor: base != null ? normalizeHex(base) : state.baseColor,
    );
  }

  /// Generate a theme from prompt via AiService and apply it.
  Future<void> applyThemeFromPrompt({
    required String prompt,
    required dynamic ai, // AiService but avoid import cycle here
  }) async {
    try {
      final Map<String, dynamic> spec = await ai.generateThemeFromText(prompt: prompt);
      applyThemeSpec(spec);
    } catch (_) {
      // Silently ignore; UI can surface error
    }
  }
}

final appThemeProvider = NotifierProvider<AppThemeNotifier, AppThemeState>(
  AppThemeNotifier.new,
);

/// Controls a simple full-screen loading overlay during async theme ops.
final themeLoadingProvider = StateProvider<bool>((ref) => false);
