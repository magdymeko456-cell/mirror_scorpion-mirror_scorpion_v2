import 'dart:math';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// خدمة الذكاء الاصطناعي - إلهام، تحليل نصوص، توليد قصص
class AIService {
  static final Random _random = Random();

  // قواعد بيانات الرسائل الملهمة حسب الحالة
  static const Map<String, List<String>> _inspirationByMood = {
    'حزين': [
      "أعلم أن الأوقات صعبة، ولكن تذكر أن الله لا يكلف نفساً إلا وسعها. أنت قادر على تخطي هذه المحنة.",
      "قال تعالى: {إِنَّ مَعَ الْعُسْرِ يُسْرًا}. بعد كل ضيق يأتي الفرج، ثق بالله.",
      "الدموع ليست ضعفاً، هي تطهير للروح. كل دمعة تسقط تحمل معها بعض الألم. غداً سيكون أجمل.",
      "لا تحزن، إن الله معنا. القمر لا يختفي، بل يختفي خلف السحاب مؤقتاً. ستعود الأيام المشرقة.",
    ],
    'فرحان': [
      "الحمد لله على نعمة الفرح. تذكر أن تبقى متواضعاً، وأن تشكر الله على ما أعطاك. الفرح الحقيقي في المشاركة.",
      "النجاح ليس نهاية الطريق، بل هو محطة. استمتع بلحظتك ولكن استعد للمرحلة القادمة بتواضع.",
      "الفرح الذي تشعر به الآن هو ثمرة صبرك. لا تدع الغرور يسرق جمال هذه اللحظة.",
    ],
    'متعب': [
      "خذ قسطاً من الراحة، جسدك وروحك يحتاجان للاسترخاء. لا بأس أن تتوقف قليلاً لتستعيد طاقتك.",
      "التعب ليس فشلاً، بل دليل على أنك تبذل جهداً. أنت في الطريق الصحيح، استمر ولكن بتمهل.",
      "كل مجهود تبذله اليوم هو استثمار في مستقبلك. أنت تبني شيئاً عظيماً، لا تستسلم.",
    ],
    'محتاج تشجيع': [
      "أنت أقوى مما تتصور، وأعظم مما تتخيل. لا تسمح للشك أن يسرق أحلامك.",
      "لا تقارن نفسك بالآخرين، فلك طريقك الخاص الذي يميزك. رحلتك فريدة وأنت بطلها.",
      "الثقة بالنفس هي أول خطوة نحو النجاح. أنت تملك كل ما تحتاجه لتحقيق أهدافك.",
    ],
  };

  /// توليد رسالة ملهمة بناءً على حالة المستخدم
  static Future<String> generateInspiration({
    required String userMood,
    required String context,
  }) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(500)));

    // البحث عن رسائل تناسب الحالة
    for (final entry in _inspirationByMood.entries) {
      if (userMood.contains(entry.key)) {
        final messages = entry.value;
        return messages[_random.nextInt(messages.length)];
      }
    }

    // رسائل عشوائية عامة
    const generalMessages = [
      "الوقت هو العملة الأغلى، استثمر كل ثانية في بناء نفسك.",
      "الماضي ليس للمحو بل للتعلم، والمستقبل هو ما يستحق انتباهك الآن.",
      "قوتك الحقيقية تكمن في قدرتك على النهوض بعد كل سقوط.",
      "اليوم هو فرصة جديدة لبداية جديدة.",
      "لا تؤجل حلمك إلى الغد، فاليوم هو أفضل وقت للبدء.",
      "تذكر دائماً.. قصتك لا تزال تُكتب، والنهاية لم يحن وقتها بعد.",
    ];
    return generalMessages[_random.nextInt(generalMessages.length)];
  }

  /// توليد رسالة مخصصة كل 3 ساعات
  static Future<String> generatePersonalizedMessage(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final messages = _inspirationByMood.values.expand((x) => x).toList();
    final msg = messages[_random.nextInt(messages.length)];
    return "🌟 $msg\n- ميرور سكربيون AI";
  }

  /// توليد مقدمة قصة
  static Future<String> generateStoryIntro(String storyTitle) async {
    final intros = [
      "قصة $storyTitle: رحلة مليئة بالعبر والدروس المستفادة من أحداث عظيمة.",
      "في قديم الزمان، كان هناك $storyTitle... قصة تحمل في طياتها الحكمة.",
      "تعالوا نستمع إلى قصة $storyTitle المستوحاة من أحداث حقيقية.",
    ];
    return intros[_random.nextInt(intros.length)];
  }

  /// تحليل النص لتحديد الحالة النفسية
  static String analyzeMood(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('حزين') || lower.contains('تعب') || lower.contains('ضيق') || lower.contains('بكاء')) {
      return 'حزين';
    }
    if (lower.contains('فرح') || lower.contains('سعيد') || lower.contains('نجاح') || lower.contains('الحمد')) {
      return 'فرحان';
    }
    if (lower.contains('تعب') || lower.contains('مرهق') || lower.contains('نوم')) {
      return 'متعب';
    }
    return 'محتاج تشجيع';
  }
}
