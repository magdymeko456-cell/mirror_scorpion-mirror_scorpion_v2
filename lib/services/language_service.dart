import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  String _deviceLanguage = 'ar';
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _deviceLanguage = _prefs.getString('device_language') ?? 'ar';
  }

  String getDeviceLanguage() => _deviceLanguage;

  String getLanguageForScreen(String screen) {
    return _prefs.getString('lang_$screen') ?? '';
  }

  Future<void> saveLanguageForScreen(String screen, String lang) async {
    await _prefs.setString('lang_$screen', lang);
  }

  List<String> getLanguageCodes() {
    return [
      'ar', 'en', 'fr', 'de', 'es', 'it', 'pt', 'ru', 'zh', 'ja', 'ko',
      'hi', 'tr', 'ur', 'fa', 'nl', 'pl', 'sv', 'da', 'fi', 'el', 'he',
      'th', 'vi', 'ms', 'id', 'tl', 'cs', 'hu', 'ro', 'sk', 'hr', 'sr',
      'bg', 'uk', 'sq', 'hy', 'ka', 'kk', 'uz', 'az'
    ];
  }

  String getLanguageName(String code) {
    final names = {
      'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'de': 'Deutsch',
      'es': 'Español', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
      'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'hi': 'हिन्दी',
      'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی', 'nl': 'Nederlands',
      'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk', 'fi': 'Suomi',
      'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย', 'vi': 'Tiếng Việt',
      'ms': 'Bahasa Melayu', 'id': 'Bahasa Indonesia', 'tl': 'Filipino',
      'cs': 'Čeština', 'hu': 'Magyar', 'ro': 'Română', 'sk': 'Slovenčina',
      'hr': 'Hrvatski', 'sr': 'Српски', 'bg': 'Български', 'uk': 'Українська',
      'sq': 'Shqip', 'hy': 'Հայերեն', 'ka': 'ქართული', 'kk': 'Қазақ',
      'uz': 'Oʻzbek', 'az': 'Azərbaycan',
    };
    return names[code] ?? code;
  }
}
