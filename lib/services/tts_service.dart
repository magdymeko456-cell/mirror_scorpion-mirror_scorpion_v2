import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  double _volume = 1.0;
  double _rate = 0.5;
  double _pitch = 1.0;
  String _voice = 'ar-xa';

  bool get isSpeaking => _isSpeaking;
  double get volume => _volume;
  double get rate => _rate;
  double get pitch => _pitch;
  String get voice => _voice;

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

  Future<void> setVolume(double v) async {
    _volume = v;
    await _tts.setVolume(v);
    notifyListeners();
  }

  Future<void> setRate(double r) async {
    _rate = r;
    await _tts.setSpeechRate(r);
    notifyListeners();
  }

  Future<void> setPitch(double p) async {
    _pitch = p;
    await _tts.setPitch(p);
    notifyListeners();
  }

  /// هذه الدالة مطلوبة من settings_screen.dart
  Future<void> setVoice(String voice) async {
    _voice = voice;
    final map = {
      'ar-xa': 'ar',
      'en-US': 'en',
      'fr-FR': 'fr',
      'de-DE': 'de',
      'es-ES': 'es',
    };
    final lang = map[voice] ?? 'ar';
    await _tts.setLanguage(lang);
    notifyListeners();
  }
}
