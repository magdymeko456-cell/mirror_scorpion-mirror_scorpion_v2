import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIService extends ChangeNotifier {
  String _lastInspiration = '';
  String _lastUserMood = '';
  int _lastNotificationHour = -1;
  bool _useApi = true; // التبديل بين API والردود المحلية

  // API Key - ضع مفتاحك هنا أو استخدم متغير بيئة
  String _apiKey = '';
  String get apiKey => _apiKey;
  set apiKey(String key) {
    _apiKey = key;
    notifyListeners();
  }

  String get lastInspiration => _lastInspiration;

  // ===== القاعدة المحلية (Fallback) =====
  final List<String> _comfortMessages = [
    '﴿ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾ [الشرح: 6]',
    '﴿ وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ ﴾ [هود: 88]',
    '﴿ رَبِّ اشْرَحْ لِي صَدْرِي ﴾ [طه: 25]',
    '﴿ إِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ ﴾ [التوبة: 120]',
    '﴿ وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ﴾ [الطلاق: 3]',
    '﴿ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ﴾ [الزمر: 53]',
    '﴿ أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ ﴾ [الشرح: 1]',
    '﴿ فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾ [الشرح: 5]',
    '﴿ مَّا وَدَّعَكَ رَبُّكَ وَمَا قَلَى ﴾ [الضحى: 3]',
    '﴿ وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ ﴾ [الضحى: 5]',
    'قال النبي ﷺ: "عجباً لأمر المؤمن، إن أمره كله له خير"',
    'قال النبي ﷺ: "لا تحقرن من المعروف شيئاً"',
    'قال النبي ﷺ: "تفاءلوا بالخير تجدوه"',
  ];

  final List<String> _joyMessages = [
    '﴿ وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ ﴾ [الضحى: 11]',
    '﴿ قُلْ بِفَضْلِ اللَّهِ وَبِرَحْمَتِهِ فَبِذَٰلِكَ فَلْيَفْرَحُوا ﴾ [يونس: 58]',
    'الحمد لله الذي بنعمته تتم الصالحات',
    'اللهم لك الحمد كما ينبغي لجلال وجهك وعظيم سلطانك',
    '﴿ رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ ﴾ [النمل: 19]',
    'قال النبي ﷺ: "من رأى مبتلى فقال الحمد لله الذي عافاني مما ابتلاك به"',
  ];

  final List<String> _encouragementMessages = [
    '﴿ إِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ مَنْ أَحْسَنَ عَمَلًا ﴾ [الكهف: 30]',
    'استعن بالله ولا تعجز - حديث شريف',
    '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾ [طه: 114]',
    '﴿ فَإِذَا فَرَغْتَ فَانصَبْ ﴾ [الشرح: 7]',
    'قال النبي ﷺ: "احرص على ما ينفعك واستعن بالله"',
    '﴿ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ﴾ [البقرة: 255]',
    'لا تيأس، فبعد العسر يسراً، وبعد الضيق فرجاً',
  ];

  // ===== API Calls =====
  Future<String> _callAIAPI(String prompt, {int maxTokens = 150}) async {
    if (_apiKey.isEmpty) return '';

    try {
      // استخدام Gemini API
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        'gemini-2.0-flash:generateContent?key=$_apiKey'
      );
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{
            'parts': [{'text': prompt}]
          }],
          'generationConfig': {
            'maxOutputTokens': maxTokens,
            'temperature': 0.7,
          }
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        return text.toString().trim();
      }
    } catch (_) {}

    return '';
  }

  Future<String> generateInspiration({
    String userMood = '',
    String context = '',
  }) async {
    _lastUserMood = userMood;

    // محاولة API أولاً
    if (_useApi && _apiKey.isNotEmpty) {
      final prompt = userMood.isNotEmpty
          ? 'المستخدم يشعر بـ: $userMood. اكتب رسالة إلهام إسلامية قصيرة (آية أو حديث أو موعظة) تناسب حالته. السياق: $context'
          : 'اكتب رسالة إلهام إسلامية عشوائية (آية قرآنية أو حديث نبوي) قصيرة ومؤثرة.';
      final result = await _callAIAPI(prompt);
      if (result.isNotEmpty && result.length > 10) {
        _lastInspiration = result;
        notifyListeners();
        return _lastInspiration;
      }
    }

    // Fallback للقاعدة المحلية
    List<String> pool;
    if (userMood.contains('حزين') || userMood.contains('تعب') ||
        userMood.contains('ضيق') || userMood.contains('خوف')) {
      pool = _comfortMessages;
    } else if (userMood.contains('فرح') || userMood.contains('سعيد') ||
        userMood.contains('نجاح') || userMood.contains('الحمد')) {
      pool = _joyMessages;
    } else if (userMood.contains('يأس') || userMood.contains('فشل') ||
        userMood.contains('حاجة')) {
      pool = _encouragementMessages;
    } else {
      pool = [..._comfortMessages, ..._joyMessages, ..._encouragementMessages];
    }

    _lastInspiration = pool[Random().nextInt(pool.length)];
    notifyListeners();
    return _lastInspiration;
  }

  String getDailyInspiration() {
    final all = [..._comfortMessages, ..._joyMessages, ..._encouragementMessages];
    _lastInspiration = all[DateTime.now().day % all.length];
    return _lastInspiration;
  }

  /// إنشاء رسالة إشعار كل 3 ساعات
  Future<String?> generateNotificationMessage() async {
    final currentHour = DateTime.now().hour;
    if (_lastNotificationHour == currentHour) return null;

    // كل 3 ساعات
    if (currentHour % 3 == 0) {
      _lastNotificationHour = currentHour;
      if (_useApi && _apiKey.isNotEmpty) {
        final result = await _callAIAPI(
          'اكتب رسالة إلهام إسلامية قصيرة جداً (سطر واحد) فيها آية أو حديث ملهم.'
        );
        if (result.isNotEmpty) {
          return result;
        }
      }
      final all = [..._comfortMessages, ..._joyMessages, ..._encouragementMessages];
      return all[Random().nextInt(all.length)];
    }
    return null;
  }

  /// تحليل اهتمامات المستخدم في القصص
  Future<String> analyzeUserInterest(List<String> recentStoryTitles) async {
    if (recentStoryTitles.isEmpty) return getDailyInspiration();

    if (_useApi && _apiKey.isNotEmpty) {
      final prompt = 'المستخدم مهتم بقصة "${recentStoryTitles.last}". '
          'اكتب رسالة إلهام مرتبطة بهذه القصة فيها عبرة وعظة.';
      final result = await _callAIAPI(prompt);
      if (result.isNotEmpty) {
        return result;
      }
    }
    return '📖 تأمل في قصة "${recentStoryTitles.last}" - فيها عبرة وعظة';
  }

  /// تخصيص رسالة للمستخدم بناء على تفاعلاته السابقة
  Future<String> generatePersonalizedMessage({
    int storyCount = 0,
    List<String> favoriteStories = const [],
    String lastMood = '',
  }) async {
    if (_useApi && _apiKey.isNotEmpty) {
      final prompt = 'مستخدم قرأ $storyCount قصة. آخر قصصه: ${favoriteStories.take(3).join(", ")}. '
          'اكتب رسالة تشجيع وإلهام إسلامية مخصصة له.';
      final result = await _callAIAPI(prompt, maxTokens: 200);
      if (result.isNotEmpty) return result;
    }
    return getDailyInspiration();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
