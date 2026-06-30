import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class DatabaseService extends ChangeNotifier {
  List<Map<String, dynamic>> _translations = [];
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _hadiths = [];
  List<Map<String, dynamic>> _revelationReasons = [];

  bool get isLoaded => _hadiths.isNotEmpty;
  List<Map<String, dynamic>> get translations => _translations;
  List<Map<String, dynamic>> get stories => _stories;
  List<Map<String, dynamic>> get hadiths => _hadiths;
  List<Map<String, dynamic>> get revelationReasons => _revelationReasons;
  List<Map<String, dynamic>> get quranStories => getStoriesByCategory('قصص القرآن');
  List<Map<String, dynamic>> get prophetStories => getStoriesByCategory('الأنبياء');
  List<Map<String, dynamic>> get womenStories => getStoriesByCategory('نساء');
  List<Map<String, dynamic>> get animalStories => getStoriesByCategory('حيوان');
  List<Map<String, dynamic>> get humanStories => getStoriesByCategory('إنسان');
  List<Map<String, dynamic>> get nationsStories => getStoriesByCategory('أقوام');

  Future<void> initialize() async {
    await _loadFromAssets();
    await _loadTranslations();
  }

  Future<void> _loadFromAssets() async {
    try {
      final String jsonStr = '''{
  "stories": [
    {"title": "قصة آدم", "category": "الأنبياء", "content": "خلق الله آدم من طين...", "source": "سورة البقرة", "video_duration": 15},
    {"title": "قصة نوح", "category": "الأنبياء", "content": "أرسل الله نوحاً إلى قومه...", "source": "سورة هود", "video_duration": 15},
    {"title": "قصة إبراهيم", "category": "الأنبياء", "content": "كان إبراهيم نبياً حنيفاً...", "source": "سورة البقرة", "video_duration": 15},
    {"title": "قصة موسى", "category": "الأنبياء", "content": "أرسل الله موسى إلى فرعون...", "source": "سورة طه", "video_duration": 15},
    {"title": "قصة عيسى", "category": "الأنبياء", "content": "بشرت الملائكة مريم...", "source": "سورة آل عمران", "video_duration": 12},
    {"title": "قصة يوسف", "category": "الأنبياء", "content": "أحسن القصص...", "source": "سورة يوسف", "video_duration": 15},
    {"title": "قصة محمد ﷺ", "category": "النبي الخاتم", "content": "ولد النبي في مكة...", "source": "السيرة النبوية", "video_duration": 15},
    {"title": "أصحاب الكهف", "category": "قصص القرآن", "content": "فتية آمنوا بربهم...", "source": "سورة الكهف", "video_duration": 10},
    {"title": "قصة قارون", "category": "قصص القرآن", "content": "كان قارون من قوم موسى...", "source": "سورة القصص", "video_duration": 10}
  ],
  "hadiths": [
    {"text": "إنما الأعمال بالنيات", "narrator": "عمر بن الخطاب", "source": "رواه البخاري ومسلم"},
    {"text": "الدين النصيحة", "narrator": "أبو هريرة", "source": "رواه مسلم"},
    {"text": "اتق الله حيثما كنت", "narrator": "أبو ذر", "source": "رواه الترمذي"},
    {"text": "لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه", "narrator": "أنس بن مالك", "source": "رواه البخاري ومسلم"},
    {"text": "المسلم من سلم المسلمون من لسانه ويده", "narrator": "عبد الله بن عمرو", "source": "رواه البخاري"}
  ],
  "revelation_reasons": [
    {"surah": "العلق", "ayah": 1, "text": "اقْرَأْ", "reason": "أول آية نزلت في غار حراء"},
    {"surah": "المدثر", "ayah": 1, "text": "يَا أَيُّهَا الْمُدَّثِّرُ", "reason": "بعد فترة انقطاع الوحي"},
    {"surah": "الضحى", "ayah": 1, "text": "وَالضُّحَىٰ", "reason": "تطييباً لقلب النبي ﷺ"},
    {"surah": "الكوثر", "ayah": 1, "text": "إِنَّا أَعْطَيْنَاكَ الْكَوْثَرَ", "reason": "حين عَيَّر المشركون النبي بموت أبنائه"},
    {"surah": "المسد", "ayah": 1, "text": "تَبَّتْ يَدَا أَبِي لَهَبٍ", "reason": "في أبي لهب وامرأته"},
    {"surah": "النصر", "ayah": 1, "text": "إِذَا جَاءَ نَصْرُ اللَّهِ", "reason": "في حجة الوداع إيذاناً بأجل النبي"},
    {"surah": "الإخلاص", "ayah": 1, "text": "قُلْ هُوَ اللَّهُ أَحَدٌ", "reason": "سأل المشركون عن صفة ربه"},
    {"surah": "الفاتحة", "ayah": 1, "text": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", "reason": "أم الكتاب وأول سورة في المصحف"}
  ]
}''';
      final data = jsonDecode(jsonStr);
      _stories = List<Map<String, dynamic>>.from(data['stories']);
      _hadiths = List<Map<String, dynamic>>.from(data['hadiths']);
      _revelationReasons = List<Map<String, dynamic>>.from(data['revelation_reasons']);
    } catch (e) {
      debugPrint('Error loading database: $e');
    }
    notifyListeners();
  }

  Future<void> _loadTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    final String? saved = prefs.getString('translation_history');
    if (saved != null) {
      try {
        _translations = List<Map<String, dynamic>>.from(
          (jsonDecode(saved) as List).map((e) => Map<String, dynamic>.from(e)),
        );
      } catch (_) {}
    }
  }

  Future<void> saveTranslation(String source, String translated,
      {String? sourceLang, String? targetLang}) async {
    _translations.insert(0, {
      'source': source,
      'translated': translated,
      'sourceLang': sourceLang ?? 'auto',
      'targetLang': targetLang ?? 'ar',
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (_translations.length > 50) _translations = _translations.sublist(0, 50);
    await _persistTranslations();
    notifyListeners();
  }

  Future<void> _persistTranslations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('translation_history', jsonEncode(_translations));
  }

  Map<String, dynamic> getRandomHadith() {
    if (_hadiths.isEmpty) return {'text': 'لا إله إلا الله', 'narrator': '', 'source': ''};
    final random = Random();
    return _hadiths[random.nextInt(_hadiths.length)];
  }

  Map<String, dynamic> getRandomStory() {
    if (_stories.isEmpty) return {'title': 'قصة', 'content': 'لم يتم تحميل القصص بعد'};
    final random = Random();
    return _stories[random.nextInt(_stories.length)];
  }

  Map<String, dynamic> getRandomAsbab() {
    if (_revelationReasons.isEmpty) {
      return {'surah': '', 'ayah': '', 'reason': '', 'text': 'لا توجد أسباب نزول متاحة'};
    }
    final random = Random();
    return _revelationReasons[random.nextInt(_revelationReasons.length)];
  }

  List<Map<String, dynamic>> getStoriesByCategory(String category) {
    return _stories.where((s) => s['category'] == category).toList();
  }
}
