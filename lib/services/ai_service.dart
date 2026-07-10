import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AIService {
  static final Random _random = Random();

  // قائمة الرسائل الملهمة
  static const List<String> _inspirationMessages = [
    "لا تيأس، فالله معك. كل انكسار هو بداية انطلاقة أعظم.",
    "الوقت هو العملة الأغلى، استثمر كل ثانية في بناء نفسك.",
    "الماضي ليس للمحو بل للتعلم، والمستقبل هو ما يستحق انتباهك الآن.",
    "قوتك الحقيقية تكمن في قدرتك على النهوض بعد كل سقوط.",
    "لا تقارن نفسك بالآخرين، فلك طريقك الخاص الذي يميزك.",
    "الصبر مفتاح الفرج، وكل ضيق يأتي بعده فرج عظيم.",
    "أنت أقوى مما تتصور، وأعظم مما تتخيل.",
    "اليوم هو فرصة جديدة لبداية جديدة.",
    "لا تؤجل حلمك إلى الغد، فاليوم هو أفضل وقت للبدء.",
    "الثقة بالنفس هي أول خطوة نحو النجاح.",
  ];

  static Future<String> generateInspiration({
    required String userMood,
    required String context,
  }) async {
    // محاكاة الذكاء - يمكن ربطها بـ API حقيقي لاحقاً
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(800)));
    
    if (userMood.isNotEmpty) {
      if (userMood.contains('حزين') || userMood.contains('تعبان') || userMood.contains('ضيق')) {
        return "أعلم أن الأوقات صعبة، ولكن تذكر أن الله لا يكلف نفساً إلا وسعها. "
            "أنت قادر على تخطي هذه المحنة، وستخرج منها أقوى مما كنت. "
            "قال تعالى: {إِنَّ مَعَ الْعُسْرِ يُسْرًا}";
      }
      if (userMood.contains('فرح') || userMood.contains('سعيد') || userMood.contains('نجاح')) {
        return "الحمد لله على نعمة الفرح. تذكر أن تبقى متواضعاً في نجاحك، "
            "وأن تشكر الله على ما أعطاك. الفرح الحقيقي هو في مشاركته مع الآخرين.";
      }
    }
    
    return _inspirationMessages[_random.nextInt(_inspirationMessages.length)];
  }

  static Future<String> generatePersonalizedMessage(String userId) async {
    await Future.delayed(Duration(milliseconds: 300));
    final msg = _inspirationMessages[_random.nextInt(_inspirationMessages.length)];
    return "مرحباً! 🌟\n\n$msg\n\n- مانوس AI";
  }

  static Future<String> generateStoryIntro(String storyTitle) async {
    return "قصة $storyTitle: رحلة مليئة بالعبر والدروس المستفادة";
  }

  static Future<String> translateText(String text, String targetLang) async {
    // مؤقت - سيتم ربطه بـ API ترجمة حقيقي
    return "[$targetLang] $text";
  }
}
