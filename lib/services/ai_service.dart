import 'dart:math';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  static Future<String> generateInspiration({
    required String userMood,
    required String context,
  }) async {
    final random = Random();
    final inspirations = [
      "لا تحزن.. إن الله معنا. كل انكسار هو تمهيد لانطلاقة أعظم.",
      "ما مضى كان درساً، وما هو آتٍ ينتظر عزيمتك. أنت أقوى مما تظن.",
      "الثبات في وجه العاصفة هو بداية النصر. اصبر فالنصر مع الصبر.",
      "لا يقاس النجاح بعدد المرات التي سقطت فيها، بل بعدد المرات التي نهضت فيها.",
      "إن مع العسر يسراً. بعد كل ليل يشرق فجر جديد.",
      "أنت لا ترى الصورة كاملة الآن، ولكن كل شيء يتوضح لمن صبر.",
      "قصتك لم تنته بعد، بل هي في أجمل فصولها. استمر في الكتابة.",
      "الفرج يأتي بعد الشدة، والنجاح يأتي بعد المحاولة.",
    ];
    await Future.delayed(const Duration(milliseconds: 500));
    return inspirations[random.nextInt(inspirations.length)];
  }
}
