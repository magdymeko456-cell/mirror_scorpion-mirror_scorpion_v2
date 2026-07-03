import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  double _volume = 1.0, _rate = 0.5, _pitch = 1.0;
  String _currentVoiceId = 'ar-xa';
  String _currentVoiceName = 'سارة';

  bool get isSpeaking => _isSpeaking;
  double get volume => _volume;
  double get rate => _rate;
  double get pitch => _pitch;
  String get currentVoiceId => _currentVoiceId;
  String get currentVoiceName => _currentVoiceName;

  static const List<Map<String, String>> availableVoices = [
    {'id': 'ar-xa', 'name': 'سارة', 'gender': 'أنثى', 'lang': 'ar'},
    {'id': 'ar-xa-female', 'name': 'سلمى', 'gender': 'أنثى', 'lang': 'ar'},
    {'id': 'ar-xa-male', 'name': 'سيف', 'gender': 'ذكر', 'lang': 'ar'},
    {'id': 'ar-xa-warm', 'name': 'سما', 'gender': 'أنثى', 'lang': 'ar'},
    {'id': 'voice_premium_clone', 'name': 'صوت المستخدم', 'gender': 'نسخ', 'lang': 'ar'},
  ];

  final Map<String, String> voiceLanguageMap = {
    'ar-xa': 'ar', 'ar-xa-female': 'ar', 'ar-xa-male': 'ar',
    'ar-xa-warm': 'ar', 'voice_premium_clone': 'ar',
    'en-US': 'en', 'fr-FR': 'fr', 'de-DE': 'de', 'es-ES': 'es',
  };

  TTSService() {
    _tts.setCompletionHandler(() { _isSpeaking = false; notifyListeners(); });
    _tts.setErrorHandler((_) { _isSpeaking = false; notifyListeners(); });
  }

  Future speak(String text, {String language = 'ar'}) async {
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
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  Future setVoice(String voiceId) async {
    _currentVoiceId = voiceId;
    final found = availableVoices.firstWhere(
      (v) => v['id'] == voiceId,
      orElse: () => availableVoices[0],
    );
    _currentVoiceName = found['name']!;
    final lang = voiceLanguageMap[voiceId] ?? 'ar';
    await _tts.setLanguage(lang);
    notifyListeners();
  }

  Future setVolume(double v) async { _volume = v; await _tts.setVolume(v); notifyListeners(); }
  Future setRate(double r) async { _rate = r; await _tts.setSpeechRate(r); notifyListeners(); }
  Future setPitch(double p) async { _pitch = p; await _tts.setPitch(p); notifyListeners(); }


}
