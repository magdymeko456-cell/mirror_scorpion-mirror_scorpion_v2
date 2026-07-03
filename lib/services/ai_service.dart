import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIService extends ChangeNotifier {
  String _lastInspiration = '';
  String _lastUserMood = '';
  int _lastNotificationHour = -1;
  bool _useApi = true;
  String _apiKey = '';
  String _deviceLanguage = 'ar';

  String get apiKey => _apiKey;
  String get lastInspiration => _lastInspiration;
  String get deviceLanguage => _deviceLanguage;

  set apiKey(String key) {
    _apiKey = key;
    notifyListeners();
  }

  set deviceLanguage(String lang) {
    _deviceLanguage = lang;
    notifyListeners();
  }

  // ===== القاعدة المحلية (Fallback) =====
  final List<Map<String, String>> _inspirationDatabase = [
    {'ar': '﴿ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾ [الشرح: 6]', 'en': 'Indeed, with hardship comes ease. [Quran 94:6]'},
    {'ar': '﴿ وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ ﴾ [هود: 88]', 'en': 'And my success is only through Allah. [Quran 11:88]'},
    {'ar': '﴿ رَبِّ اشْرَحْ لِي صَدْرِي ﴾ [طه: 25]', 'en': 'My Lord, expand for me my breast. [Quran 20:25]'},
    {'ar': '﴿ إِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ ﴾ [التوبة: 120]', 'en': 'Indeed, Allah does not allow to be lost the reward of the doers of good. [Quran 9:120]'},
    {'ar': '﴿ وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ﴾ [الطلاق: 3]', 'en': 'And whoever relies upon Allah – then He is sufficient for him. [Quran 65:3]'},
    {'ar': '﴿ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ﴾ [الزمر: 53]', 'en': 'Do not despair of the mercy of Allah. [Quran 39:53]'},
    {'ar': '﴿ أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ ﴾ [الشرح: 1]', 'en': 'Did We not expand for you your breast? [Quran 94:1]'},
    {'ar': '﴿ فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾ [الشرح: 5]', 'en': 'For indeed, with hardship comes ease. [Quran 94:5]'},
    {'ar': '﴿ مَّا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ ﴾ [الضحى: 3]', 'en': 'Your Lord has not taken leave of you, nor has He detested [you]. [Quran 93:3]'},
    {'ar': '﴿ وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰ ﴾ [الضحى: 5]', 'en': 'And your Lord is going to give you, and you will be satisfied. [Quran 93:5]'},
    {'ar': 'قال النبي ﷺ: "عجباً لأمر المؤمن، إن أمره كله له خير"', 'en': 'The Prophet ﷺ said: "Amazing is the affair of the believer, all of it is good."'},
    {'ar': 'قال النبي ﷺ: "لا تحقرن من المعروف شيئاً"', 'en': 'The Prophet ﷺ said: "Do not deem any act of kindness insignificant."'},
    {'ar': 'قال النبي ﷺ: "تفاءلوا بالخير تجدوه"', 'en': 'The Prophet ﷺ said: "Be optimistic about good, you will find it."'},
    {'ar': '﴿ وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ ﴾ [الضحى: 11]', 'en': 'And as for the favor of your Lord, report [it]. [Quran 93:11]'},
    {'ar': '﴿ قُلْ بِفَضْلِ اللَّهِ وَبِرَحْمَتِهِ فَبِذَٰلِكَ فَلْيَفْرَحُوا ﴾ [يونس: 58]', 'en': 'Say: In the bounty of Allah and in His mercy – in that let them rejoice. [Quran 10:58]'},
    {'ar': '﴿ إِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ مَنْ أَحْسَنَ عَمَلًا ﴾ [الكهف: 30]', 'en': 'Indeed, Allah does not allow to be lost the reward of those who do good. [Quran 18:30]'},
    {'ar': '﴿ وَقُل رَّبِّ زِدْنِي عِلْمًا ﴾ [طه: 114]', 'en': 'And say: My Lord, increase me in knowledge. [Quran 20:114]'},
    {'ar': '﴿ فَإِذَا فَرَغْتَ فَانصَبْ ﴾ [الشرح: 7]', 'en': 'So when you have finished, then stand up [for worship]. [Quran 94:7]'},
    {'ar': 'قال النبي ﷺ: "احرص على ما ينفعك واستعن بالله"', 'en': 'The Prophet ﷺ said: "Be keen on what benefits you and seek help from Allah."'},
    {'ar': '﴿ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ﴾ [البقرة: 255]', 'en': 'His Kursi extends over the heavens and the earth. [Quran 2:255]'},
    {'ar': 'لا تيأس، فبعد العسر يسراً، وبعد الضيق فرجاً', 'en': 'Do not despair, after hardship comes ease, after distress comes relief.'},
    {'ar': '﴿ رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ ﴾ [النمل: 19]', 'en': 'My Lord, enable me to be grateful for Your favor. [Quran 27:19]'},
    {'ar': 'الحمد لله الذي بنعمته تتم الصالحات', 'en': 'Praise be to Allah by whose grace good deeds are completed.'},
  ];

  // ===== API Calls (Gemini) =====
  Future<String> _callAIAPI(String prompt, {int maxTokens = 150}) async {
    if (_apiKey.isEmpty) return '';
    try {
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

  /// توليد رسالة إلهام
  Future<String> generateInspiration({
    String userMood = '',
    String context = '',
  }) async {
    _lastUserMood = userMood;

    // محاولة API
    if (_useApi && _apiKey.isNotEmpty) {
      final lang = _deviceLanguage == 'en' ? 'English' : 'Arabic';
      final prompt = userMood.isNotEmpty
          ? 'The user is feeling: $userMood. Write a short Islamic inspirational message (verse, hadith, or wisdom) in $lang that suits their mood. Context: $context'
          : 'Write a random short Islamic inspirational message (Quranic verse or hadith) in $lang. Keep it concise and impactful.';
      final result = await _callAIAPI(prompt);
      if (result.isNotEmpty && result.length > 10) {
        _lastInspiration = result;
        notifyListeners();
        return _lastInspiration;
      }
    }

    // Fallback محلي مع دعم اللغة
    final langKey = _deviceLanguage == 'en' ? 'en' : 'ar';
    final filtered = _inspirationDatabase
        .where((m) => m.containsKey(langKey) && m[langKey]!.isNotEmpty)
        .toList();
    final pool = filtered.isNotEmpty ? filtered : _inspirationDatabase;
    _lastInspiration = pool[Random().nextInt(pool.length)][langKey] ?? pool[0]['ar']!;
    notifyListeners();
    return _lastInspiration;
  }

  /// رسالة يومية
  String getDailyInspiration() {
    final langKey = _deviceLanguage == 'en' ? 'en' : 'ar';
    final filtered = _inspirationDatabase
        .where((m) => m.containsKey(langKey) && m[langKey]!.isNotEmpty)
        .toList();
    final pool = filtered.isNotEmpty ? filtered : _inspirationDatabase;
    _lastInspiration = pool[DateTime.now().day % pool.length][langKey] ?? pool[0]['ar']!;
    return _lastInspiration;
  }

  /// رسالة إشعار كل 3 ساعات
  Future<String?> generateNotificationMessage() async {
    final currentHour = DateTime.now().hour;
    if (_lastNotificationHour == currentHour) return null;

    if (currentHour % 3 == 0) {
      _lastNotificationHour = currentHour;
      if (_useApi && _apiKey.isNotEmpty) {
        final lang = _deviceLanguage == 'en' ? 'English' : 'Arabic';
        final result = await _callAIAPI(
          'Write a very short Islamic inspirational message (one line) in $lang with a Quranic verse or hadith.'
        );
        if (result.isNotEmpty) return result;
      }
      return getDailyInspiration();
    }
    return null;
  }

  /// تحليل اهتمام المستخدم في القصص
  Future<String> analyzeUserInterest(List<String> recentStoryTitles) async {
    if (recentStoryTitles.isEmpty) return getDailyInspiration();
    if (_useApi && _apiKey.isNotEmpty) {
      final lang = _deviceLanguage == 'en' ? 'English' : 'Arabic';
      final prompt = 'The user is interested in the story: "${recentStoryTitles.last}". '
          'Write an inspirational message in $lang related to this story containing a lesson.';
      final result = await _callAIAPI(prompt);
      if (result.isNotEmpty) return result;
    }
    final lastTitle = recentStoryTitles.last;
    return '📖 تأمل في قصة "$lastTitle" — فيها عبرة وعظة';
  }

  /// رسالة مخصصة
  Future<String> generatePersonalizedMessage({
    int storyCount = 0,
    List<String> favoriteStories = const [],
    String lastMood = '',
  }) async {
    if (_useApi && _apiKey.isNotEmpty) {
      final lang = _deviceLanguage == 'en' ? 'English' : 'Arabic';
      final stories = favoriteStories.take(3).join(', ');
      final prompt = 'A user read $storyCount stories. Their recent stories: $stories. '
          'Write an encouraging Islamic message in $lang for them.';
      final result = await _callAIAPI(prompt, maxTokens: 200);
      if (result.isNotEmpty) return result;
    }
    return getDailyInspiration();
  }
}
