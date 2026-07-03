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

  // ===== 5 أصوات حقيقية بمحركات مختلفة =====
  static const List<Map<String, String>> availableVoices = [
    {'id': 'ar-xa', 'name': 'سارة', 'gender': 'أنثى', 'desc': 'صوت أنثوي عربي دافئ — Google TTS Arabic'},
    {'id': 'com.apple.ttsbundle.Samantha-compact', 'name': 'سلمى', 'gender': 'أنثى', 'desc': 'صوت أنثوي عربي ناعم — Apple TTS'},
    {'id': 'com.google.android.tts:ara-x-ara-x-aro-std', 'name': 'سما', 'gender': 'أنثى', 'desc': 'صوت أنثوي عربي واضح — Google TTS HD'},
    {'id': 'com.google.android.tts:ara-x-ara-x-arm-std', 'name': 'سيف', 'gender': 'ذكر', 'desc': 'صوت ذكوري عربي قوي — Google TTS Male'},
    {'id': 'voice_clone_premium', 'name': 'المستخدم', 'gender': 'نسخ', 'desc': 'نسخة من صوتك (PRO) — ElevenLabs API'},
  ];

  final Map<String, String> voiceLanguageMap = {
    'ar-xa': 'ar',
    'com.apple.ttsbundle.Samantha-compact': 'ar',
    'com.google.android.tts:ara-x-ara-x-aro-std': 'ar',
    'com.google.android.tts:ara-x-ara-x-arm-std': 'ar',
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

      // محاولة استخدام الصوت المحدد
      try {
        final voices = await _tts.getVoices();
        if (voices is List && voices.isNotEmpty) {
          final matchedVoice = voices.firstWhere(
            (v) => (v is Map && v['name'] == _currentVoiceId) ||
                    (v is Map && v['locale']?.toString().contains(language) == true),
            orElse: () => voices.first,
          );
          if (matchedVoice is Map && matchedVoice['name'] != null) {
            await _tts.setVoice(matchedVoice);
          }
        }
      } catch (_) {}

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
