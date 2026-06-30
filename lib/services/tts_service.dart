import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  double _volume = 1.0;
  double _rate = 0.5;
  double _pitch = 1.0;
  String _voice = 'ar-xa';
  String _selectedVoiceName = 'سارة';

  bool get isSpeaking => _isSpeaking;
  double get volume => _volume;
  double get rate => _rate;
  double get pitch => _pitch;
  String get voice => _voice;
  String get selectedVoiceName => _selectedVoiceName;

  TTSService() {
    _tts.setCompletionHandler(() { _isSpeaking = false; notifyListeners(); });
    _tts.setErrorHandler((_) { _isSpeaking = false; notifyListeners(); });
  }

  Future<void> speak(String text, {String language = 'ar'}) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    notifyListeners();
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(_rate);
    await _tts.setVolume(_volume);
    await _tts.setPitch(_pitch);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> setVolume(double v) async { _volume = v; await _tts.setVolume(v); notifyListeners(); }
  Future<void> setRate(double r) async { _rate = r; await _tts.setSpeechRate(r); notifyListeners(); }
  Future<void> setPitch(double p) async { _pitch = p; await _tts.setPitch(p); notifyListeners(); }

  /// الأصوات الخمسة: سيف, سلمى, سما, سارة, صوت المستخدم
  static const Map<String, String> voices = {
    'سارة': 'ar-xa',
    'سيف': 'ar-xa',
    'سلمى': 'ar-xa',
    'سما': 'ar-xa',
    'صوت المستخدم': 'ar-xa',
  };

  static const Map<String, String> voiceLanguages = {
    'ar-xa': 'ar',
    'en-US': 'en',
    'fr-FR': 'fr',
    'de-DE': 'de',
    'es-ES': 'es',
  };

  Future<void> setVoice(String voiceCode) async {
    _voice = voiceCode;
    _selectedVoiceName = voices.entries
        .firstWhere((e) => e.value == voiceCode,
            orElse: () => MapEntry('سارة', 'ar-xa'))
        .key;
    final lang = voiceLanguages[voiceCode] ?? 'ar';
    await _tts.setLanguage(lang);
    notifyListeners();
  }
}
