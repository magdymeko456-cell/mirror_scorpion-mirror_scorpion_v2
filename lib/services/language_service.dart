import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  String _deviceLang = 'ar';
  final Map<String, String> _screenLangs = {};

  String getDeviceLanguage() => _deviceLang;

  final Map<String, String> _allLanguages = {
    'auto': 'تحديد تلقائي', 'ar': 'العربية', 'en': 'English', 'fr': 'Français',
    'de': 'Deutsch', 'es': 'Español', 'it': 'Italiano', 'pt': 'Português',
    'ru': 'Русский', 'zh': '中文', 'ja': '日本語', 'ko': '한국어',
    'hi': 'हिन्दी', 'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی',
    'nl': 'Nederlands', 'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk',
    'no': 'Norsk', 'fi': 'Suomi', 'cs': 'Čeština', 'ro': 'Română',
    'hu': 'Magyar', 'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย',
    'vi': 'Tiếng Việt', 'ms': 'Bahasa Melayu', 'id': 'Bahasa Indonesia',
    'tl': 'Filipino', 'bn': 'বাংলা', 'ta': 'தமிழ்', 'te': 'తెలుగు',
    'mr': 'मराठी', 'gu': 'ગુજરાતી', 'kn': 'ಕನ್ನಡ', 'ml': 'മലയാളം',
    'si': 'සිංහල', 'ne': 'नेपाली', 'km': 'ខ្មែរ', 'my': 'မြန်မာ',
    'ka': 'ქართული', 'hy': 'Հայերեն', 'az': 'Azərbaycan', 'kk': 'Қазақ',
    'uz': 'O\'zbek', 'uk': 'Українська', 'be': 'Беларуская', 'sq': 'Shqip',
    'bs': 'Bosanski', 'hr': 'Hrvatski', 'sr': 'Српски', 'mk': 'Македонски',
    'bg': 'Български', 'lt': 'Lietuvių', 'lv': 'Latviešu', 'et': 'Eesti',
    'is': 'Íslenska', 'ga': 'Gaeilge', 'cy': 'Cymraeg', 'mt': 'Malti',
    'sw': 'Kiswahili', 'ha': 'Hausa', 'yo': 'Yorùbá', 'ig': 'Igbo',
    'zu': 'isiZulu', 'xh': 'isiXhosa', 'af': 'Afrikaans', 'am': 'አማርኛ',
    'sd': 'سنڌي', 'ps': 'پښتو', 'ku': 'Kurdî', 'ckb': 'کوردی',
    'lo': 'ລາວ', 'bo': 'བོད་སྐད་', 'mn': 'Монгол', 'ug': 'Uyghurche',
  };

  final Map<String, bool> _downloadedLanguages = {};

  Map<String, bool> get downloadedLanguages => Map.unmodifiable(_downloadedLanguages);

  Future initialize() async {
    final p = await SharedPreferences.getInstance();
    _deviceLang = p.getString('device_language') ?? 'ar';
  }

  List<String> getLanguageCodes() => _allLanguages.keys.toList();
  String getLanguageName(String code) => _allLanguages[code] ?? code;

  String getLanguageForScreen(String screen) {
    return _screenLangs[screen] ?? 'auto';
  }

  Future saveLanguageForScreen(String screen, String lang) async {
    _screenLangs[screen] = lang;
    final p = await SharedPreferences.getInstance();
    await p.setString('lang_$screen', lang);
    notifyListeners();
  }

  Future downloadLanguage(String lang) async {
    _downloadedLanguages[lang] = true;
    final p = await SharedPreferences.getInstance();
    await p.setStringList('downloaded_langs', _downloadedLanguages.keys.toList());
    notifyListeners();
  }

  Future deleteLanguage(String lang) async {
    _downloadedLanguages.remove(lang);
    final p = await SharedPreferences.getInstance();
    await p.setStringList('downloaded_langs', _downloadedLanguages.keys.toList());
    notifyListeners();
  }
}
