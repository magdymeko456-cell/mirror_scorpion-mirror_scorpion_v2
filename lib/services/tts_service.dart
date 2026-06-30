import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// خدمة النطق الصوتي - تدعم 5 أصوات (سيف، سلمى، سما، سارة، صوت المستخدم)
class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _selectedVoice = 'voice_2_male'; // سيف افتراضياً

  // الأصوات الخمسة المطلوبة
  static const List<Map<String, String>> availableVoices = [
    {'id': 'voice_2_male', 'name': 'سيف', 'desc': 'صوت رجالي عميق وقوي'},
    {'id': 'voice_1_female', 'name': 'سلمى', 'desc': 'صوت نسائي هادئ ومتزن'},
    {'id': 'voice_3_female_warm', 'name': 'سما', 'desc': 'صوت ناعم دافئ وسريع'},
    {'id': 'voice_4_female_soft', 'name': 'سارة', 'desc': 'صوت رقيق للمستندات'},
    {'id': 'voice_5_premium_ai', 'name': 'صوت المستخدم', 'desc': 'نسخ صوتك بالذكاء الاصطناعي (PRO)'},
  ];

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get selectedVoice => _selectedVoice;

  TTSService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);

    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      debugPrint('TTS Error: $msg');
      notifyListeners();
    });
    _flutterTts.setCancelHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  Future<void> setVoice(String voiceId) async {
    _selectedVoice = voiceId;

    switch (voiceId) {
      case 'voice_1_female': // سلمى - هادئ
        await _flutterTts.setPitch(1.2);
        await _flutterTts.setSpeechRate(0.45);
        break;
      case 'voice_2_male': // سيف - عميق
        await _flutterTts.setPitch(0.7);
        await _flutterTts.setSpeechRate(0.4);
        break;
      case 'voice_3_female_warm': // سما - دافئ سريع
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.65);
        break;
      case 'voice_4_female_soft': // سارة - رقيق
        await _flutterTts.setPitch(1.35);
        await _flutterTts.setSpeechRate(0.5);
        break;
      case 'voice_5_premium_ai': // صوت المستخدم
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
        break;
    }
    notifyListeners();
  }

  Future<void> speak(String text, {String? language}) async {
    if (_isSpeaking) {
      await stop();
    }
    _isSpeaking = true;
    notifyListeners();

    if (language != null && language.isNotEmpty) {
      try {
        await _flutterTts.setLanguage(language);
      } catch (e) {
        await _flutterTts.setLanguage('ar');
      }
    } else {
      await _flutterTts.setLanguage('ar');
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    _isPaused = false;
    notifyListeners();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
    _isPaused = true;
    notifyListeners();
  }

  Future<void> resume() async {
    _isPaused = false;
    notifyListeners();
  }

  Future<List<String>> getAvailableLanguages() async {
    return await _flutterTts.getLanguages;
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
