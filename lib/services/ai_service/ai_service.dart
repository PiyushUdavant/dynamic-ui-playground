abstract class AiService {
  /// Create an initial UI JSON from a natural language text description.
  Future<Map<String, dynamic>> createUiFromText({
    required String prompt,
  });

  /// Update an existing UI JSON given a natural language text instruction.
  Future<Map<String, dynamic>> updateUiFromText({
    required String prompt,
    required Map<String, dynamic> currentJson,
  });

  /// Generate an app theme specification from a natural language description.
  /// The returned map should include:
  /// { "mode": "light|dark", "contrast": "normal|medium|high", "bodyFont": String, "displayFont": String }
  Future<Map<String, dynamic>> generateThemeFromText({
    required String prompt,
  });
}
