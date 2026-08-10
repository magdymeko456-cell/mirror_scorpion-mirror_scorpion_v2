import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  final Map<String, String> _screenLanguages = {
    'dialogue_from': 'ar',
    'dialogue_to': 'en',
    'text_from': 'ar',
    'text_to': 'en',
  };

  bool get isInitialized => _isInitialized;

  /// لغة جهاز المستخدم (تُستخدم عند فتح التطبيق وفي الشاشات)
  String get deviceLanguageCode {
    final loc = WidgetsBinding.instance.platformDispatcher.locale;
    return loc.languageCode;
  }

  String get deviceLanguageName => getLanguageName(deviceLanguageCode);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _screenLanguages['dialogue_from'] = _prefs.getString('dialogue_from') ?? 'ar';
    _screenLanguages['dialogue_to'] = _prefs.getString('dialogue_to') ?? 'en';
    _screenLanguages['text_from'] = _prefs.getString('text_from') ?? 'ar';
    _screenLanguages['text_to'] = _prefs.getString('text_to') ?? 'en';
    _isInitialized = true;
    notifyListeners();
  }

  /// 100+ لغة مدعومة (تطابق supportedLocales في main.dart)
  List<String> getLanguageCodes() => _langNames.keys.toList();

  String getLanguageName(String code) => _langNames[code] ?? code;

  String getLanguageForScreen(String screenKey) => _screenLanguages[screenKey] ?? 'ar';

  Future<void> saveLanguageForScreen(String screenKey, String langCode) async {
    _screenLanguages[screenKey] = langCode;
    await _prefs.setString(screenKey, langCode);
    notifyListeners();
  }

  String translateOffline(String text, String from, String to) {
    if (text.isEmpty) return '';
    final clean = text.trim().toLowerCase();
    const dictionary = {
      'ar': {
        'hello': 'مرحباً', 'how are you?': 'كيف حالك؟', 'thank you': 'شكراً لك',
        'good morning': 'صباح الخير', 'good night': 'تصبح على خير',
        'yes': 'نعم', 'no': 'لا', 'peace be upon you': 'السلام عليكم',
        'welcome': 'أهلاً وسهلاً',
      },
      'en': {
        'مرحبا': 'Hello', 'مرحباً': 'Hello', 'كيف حالك': 'How are you?',
        'كيف حالك؟': 'How are you?', 'شكرا': 'Thank you', 'شكراً': 'Thank you',
        'صباح الخير': 'Good morning', 'السلام عليكم': 'Peace be upon you',
        'أهلاً وسهلاً': 'Welcome',
      }
    };
    if (dictionary.containsKey(to)) {
      for (final e in dictionary[to]!.entries) {
        if (clean.contains(e.key)) return e.value;
      }
    }
    return '[$to] $text';
  }

  Map<String, dynamic> generateSmartGameChallenge(String lang) {
    if (lang == 'ar') {
      return {
        'question': 'ما هي الكلمة الإنجليزية المقابلة لـ "تطوير البرمجيات"؟',
        'options': ['Software Development', 'Hardware Industry', 'Network Design', 'Data Analysis'],
        'answer': 'Software Development',
        'hint': 'تبدأ بحرف S'
      };
    } else {
      return {
        'question': 'What is the Arabic word for "Artificial Intelligence"?',
        'options': ['الذكاء الاصطناعي', 'الواقع الافتراضي', 'الأمن السيبراني', 'علم البيانات'],
        'answer': 'الذكاء الاصطناعي',
        'hint': 'تبدأ بـ الذكاء...'
      };
    }
  }

  static const Map<String, String> _langNames = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'de': 'Deutsch', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
    'zh': '中文(简体)', 'zh-TW': '中文(繁體)', 'ja': '日本語', 'ko': '한국어',
    'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی', 'hi': 'हिन्दी',
    'bn': 'বাংলা', 'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu',
    'nl': 'Nederlands', 'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk',
    'fi': 'Suomi', 'no': 'Norsk', 'cs': 'Čeština', 'hu': 'Magyar',
    'ro': 'Română', 'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย',
    'vi': 'Tiếng Việt', 'tl': 'Filipino', 'sw': 'Kiswahili',
    'ta': 'தமிழ்', 'te': 'తెలుగు', 'kn': 'ಕನ್ನಡ', 'ml': 'മലയാളം',
    'gu': 'ગુજરાતી', 'mr': 'मराठी', 'pa': 'ਪੰਜਾਬੀ', 'ne': 'नेपाली',
    'si': 'සිංහල', 'km': 'ខ្មែរ', 'my': 'မြန်မာ', 'lo': 'ລາວ',
    'ka': 'ქართული', 'hy': 'հայերեն', 'az': 'Azərbaycan', 'uz': "O'zbek",
    'kk': 'Қазақ', 'ky': 'Кыргызча', 'tg': 'Тоҷикӣ', 'mn': 'Монгол',
    'ps': 'پښتو', 'sd': 'سنڌي', 'am': 'አማርኛ', 'om': 'Afaan Oromoo',
    'ha': 'Hausa', 'ig': 'Igbo', 'yo': 'Yorùbá', 'zu': 'isiZulu',
    'xh': 'isiXhosa', 'af': 'Afrikaans', 'st': 'Sesotho', 'sn': 'Shona',
    'rw': 'Kinyarwanda', 'mg': 'Malagasy', 'ny': 'Chichewa', 'eo': 'Esperanto',
    'cy': 'Cymraeg', 'ga': 'Gaeilge', 'gd': 'Gàidhlig', 'mt': 'Malti',
    'is': 'Íslenska', 'lv': 'Latviešu', 'lt': 'Lietuvių', 'et': 'Eesti',
    'bs': 'Bosanski', 'hr': 'Hrvatski', 'sq': 'Shqip', 'mk': 'Македонски',
    'sr': 'Српски', 'sl': 'Slovenščina', 'sk': 'Slovenčina',
    'eu': 'Euskara', 'gl': 'Galego', 'ca': 'Català', 'oc': 'Occitan',
    'lb': 'Lëtzebuergesch', 'fy': 'Frysk', 'jv': 'Jawa', 'su': 'Sunda',
    'ceb': 'Cebuano', 'hmn': 'Hmong', 'ht': 'Kreyòl', 'co': 'Corsu', 'la': 'Latina',
  };
}
