import 'package:dynamic_ui_playground/services/ai_service/ai_service.dart';
import 'package:dynamic_ui_playground/services/ai_service/firebase_ai_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return FirebaseAiService();
});
