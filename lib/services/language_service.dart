import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  late SharedPreferences _prefs;
  String _currentLanguage = 'auto';
  Map<String, String> _savedLanguages = {};

  static const Map<String, String> supportedLanguages = {
    'auto': 'تلقائي',
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'de': 'Deutsch',
    'es': 'Español', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
    'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'hi': 'हिन्दी',
    'tr': 'Türkçe', 'fa': 'فارسی', 'ur': 'اردو', 'nl': 'Nederlands',
    'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk', 'fi': 'Suomi',
    'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย', 'vi': 'Tiếng Việt',
    'ms': 'Bahasa Melayu', 'id': 'Bahasa Indonesia', 'tl': 'Filipino',
    'cs': 'Čeština', 'hu': 'Magyar', 'ro': 'Română', 'sk': 'Slovenčina',
    'hr': 'Hrvatski', 'sr': 'Српски', 'bg': 'Български', 'uk': 'Українська',
    'ka': 'ქართული', 'hy': 'Հայերեն', 'az': 'Azərbaycan', 'kk': 'Қазақ',
    'uz': "O'zbek", 'mn': 'Монгол', 'ne': 'नेपाली', 'si': 'සිංහල',
    'km': 'ភាសាខ្មែរ', 'lo': 'ລາວ', 'my': 'မြန်မာဘာသာ',
  };

  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _currentLanguage = _prefs.getString('current_language') ?? 'auto';
      String savedLanguagesJson = _prefs.getString('saved_languages') ?? '{}';
      _savedLanguages = Map<String, String>.from(jsonDecode(savedLanguagesJson));
      notifyListeners();
    } catch (e) {
      print('Error initializing LanguageService: $e');
      _currentLanguage = 'auto';
      _savedLanguages = {};
    }
  }

  String getDeviceLanguage() {
    try {
      return window.locale.languageCode;
    } catch (e) {
      return 'ar';
    }
  }

  String get currentLanguage => _currentLanguage;

  Future<void> setCurrentLanguage(String language) async {
    _currentLanguage = language;
    await _prefs.setString('current_language', language);
    notifyListeners();
  }

  Future<void> saveLanguageForScreen(String screenName, String language) async {
    _savedLanguages[screenName] = language;
    await _prefs.setString('saved_languages', jsonEncode(_savedLanguages));
    notifyListeners();
  }

  String getLanguageForScreen(String screenName) {
    return _savedLanguages[screenName] ?? 'auto';
  }

  String getLanguageName(String code) {
    return supportedLanguages[code] ?? code.toUpperCase();
  }

  List<String> getLanguageCodes() {
    return supportedLanguages.keys.toList();
  }
}
