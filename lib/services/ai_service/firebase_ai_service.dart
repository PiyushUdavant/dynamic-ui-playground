import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:dynamic_ui_playground/services/ai_service/ai_prompts.dart';
import 'package:dynamic_ui_playground/services/ai_service/ai_service.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:record/record.dart';

/// FirebaseAI-backed implementation that returns JSON-structured UI responses.
class FirebaseAiService extends AiService {
  GenerativeModel? _jsonModel;
  String _currentJsonModelName = 'gemini-2.5-flash';
  final String _fallbackJsonModelName = 'gemini-1.5-flash';

  FirebaseAiService() {
    _ensureInitialized();
  }

  Future<void> _ensureInitialized() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
    _jsonModel = _createUiJsonModel(_currentJsonModelName);
  }

  GenerativeModel _createUiJsonModel(String modelName) {
    // The firebase_ai Schema API does not support recursive schemas at the
    // time of writing. We enforce structure via prompts and request JSON only.
    return FirebaseAI.googleAI().generativeModel(
      model: modelName,
      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );
  }

  Map<String, dynamic> _parseJsonSafely(String raw) {
    // Strip markdown fences and language hints
    var text = raw.replaceAll('```', '');
    text = text.replaceAll(RegExp(r'^json\s*', multiLine: true), '');
    text = text.trim();
    // Fast path
    try {
      return json.decode(text) as Map<String, dynamic>;
    } catch (e) {
      // continue
    }
    // Try to extract the largest JSON object substring
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start >= 0 && end > start) {
      final candidate = text.substring(start, end + 1);
      try {
        return json.decode(candidate) as Map<String, dynamic>;
      } catch (e) {
        // continue
      }
    }
    // Progressive shrink from the end to find a parsable object (limited attempts)
    if (start >= 0) {
      for (
        int i = text.length - 1, attempts = 0;
        i > start && attempts < 10;
        i--, attempts++
      ) {
        if (text[i] == '}' || text[i] == ']') {
          final sub = text.substring(start, i + 1);
          try {
            return json.decode(sub) as Map<String, dynamic>;
          } catch (e) {
            // continue
          }
        }
      }
      // Attempt to balance braces/brackets if response was cut
      final sub = text.substring(start);
      int curlOpen = '{'.allMatches(sub).length;
      int curlClose = '}'.allMatches(sub).length;
      int sqOpen = '['.allMatches(sub).length;
      int sqClose = ']'.allMatches(sub).length;
      var builder = StringBuffer(sub);
      while (sqOpen > sqClose) {
        builder.write(']');
        sqClose++;
      }
      while (curlOpen > curlClose) {
        builder.write('}');
        curlClose++;
      }
      final balanced = builder.toString();
      try {
        return json.decode(balanced) as Map<String, dynamic>;
      } catch (e) {
        // continue to final
      }
    }
    throw FormatException('Could not parse JSON response');
  }

  Future<Map<String, dynamic>> _generateJsonFromParts(List<Part> parts) async {
    if (_jsonModel == null) {
      await _ensureInitialized();
    }

    try {
      final res = await _jsonModel!.generateContent([Content.multi(parts)]);
      final String? text = res.text;
      if (text == null || text.isEmpty) {
        throw Exception('Empty JSON response from AI');
      }
      return _parseJsonSafely(text);
    } on FirebaseAIException catch (e) {
      log('FirebaseAIException: ${e.message}', error: e);
      if (_currentJsonModelName != _fallbackJsonModelName) {
        _currentJsonModelName = _fallbackJsonModelName;
        _jsonModel = _createUiJsonModel(_currentJsonModelName);
        final res = await _jsonModel!.generateContent([Content.multi(parts)]);
        final text = res.text;
        if (text == null || text.isEmpty) {
          throw Exception('Empty JSON response from AI (fallback)');
        }
        return _parseJsonSafely(text);
      }
      rethrow;
    } catch (e) {
      log('Exception: $e', error: e);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createUiFromText({
    required String prompt,
  }) async {
    final fullPrompt = AiPrompts.initialUiPrompt(prompt: prompt);
    return _generateJsonFromParts([TextPart(fullPrompt)]);
  }

  @override
  Future<Map<String, dynamic>> updateUiFromText({
    required String prompt,
    required Map<String, dynamic> currentJson,
  }) async {
    final fullPrompt = AiPrompts.updateUiPrompt(
      instruction: prompt,
      currentJson: currentJson,
    );
    return _generateJsonFromParts([TextPart(fullPrompt)]);
  }


  @override
  Future<Map<String, dynamic>> generateThemeFromText({
    required String prompt,
  }) async {
    final full = AiPrompts.themeFromTextPrompt(description: prompt);
    return _generateJsonFromParts([TextPart(full)]);
  }
}
