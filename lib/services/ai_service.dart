import 'dart:math';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AIService extends ChangeNotifier {
  late SharedPreferences _prefs;
  String _apiKey = '';
  String _selectedModel = 'gemini-pro';
  bool _isProcessing = false;
  String _lastResponse = '';

  bool get isProcessing => _isProcessing;
  String get selectedModel => _selectedModel;
  String get lastResponse => _lastResponse;

  // قاعدة بيانات الإلهام المحلية (مصادر إسلامية موثوقة)
  static final List<Map<String, String>> _inspirationDB = [
    {'text': 'وَمَا تَدْرِي نَفْسٌ مَّاذَا تَكْسِبُ غَدًا ۖ', 'source': 'سورة لقمان — 34'},
    {'text': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'source': 'سورة الشرح — 5-6'},
    {'text': 'لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا', 'source': 'سورة التوبة — 40'},
    {'text': 'وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ', 'source': 'سورة البقرة — 216'},
    {'text': 'إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنفُسِهِمْ', 'source': 'سورة الرعد — 11'},
    {'text': 'رَّبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي', 'source': 'سورة طه — 25-26'},
    {'text': 'أَحْسِنِ الظَّنَّ بِاللَّهِ', 'source': 'حديث قدسي — متفق عليه'},
    {'text': 'اليوم أنت أقوى مما كنت أمس، وغداً ستكون أقوى', 'source': 'إلهام ميرور'},
    {'text': 'البدايات الصغيرة تصنع نهايات عظيمة', 'source': 'إلهام ميرور'},
    {'text': 'الفشل ليس النهاية، بل درس جديد', 'source': 'إلهام ميرور'},
    {'text': 'الوقت هو أثمن ما تملك — استثمره', 'source': 'إلهام ميرور'},
    {'text': 'كل لحظة هي فرصة لبداية جديدة', 'source': 'إلهام ميرور'},
  ];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs.getString('ai_api_key') ?? '';
    _selectedModel = _prefs.getString('ai_model') ?? 'gemini-pro';
    notifyListeners();
  }

  Future<void> setApiKey(String key) async {
    _apiKey = key;
    await _prefs.setString('ai_api_key', key);
    notifyListeners();
  }

  String analyzeMood(String text) {
    final t = text.toLowerCase();
    if (t.contains('حزين') || t.contains('تعب') || t.contains('بكاء') || t.contains('خوف')) return 'حزين';
    if (t.contains('فرح') || t.contains('سعيد') || t.contains('نجاح')) return 'فرح';
    if (t.contains('غضب') || t.contains('ضيق') || t.contains('غاضب')) return 'غاضب';
    if (t.contains('خائف') || t.contains('قلق') || t.contains('توتر')) return 'خائف';
    if (t.contains('وحيد') || t.contains('وحدة')) return 'وحيد';
    return 'عام';
  }

  Future<String> generateInspiration({String? userMood, String? context, bool forceApi = false}) async {
    _isProcessing = true;
    notifyListeners();

    // Try Gemini API first if key is set
    if (_apiKey.isNotEmpty && forceApi) {
      try {
        final prompt = 'أنت مساعد إلهام إسلامي. اكتب رسالة إلهام قصيرة بالعربية '
            'مستوحاة من القرآن والسنة. حالة المستخدم: ${userMood ?? "عامة"}. السياق: ${context ?? "حياة يومية"}.';
        final result = await _callGemini(prompt);
        if (result.isNotEmpty) {
          _lastResponse = result;
          _isProcessing = false;
          notifyListeners();
          return result;
        }
      } catch (_) {}
    }

    // Local fallback — smart selection
    await Future.delayed(const Duration(milliseconds: 400));
    final random = Random();
    final mood = (userMood ?? '').toLowerCase();
    int index;
    if (mood.contains('حزين') || mood.contains('تعب') || mood.contains('خائف')) {
      index = [0, 2, 6][random.nextInt(3)]; // طمأنينة
    } else if (mood.contains('فرح') || mood.contains('سعيد')) {
      index = [3, 7, 9][random.nextInt(3)]; // شكر
    } else if (mood.contains('غضب') || mood.contains('ضيق')) {
      index = [4, 8][random.nextInt(2)]; // صبر
    } else if (mood.contains('وحيد')) {
      index = [5, 10, 11][random.nextInt(3)]; // أمل
    } else {
      index = random.nextInt(_inspirationDB.length);
    }
    final entry = _inspirationDB[index];
    _lastResponse = '${entry['text']}\n\n— ${entry['source']}';
    _isProcessing = false;
    notifyListeners();
    return _lastResponse;
  }

  Future<String> _callGemini(String prompt) async {
    if (_apiKey.isEmpty) return '';
    try {
      final uri = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/${_selectedModel}:generateContent?key=$_apiKey');
      final resp = await http.post(uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'contents': [{'parts': [{'text': prompt}]}], 'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 200}}),
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        return data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String? ?? '';
      }
    } catch (_) {}
    return '';
  }

  Future<String> enhanceStory(String story) async {
    if (_apiKey.isNotEmpty) {
      try {
        final result = await _callGemini('حسّن القصة التالية وأثرها:\n\n$story');
        if (result.isNotEmpty) return result;
      } catch (_) {}
    }
    return '$story\n\n🦂 — Mirror Scorpion AI';
  }

  Future<String> generateVideoScript(String title) async {
    if (_apiKey.isNotEmpty) {
      try {
        final result = await _callGemini('اكتب سكريبت فيديو لقصة "$title" مقسم لمشاهد مع حوار');
        if (result.isNotEmpty) return result;
      } catch (_) {}
    }
    return '🎬 سكريبت "$title":\nالمشهد الأول: مقدمة\nالمشهد الثاني: أحداث\nالمشهد الثالث: ذروة\nالمشهد الرابع: نهاية وعبرة';
  }
}
