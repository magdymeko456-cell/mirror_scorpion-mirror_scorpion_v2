import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TranslationService extends ChangeNotifier {
  late SharedPreferences _prefs;
  String _lastSourceLanguage = 'auto';
  String _lastTargetLanguage = 'en';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _lastSourceLanguage = _prefs.getString('last_source_lang') ?? 'auto';
    _lastTargetLanguage = _prefs.getString('last_target_lang') ?? 'en';
    notifyListeners();
  }

  String get lastSourceLanguage => _lastSourceLanguage;
  String get lastTargetLanguage => _lastTargetLanguage;

  Future<void> setLastLanguages(String source, String target) async {
    _lastSourceLanguage = source;
    _lastTargetLanguage = target;
    await _prefs.setString('last_source_lang', source);
    await _prefs.setString('last_target_lang', target);
    notifyListeners();
  }

  Future<Map<String, dynamic>> detectLanguage(String text) async {
    if (text.trim().isEmpty) {
      return {'language': 'unknown', 'confidence': 0.0};
    }
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': text}),
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final list = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        if (list.isNotEmpty) {
          return {'language': list[0]['language'] ?? 'unknown', 'confidence': (list[0]['confidence'] ?? 0.0).toDouble()};
        }
      }
    } catch (e) {
      debugPrint('Detect error: $e');
    }
    return {'language': 'ar', 'confidence': 0.0};
  }

  Future<String> _callTranslate(String text, String target, {String? source}) async {
    if (text.trim().isEmpty) return '';
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': source ?? 'auto',
          'target': target,
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return (data['translatedText'] as String?) ?? text;
      }
    } catch (e) {
      debugPrint('Translate error: $e');
    }
    return text;
  }

  Future<String> translate(String text, String target, {String? source}) async {
    final result = await _callTranslate(text, target, source: source);
    return result;
  }

  Future<bool> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('https://libretranslate.com/languages'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
