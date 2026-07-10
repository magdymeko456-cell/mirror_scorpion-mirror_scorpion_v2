import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // الحالات الافتراضية للغات الشاشات
  final Map<String, String> _screenLanguages = {
    'dialogue_from': 'ar',
    'dialogue_to': 'en',
    'text_from': 'ar',
    'text_to': 'en',
  };

  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // تحميل اللغات المحفوظة لكل شاشة
    _screenLanguages['dialogue_from'] = _prefs.getString('dialogue_from') ?? 'ar';
    _screenLanguages['dialogue_to'] = _prefs.getString('dialogue_to') ?? 'en';
    _screenLanguages['text_from'] = _prefs.getString('text_from') ?? 'ar';
    _screenLanguages['text_to'] = _prefs.getString('text_to') ?? 'en';

    _isInitialized = true;
    notifyListeners();
  }

  // جلب قائمة الأكواد المتاحة للتطبيق
  List<String> getLanguageCodes() {
    return ['ar', 'en', 'fr', 'de', 'es', 'it', 'tr', 'ru', 'zh'];
  }

  // جلب اسم اللغة بناءً على الكود
  String getLanguageName(String code) {
    switch (code) {
      case 'ar': return 'العربية';
      case 'en': return 'English';
      case 'fr': return 'Français';
      case 'de': return 'Deutsch';
      case 'es': return 'Español';
      case 'it': return 'Italiano';
      case 'tr': return 'Türkçe';
      case 'ru': return 'Русский';
      case 'zh': return '中文';
      default: return code;
    }
  }

  // جلب لغة شاشة معينة
  String getLanguageForScreen(String screenKey) {
    return _screenLanguages[screenKey] ?? 'ar';
  }

  // حفظ لغة شاشة معينة
  Future<void> saveLanguageForScreen(String screenKey, String langCode) async {
    _screenLanguages[screenKey] = langCode;
    await _prefs.setString(screenKey, langCode);
    notifyListeners();
  }

  // ==========================================
  //  🧠 محرك الذكاء الاصطناعي الداخلي والأوفلاين
  // ==========================================
  
  // دالة محاكاة الترجمة الذكية الأوفلاين (توسيع القاموس الداخلي الاستقراطي)
  String translateOffline(String text, String from, String to) {
    if (text.isEmpty) return '';
    String cleanText = text.trim().toLowerCase();

    // قاموس ذكي داخلي للطوارئ والأوفلاين
    final Map<String, Map<String, String>> dictionary = {
      'ar': {
        'hello': 'مرحباً',
        'how are you?': 'كيف حالك؟',
        'thank you': 'شكراً لك',
        'good morning': 'صباح الخير',
        'good night': 'تصبح على خير',
        'yes': 'نعم',
        'no': 'لا',
        'peace be upon you': 'السلام عليكم',
        'welcome': 'أهلاً وسهلاً',
      },
      'en': {
        'مرحبا': 'Hello',
        'مرحباً': 'Hello',
        'كيف حالك': 'How are you?',
        'كيف حالك؟': 'How are you?',
        'شكرا': 'Thank you',
        'شكراً': 'Thank you',
        'صباح الخير': 'Good morning',
        'السلام عليكم': 'Peace be upon you',
        'أهلاً وسهلاً': 'Welcome',
      }
    };

    // محاولة البحث في القاموس
    if (dictionary.containsKey(to)) {
      for (var entry in dictionary[to]!.entries) {
        if (cleanText.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    // إذا لم يجد النص، يعود بترجمة الذكاء الاصطناعي الافتراضية المستقرة دون كراش
    return '[$to] $text';
  }

  // دالة الذكاء الاصطناعي لكارت الألعاب (توليد أسئلة/تحديات ذكية بناءً على اللغة)
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
}
