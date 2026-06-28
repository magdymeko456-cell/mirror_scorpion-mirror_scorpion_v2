import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة الذكاء الاصطناعي المُحسّنة - مانوس إنتليجنس
class AIEnhancedService extends ChangeNotifier {
  static final AIEnhancedService _instance = AIEnhancedService._internal();
  factory AIEnhancedService() => _instance;
  AIEnhancedService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;
  bool _autoInspirationEnabled = false;
  DateTime _lastInspirationTime = DateTime.now().subtract(const Duration(hours: 3));
  
  // تحليل الحالة النفسية
  String _detectedMood = 'محايد';
  String _lastStoryFocus = '';
  int _storyViewCount = 0;
  
  // قواعد بيانات للرسائل الملهمة حسب الحالة
  static const Map<String, List<String>> _moodMessages = {
    'حزين': [
      'أعلم أن الأوقات صعبة، ولكن تذكر أن الله لا يكلف نفساً إلا وسعها. أنت قادر على تخطي هذه المحنة.',
      'كل انكسار هو بداية لانطلاقة أعظم. قال تعالى: {إِنَّ مَعَ الْعُسْرِ يُسْرًا}',
      'لا تيأس، فالنور يأتي بعد الظلام. استعن بالله ولا تعجز.',
      'الدموع ليست ضعفاً، إنها دليل على أن قلبك مازال نابضاً بالحياة.',
      'تذكر: ما كان الله ليجمع بين هم الدنيا وهم الآخرة على عبد مؤمن.',
    ],
    'فرح': [
      'الحمد لله على نعمة الفرح. تذكر أن تبقى متواضعاً في نجاحك، وأن تشكر الله على ما أعطاك.',
      'الفرح الحقيقي هو في مشاركته مع الآخرين. استخدم ما وهبك الله لخدمة من حولك.',
      'لا يغرنك الفرح فتنسى الشكر، ولا يغرنك النجاح فتنسى التواضع.',
      'اجعل فرحك شكراً، ونجاحك تواضعاً، وعطاءك استمراراً.',
    ],
    'قلق': [
      'لا تقلق، فالله يدبر الأمور على أكمل وجه. توكل عليه وستجد الراحة.',
      'القلق لا يغير شيئاً، لكن الثقة بالله تغير كل شيء.',
      'خذ نفساً عميقاً. أنت قادر على التعامل مع هذا الموقف.',
      'قال تعالى: {وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ}',
    ],
    'محايد': [
      'كل يوم هو فرصة جديدة لبداية جديدة. استثمر وقتك في بناء نفسك.',
      'الوقت هو العملة الأغلى التي مُنحت للإنسان. استثمر كل ثانية.',
      'تذكّر دائماً.. قصتك لا تزال تُكتب، والنهاية لم يحن وقتها بعد.',
      'أنت أقوى مما تتصور، وأعظم مما تتخيل.',
    ],
  };

  Future initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _autoInspirationEnabled = _prefs.getBool('auto_inspiration') ?? false;
    _lastInspirationTime = DateTime.parse(
      _prefs.getString('last_inspiration_time') ?? DateTime.now().subtract(const Duration(hours: 3)).toIso8601String()
    );
    _isInitialized = true;
    notifyListeners();
  }

  bool get autoInspirationEnabled => _autoInspirationEnabled;
  String get detectedMood => _detectedMood;
  String get lastStoryFocus => _lastStoryFocus;

  Future<void> toggleAutoInspiration(bool value) async {
    _autoInspirationEnabled = value;
    await _prefs.setBool('auto_inspiration', value);
    notifyListeners();
  }

  /// يحلل مزاج المستخدم من النص
  String analyzeMood(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('حزين') || lower.contains('تعب') || lower.contains('ضيق') || 
        lower.contains('alone') || lower.contains('sad') || lower.contains('tired')) {
      return 'حزين';
    }
    if (lower.contains('فرح') || lower.contains('سعيد') || lower.contains('نجاح') || 
        lower.contains('happy') || lower.contains('success')) {
      return 'فرح';
    }
    if (lower.contains('قلق') || lower.contains('خائف') || lower.contains('worried') || 
        lower.contains('anxious') || lower.contains('afraid')) {
      return 'قلق';
    }
    return 'محايد';
  }

  /// توليد رسالة ملهمة
  Future<String> generateInspiration({required String userMood, required String context}) async {
    final mood = analyzeMood(userMood.isNotEmpty ? userMood : _detectedMood);
    _detectedMood = mood;
    final messages = _moodMessages[mood] ?? _moodMessages['محايد']!;
    final random = Random();
    await Future.delayed(Duration(milliseconds: 300 + random.nextInt(500)));
    return messages[random.nextInt(messages.length)] + '\n\n- مانوس إنتليجنس';
  }

  /// التحقق من إمكانية إرسال رسالة ملهمة (مرة كل 3 ساعات)
  bool canSendInspiration() {
    if (!_autoInspirationEnabled) return false;
    return DateTime.now().difference(_lastInspirationTime).inHours >= 3;
  }

  /// تسجيل إرسال رسالة ملهمة
  Future<void> markInspirationSent() async {
    _lastInspirationTime = DateTime.now();
    await _prefs.setString('last_inspiration_time', _lastInspirationTime.toIso8601String());
  }

  /// تتبع القصص التي يقرأها المستخدم
  Future<void> trackStoryView(String storyTitle) async {
    if (_lastStoryFocus == storyTitle) {
      _storyViewCount++;
    } else {
      _lastStoryFocus = storyTitle;
      _storyViewCount = 1;
    }
    await _prefs.setString('last_story_focus', storyTitle);
    await _prefs.setInt('story_view_count', _storyViewCount);
  }

  /// توليد فيديو من نص قصة (API simulation)
  Future<String> generateVideoFromStory(String storyText) async {
    await Future.delayed(const Duration(seconds: 3));
    return 'video_story_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  /// الترجمة باستخدام الذكاء الاصطناعي
  Future<String> aiTranslate(String text, String targetLang) async {
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}'
      );
      final http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[0] as List).map((e) => e[0] as String).join();
      }
    } catch (e) {
      debugPrint('AI Translate error: $e');
    }
    return text;
  }
}
