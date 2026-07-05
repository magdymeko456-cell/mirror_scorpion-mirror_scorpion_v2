import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/foundation.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;

  // الأصوات الخمسة
  final List<Map<String, String>> voices = const [
    {'name': 'سيف', 'id': 'ar-x-saf-standard'},
    {'name': 'سلمى', 'id': 'ar-x-slm-standard'},
    {'name': 'سما', 'id': 'ar-x-sma-standard'},
    {'name': 'سارة', 'id': 'ar-x-sar-standard'},
    {'name': 'صوت المستخدم', 'id': 'user'},
  ];

  String _currentVoice = 'ar-x-saf-standard';
  String get currentVoice => _currentVoice;

  TTSService() {
    _tts.setCompletionHandler(() { _isSpeaking = false; notifyListeners(); });
  }

  Future<void> speak(String text, {String language = 'ar'}) async {
    await _tts.setLanguage(language);
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.speak(text);
    _isSpeaking = true;
    notifyListeners();
  }

  Future<void> stop() async { await _tts.stop(); _isSpeaking = false; notifyListeners(); }
  Future<void> setVoice(String voiceId) async { _currentVoice = voiceId; notifyListeners(); }
}
