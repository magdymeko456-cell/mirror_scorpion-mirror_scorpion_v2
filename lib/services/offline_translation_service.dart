import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineTranslationService extends ChangeNotifier {
  late SharedPreferences _prefs;
  final Map<String, bool> _downloadedLanguages = {};
  final Map<String, double> _downloadProgress = {};
  bool _isInitialized = false;

  static const List<Map<String, String>> _availableLanguages = [
    {'code': 'ar', 'name': 'العربية', 'size': '45 MB'},
    {'code': 'en', 'name': 'English', 'size': '38 MB'},
    {'code': 'fr', 'name': 'Français', 'size': '42 MB'},
    {'code': 'es', 'name': 'Español', 'size': '40 MB'},
    {'code': 'de', 'name': 'Deutsch', 'size': '44 MB'},
    {'code': 'zh', 'name': '中文', 'size': '55 MB'},
    {'code': 'ja', 'name': '日本語', 'size': '52 MB'},
    {'code': 'ko', 'name': '한국어', 'size': '48 MB'},
    {'code': 'ru', 'name': 'Русский', 'size': '47 MB'},
    {'code': 'tr', 'name': 'Türkçe', 'size': '41 MB'},
    {'code': 'ur', 'name': 'اردو', 'size': '39 MB'},
    {'code': 'hi', 'name': 'हिन्दी', 'size': '43 MB'},
    {'code': 'bn', 'name': 'বাংলা', 'size': '43 MB'},
    {'code': 'fa', 'name': 'فارسی', 'size': '38 MB'},
    {'code': 'it', 'name': 'Italiano', 'size': '39 MB'},
    {'code': 'pt', 'name': 'Português', 'size': '40 MB'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'size': '37 MB'},
    {'code': 'ms', 'name': 'Bahasa Melayu', 'size': '36 MB'},
    {'code': 'th', 'name': 'ไทย', 'size': '41 MB'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'size': '39 MB'},
    {'code': 'pl', 'name': 'Polski', 'size': '42 MB'},
    {'code': 'sv', 'name': 'Svenska', 'size': '36 MB'},
    {'code': 'ku', 'name': 'Kurdî', 'size': '34 MB'},
    {'code': 'am', 'name': 'አማርኛ', 'size': '33 MB'},
    {'code': 'sw', 'name': 'Kiswahili', 'size': '31 MB'},
    {'code': 'ha', 'name': 'Hausa', 'size': '30 MB'},
  ];

  // هذا هو getter الـ instance الذي يحتاجه settings_screen.dart
  List<Map<String, String>> get availableLanguages => _availableLanguages;

  bool get isInitialized => _isInitialized;
  Map<String, bool> get downloadedLanguages => Map.unmodifiable(_downloadedLanguages);

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
    final saved = _prefs.getString('offline_languages') ?? '';
    if (saved.isNotEmpty) {
      for (final code in saved.split(',')) {
        if (code.isNotEmpty) _downloadedLanguages[code] = true;
      }
    }
    notifyListeners();
  }

  Future<bool> downloadLanguage(String langCode) async {
    if (_downloadedLanguages[langCode] == true) return true;
    _downloadProgress[langCode] = 0.0;
    notifyListeners();
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 400));
      _downloadProgress[langCode] = i / 10;
      notifyListeners();
    }
    _downloadedLanguages[langCode] = true;
    await _prefs.setString('offline_languages', _downloadedLanguages.keys.join(','));
    _downloadProgress.remove(langCode);
    notifyListeners();
    return true;
  }

  Future<void> removeLanguage(String langCode) async {
    _downloadedLanguages.remove(langCode);
    await _prefs.setString('offline_languages', _downloadedLanguages.keys.join(','));
    notifyListeners();
  }

  Future<String> translate(String text, {String from = 'auto', String to = 'ar'}) async {
    if (text.trim().isEmpty) return '';
    if (_downloadedLanguages[to] == true || _downloadedLanguages[from] == true) {
      await Future.delayed(const Duration(milliseconds: 100));
      return '[أوفلاين] $text (محاكاة: $from → $to)';
    }
    try {
      final resp = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': text, 'source': from == 'auto' ? 'auto' : from, 'target': to, 'format': 'text'}),
      ).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        return (data['translatedText'] as String?) ?? text;
      }
    } catch (_) {}
    return text;
  }

  bool isDownloaded(String langCode) => _downloadedLanguages[langCode] == true;
  double? getProgress(String langCode) => _downloadProgress[langCode];
}
