import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../core/api_config.dart';

/// خدمة الترجمة الحقيقية عبر Google Translate API
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  Future<Map<String, String>> translate({
    required String text,
    required String targetLang,
    String? sourceLang,
  }) async {
    if (text.trim().isEmpty) return {'translated': '', 'detected': targetLang};

    try {
      final url = '${ApiConfig.translateUrl}?key=${ApiConfig.googleApiKey}';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'target': targetLang,
          if (sourceLang != null && sourceLang != 'auto') 'source': sourceLang,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final translated = data['data']['translations'][0]['translatedText'] ?? '';
        final detected = data['data']['translations'][0]['detectedSourceLanguage'] ?? targetLang;
        return {'translated': translated, 'detected': detected};
      } else {
        debugPrint('❌ Google Translate API خطأ: ${response.statusCode}');
        return {'translated': '[خطأ في الترجمة - ${response.statusCode}]', 'detected': targetLang};
      }
    } catch (e) {
      debugPrint('❌ Translation error: $e');
      return {'translated': '[خطأ في الاتصال]', 'detected': targetLang};
    }
  }

  Future<String> detectLanguage(String text) async {
    try {
      final url = '${ApiConfig.translateUrl}?key=${ApiConfig.googleApiKey}';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': text, 'target': 'ar'}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['translations'][0]['detectedSourceLanguage'] ?? 'en';
      }
    } catch (_) {}
    return 'en';
  }

  /// الحصول على قائمة اللغات المدعومة
  Future<List<String>> getSupportedLanguages() async {
    try {
      final url = '${ApiConfig.translateUrl}/languages?key=${ApiConfig.googleApiKey}&target=ar';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final languages = data['data']['languages'] as List;
        return languages.map((l) => l['language'] as String).toList();
      }
    } catch (_) {}
    return [];
  }
}
