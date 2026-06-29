import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AIService {
  static final List<String> _inspirations = [
    'لا تحزن، إن الله معنا.',
    'وما تدري نفس ماذا تكسب غداً.',
    'فإن مع العسر يسراً.',
    'إن الله لا يغير ما بقوم حتى يغيروا ما بأنفسهم.',
    'رب اشرح لي صدري ويسر لي أمري.',
    'أحسن الظن بالله.',
    'اليوم أنت أقوى مما كنت أمس.',
    'البدايات الصغيرة تصنع نهايات عظيمة.',
    'لا تنتظر الظروف المثالية، اصنعها.',
    'قيمتك لا تقاس بما تملك، بل بما تعطي.',
    'الفشل ليس النهاية، بل درس جديد.',
    'عقلك أقوى أداة لديك — دربه على النجاح.',
    'كل لحظة هي فرصة لبداية جديدة.',
    'أنت لست وحدك، هناك من يؤمن بك.',
    'الوقت هو أثمن ما تملك — استثمره بحكمة.',
  ];

  /// إنشاء رسالة تحفيزية حقيقية عبر API
  static Future<String> generateInspiration({
    String? userMood,
    String? context,
  }) async {
    try {
      final uri = Uri.parse('https://api.quotable.io/random');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['content'] as String? ?? '';
        final author = data['author'] as String? ?? '';
        if (content.isNotEmpty) {
          return '$content\n— $author';
        }
      }
    } catch (e) {
      debugPrint('AI API error, falling back: $e');
    }

    // Fallback محلي
    await Future.delayed(const Duration(milliseconds: 300));
    final random = Random();
    int index = random.nextInt(_inspirations.length);
    if (userMood != null && userMood.contains('حزين')) index = 0;
    else if (userMood != null && userMood.contains('فرح')) index = 3;
    else if (userMood != null && userMood.contains('خائف')) index = 4;
    return _inspirations[index];
  }

  /// وضع التشخيص — يعطي رسالة حسب السياق
  static String recommendMode(String text) {
    if (text.contains('سلام') || text.contains('hello')) {
      return 'السلام عليكم — أنا هنا لمساعدتك في الترجمة';
    } else if (text.contains('?')) {
      return 'هل لديك سؤال؟ دعني أساعدك';
    } else if (text.length > 50) {
      return 'نص طويل! يمكنني ترجمته لك';
    }
    return 'مرحباً بك في ميرور سكربيون 🦂';
  }

  static Future<String> enhanceStory(String story) async {
    await Future.delayed(const Duration(seconds: 1));
    return '$story\n\n🦂 — تمت الكتابة والتنسيق بواسطة Mirror Scorpion AI';
  }

  static Future<String> generateVideoScript(String storyTitle) async {
    await Future.delayed(const Duration(seconds: 2));
    return 'سكريبت فيديو لقصة "$storyTitle"\n'
        'المدة المقترحة: 10-15 دقيقة\n\n'
        'المشهد الأول: مقدمة درامية\n'
        'المشهد الثاني: الأحداث الرئيسية\n'
        'المشهد الثالث: الذروة\n'
        'المشهد الرابع: النهاية والعبرة';
  }
}
