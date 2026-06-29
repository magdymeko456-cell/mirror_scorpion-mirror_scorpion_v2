import 'dart:convert';
import 'dart:io';
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
    if (text.trim().isEmpty) return {'language': 'unknown', 'confidence': 0.0};
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': text}),
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        if (data.isNotEmpty) {
          return {'language': data[0]['language'], 'confidence': data[0]['confidence']};
        }
      }
    } catch (_) {}
    return {'language': 'ar', 'confidence': 0.0};
  }

  Future<String> translate(String text, String target, {String? source}) async {
    if (text.trim().isEmpty) return '';

    // إضافة توقيع
    final translated = await _callTranslate(text, target, source: source);
    final signed = '$translated\n\n🦂 ترجمة Mirror Scorpion';
    return signed;
  }

  Future<String> _callTranslate(String text, String target, {String? source}) async {
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
      debugPrint('Translation error: $e');
    }
    return text;
  }

  Future<String> translateWithSignature(String text, String target, {String? source}) async {
    final result = await _callTranslate(text, target, source: source);
    return '$result\n\n🦂 ترجمة Mirror Scorpion';
  }

  Future<String> batchTranslate(List<String> texts, String target, {String? source}) async {
    if (texts.isEmpty) return '';
    final results = <String>[];
    for (final text in texts) {
      final result = await _callTranslate(text, target, source: source);
      results.add(result);
    }
    final joined = results.join('\n---\n');
    return '$joined\n\n🦂 ترجمة Mirror Scorpion';
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

  Future<List<Map<String, dynamic>>> getLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('https://libretranslate.com/languages'),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(utf8.decode(response.bodyBytes)));
      }
    } catch (_) {}
    return [];
  }
}
