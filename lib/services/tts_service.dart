import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String _activeVoice = 'سيف';

  // 5 أصوات: سيف، سلمى، سما، سارة، صوت المستخدم
  final List<Map<String, String>> voices = [
    {'name': 'سيف', 'lang': 'ar-SA', 'gender': 'male'},
    {'name': 'سلمى', 'lang': 'ar-SA', 'gender': 'female'},
    {'name': 'سما', 'lang': 'ar-SA', 'gender': 'female'},
    {'name': 'سارة', 'lang': 'ar-SA', 'gender': 'female'},
    {'name': 'صوت المستخدم', 'lang': 'ar-SA', 'gender': 'male'},
  ];

  TTSService() {
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  bool get isSpeaking => _isSpeaking;
  String get activeVoice => _activeVoice;

  Future<void> speak(String text, {String language = 'ar', String? voice}) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    notifyListeners();
    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(voice == 'female' ? 1.5 : 1.0);
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> setVoice(String voiceName) async {
    _activeVoice = voiceName;
    notifyListeners();
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }
}
