import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../core/api_config.dart';

/// خدمة AI حقيقية عبر Gemini API — توليد إلهام ودعم نفسي
class AIService {
  static Future<String> generateInspiration({String userMood = '', bool isPremium = false}) async {
    try {
      final prompt = userMood.isEmpty
        ? 'قدم رسالة إلهام وتحفيز يومية باللغة العربية. كن إيجابياً وملهمًا. أضف آية قرآنية أو حديثاً مناسباً في النهاية.'
        : 'المستخدم يشعر بـ: $userMood. قدم له رسالة دعم نفسي وإلهام باللغة العربية مناسبة لحالته. أضف آية قرآنية أو حديثاً مناسباً.';

      final url = '${ApiConfig.geminiUrl}?key=${ApiConfig.googleApiKey}';
      final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': prompt}]}],
          'generationConfig': {'temperature': 0.8, 'maxOutputTokens': 250},
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
        if (text.isNotEmpty) return text;
      } else {
        debugPrint('❌ Gemini API error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ AI Service error: $e');
    }

    // Fallback إن فشل API
    const fallbacks = [
      'تذكّر أن كل تحدٍ هو فرصة لتصبح أقوى وأحكم. "إن مع العسر يسرا" (الشرح: ٦)',
      'الصبر مفتاح الفرج. "وَاصْبِرْ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ" (الأنفال: ٤٦)',
      'لا تستسلم، فالفجر يأتي بعد أطول ليل. "فَإِنَّ مَعَ الْعُسْرِ يُسْرًا" (الشرح: ٥)',
      'أنت أقوى مما تعتقد. "وَلَا تَهِنُوا وَلَا تَحْزَنُوا وَأَنْتُمُ الْأَعْلَوْنَ" (آل عمران: ١٣٩)',
    ];
    return fallbacks[DateTime.now().microsecond % fallbacks.length];
  }

  static Future<String> generateDailyWisdom() => generateInspiration();
  static Future<String> getSpiritualSupport({required String userState, bool isPremium = false}) => generateInspiration(userMood: userState);

  static Future<String> analyzeSentiment(String text) async {
    final lowered = text.toLowerCase();
    if (['حزين','حزن','مكتئب','وحيد','يأس','فشل','خسر','ألم','sad','depressed','lonely'].any((w) => lowered.contains(w))) return 'sad';
    if (['سعيد','فرح','نجاح','فوز','جميل','happy','joy','amazing','love'].any((w) => lowered.contains(w))) return 'happy';
    return 'neutral';
  }

  /// دردشة مع Gemini
  static Future<String> chat(String message) async {
    try {
      final url = '${ApiConfig.geminiUrl}?key=${ApiConfig.googleApiKey}';
      final response = await http.post(Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [{'parts': [{'text': 'أنت مساعد ذكي اسمه ميرور سكربيون. أجب بالعربية: $message'}]}],
          'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 300},
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
      }
    } catch (_) {}
    return 'عذراً، حدث خطأ. حاول مرة أخرى.';
  }
}
