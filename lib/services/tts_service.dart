import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  double _volume = 1.0, _rate = 0.5, _pitch = 1.0;
  String _currentVoiceId = 'ar-xa';
  String _currentVoiceName = 'سارة';
  int _currentVoiceIndex = 0;

  bool get isSpeaking => _isSpeaking;
  double get volume => _volume;
  double get rate => _rate;
  double get pitch => _pitch;
  String get currentVoiceId => _currentVoiceId;
  String get currentVoiceName => _currentVoiceName;
  int get currentVoiceIndex => _currentVoiceIndex;

  // ===== 5 أصوات =====
  static const List<Map<String, String>> availableVoices = [
    {'id': 'ar-xa', 'name': 'سارة', 'gender': 'أنثى', 'desc': 'صوت أنثوي عربي دافئ'},
    {'id': 'ar-xa-warm', 'name': 'سلمى', 'gender': 'أنثى', 'desc': 'صوت أنثوي عربي ناعم'},
    {'id': 'ar-xa-female', 'name': 'سما', 'gender': 'أنثى', 'desc': 'صوت أنثوي عربي واضح'},
    {'id': 'ar-xa-male', 'name': 'سيف', 'gender': 'ذكر', 'desc': 'صوت ذكوري عربي قوي'},
    {'id': 'voice_clone_premium', 'name': 'المستخدم', 'gender': 'نسخ', 'desc': 'نسخة من صوتك (PRO)'},
  ];

  final Map<String, String> voiceLanguageMap = {
    'ar-xa': 'ar',
    'ar-xa-warm': 'ar',
    'ar-xa-female': 'ar',
    'ar-xa-male': 'ar',
    'voice_clone_premium': 'ar',
  };

  TTSService() {
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _tts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      _isSpeaking = false;
      notifyListeners();
    });
  }

  /// النطق مع دعم اللغة والصوت المحدد
  Future<void> speak(String text, {String language = 'ar'}) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    notifyListeners();

    try {
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(_rate);
      await _tts.setVolume(_volume);
      await _tts.setPitch(_pitch);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS Speak Error: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// إيقاف النطق
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  /// تعيين الصوت المحدد
  Future<void> setVoice(String voiceId) async {
    _currentVoiceId = voiceId;
    final found = availableVoices.indexWhere((v) => v['id'] == voiceId);
    if (found >= 0) {
      _currentVoiceName = availableVoices[found]['name']!;
      _currentVoiceIndex = found;
    }
    final lang = voiceLanguageMap[voiceId] ?? 'ar';
    await _tts.setLanguage(lang);
    notifyListeners();
  }

  /// التبديل للصوت التالي
  Future<void> nextVoice() async {
    _currentVoiceIndex = (_currentVoiceIndex + 1) % availableVoices.length;
    await setVoice(availableVoices[_currentVoiceIndex]['id']!);
  }

  /// التبديل للصوت السابق
  Future<void> previousVoice() async {
    _currentVoiceIndex = (_currentVoiceIndex - 1 + availableVoices.length) % availableVoices.length;
    await setVoice(availableVoices[_currentVoiceIndex]['id']!);
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    await _tts.setVolume(_volume);
    notifyListeners();
  }

  Future<void> setRate(double r) async {
    _rate = r.clamp(0.0, 1.0);
    await _tts.setSpeechRate(_rate);
    notifyListeners();
  }

  Future<void> setPitch(double p) async {
    _pitch = p.clamp(0.5, 2.0);
    await _tts.setPitch(_pitch);
    notifyListeners();
  }
}
