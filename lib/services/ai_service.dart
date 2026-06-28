import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class AIService {
  static const String _apiEndpoint = 'https://api.openai.com/v1/chat/completions';
  static const String _modelName = 'gpt-3.5-turbo';

  static const String MODE_SPIRITUAL = 'خواطر روحانية';
  static const String MODE_AYAH = 'آيات مناسبات';
  static const String MODE_DUA = 'أدعية مأثورة';

  static final List<String> _spiritualThoughts = [
    'تأمل في خلق الله.. كل شيء حولك يسبح بحمده',
    'الدنيا ساعة فاجعلها طاعة، والقلب إذا تعلق بالله هانت عليه الدنيا',
    'ما من شيء أحب إلى الله من التوكل عليه وحسن الظن به',
    'الليل والنهار يعملان فيك فاعمل فيهما، والموت يأتي بغتة فاستعد له',
    'إذا ضاقت بك الدنيا فاعلم أن فرج الله قريب، مع العسر يسراً',
    'سبحان الله وبحمده.. عدد خلقه ورضا نفسه وزنة عرشه ومداد كلماته',
    'القلب السليم هو الذي يرى الله في كل شيء',
    'الدنيا متاع الغرور، والآخرة خير وأبقى، فاعمل لآخرتك',
    'الصلاة عماد الدين، فحافظ عليها تكن من الفائزين',
    'لا تحزن إن الله معنا، السكينة تنزل مع الذكر',
  ];

  static final List<Map<String, String>> _occasionAyahs = [
    {'occasion': 'عند الحزن', 'ayah': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'surah': 'الشرح: 6'},
    {'occasion': 'عند الخوف', 'ayah': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ', 'surah': 'آل عمران: 173'},
    {'occasion': 'عند الذنب', 'ayah': 'وَإِنِّي لَغَفَّارٌ لِّمَن تَابَ وَآمَنَ وَعَمِلَ صَالِحًا', 'surah': 'طه: 82'},
    {'occasion': 'عند الضيق', 'ayah': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'surah': 'الشرح: 5-6'},
    {'occasion': 'عند النعمة', 'ayah': 'وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ', 'surah': 'الضحى: 11'},
    {'occasion': 'عند السفر', 'ayah': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ', 'surah': 'الزخرف: 13'},
  ];

  static final List<Map<String, String>> _authenticDuas = [
    {'dua': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ', 'source': 'البقرة: 201'},
    {'dua': 'رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا', 'source': 'البقرة: 286'},
    {'dua': 'رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي', 'source': 'طه: 25-26'},
    {'dua': 'رَبِّ لَا تَذَرْنِي فَرْدًا وَأَنتَ خَيْرُ الْوَارِثِينَ', 'source': 'الأنبياء: 89'},
    {'dua': 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ', 'source': 'آل عمران: 173'},
  ];

  static Future<String> generateByMode(String mode, {String? mood}) async {
    final random = DateTime.now().microsecond;
    switch (mode) {
      case MODE_SPIRITUAL:
        return _spiritualThoughts[random % _spiritualThoughts.length];
      case MODE_AYAH:
        final ayah = _occasionAyahs[random % _occasionAyahs.length];
        return '【${ayah['ayah']}】\n${ayah['surah']}\n\nمناسبة: ${ayah['occasion']}';
      case MODE_DUA:
        final dua = _authenticDuas[random % _authenticDuas.length];
        return '🤲 ${dua['dua']}\n📖 ${dua['source']}';
      default:
        return _spiritualThoughts[random % _spiritualThoughts.length];
    }
  }

  /// توليد إلهام حسب حالة المستخدم (مطلوب من overlay_service)
  static Future<String> generateInspiration({String? userMood, String? context}) async {
    if (userMood != null && userMood.isNotEmpty) {
      final mode = recommendMode(userMood);
      return generateByMode(mode, mood: userMood);
    }
    return getDailyInspiration();
  }

  static Future<String> callOpenAIAPI({
    required String prompt,
    required String apiKey,
    String mode = MODE_SPIRITUAL,
  }) async {
    try {
      String systemPrompt;
      switch (mode) {
        case MODE_SPIRITUAL:
          systemPrompt = 'أنت خادم روحاني إسلامي، تقدم خواطر روحانية قصيرة مؤثرة بالعربية';
          break;
        case MODE_AYAH:
          systemPrompt = 'أنت مفسر قرآن، تقدم آيات مناسبة لحالة المستخدم مع تفسير مختصر';
          break;
        case MODE_DUA:
          systemPrompt = 'أنت داعية إسلامي، تقدم أدعية مأثورة من القرآن والسنة مناسبة لحالة المستخدم';
          break;
        default:
          systemPrompt = 'أنت مساعد روحي إسلامي';
      }
      final response = await http.post(
        Uri.parse(_apiEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': _modelName,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.8,
          'max_tokens': 200,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'] ?? 'تذكّر أن الله معك دائماً';
      }
      return 'عذراً، حدث خطأ في الاتصال';
    } catch (e) {
      return 'سبحان الله وبحمده، سبحان الله العظيم';
    }
  }

  static Future<String> getDailyInspiration() async {
    final random = DateTime.now().microsecond;
    final all = [
      ..._spiritualThoughts,
      '﴿ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾',
      '﴿ وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ﴾',
      '﴿ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ ﴾',
      '﴿ رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً ﴾',
      '﴿ إِنَّ اللَّهَ لَا يُضِيعُ أَجْرَ الْمُحْسِنِينَ ﴾',
      '﴿ وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ ﴾',
      '﴿ فَاذْكُرُونِي أَذْكُرْكُمْ ﴾',
      '﴿ إِنَّ رَحْمَتَ اللَّهِ قَرِيبٌ مِّنَ الْمُحْسِنِينَ ﴾',
    ];
    return all[random % all.length];
  }

  static String recommendMode(String text) {
    final sad = ['حزين', 'تعب', 'خائف', 'قلق', 'ضيق', 'هم', 'غم'];
    final happy = ['فرح', 'سعيد', 'نجاح', 'خير', 'حمد'];
    for (final w in sad) {
      if (text.contains(w)) return MODE_DUA;
    }
    for (final w in happy) {
      if (text.contains(w)) return MODE_SPIRITUAL;
    }
    return MODE_AYAH;
  }
}
