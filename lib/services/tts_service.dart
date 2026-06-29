import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _selectedVoice = 'voice_salma';
  double _speed = 0.5;

  static const List<Map<String, String>> availableVoices = [
    {'id': 'voice_seif',  'name': 'سيف', 'desc': 'خشن/عميق'},
    {'id': 'voice_salma', 'name': 'سلمى', 'desc': 'متزن'},
    {'id': 'voice_sama',  'name': 'سما',  'desc': 'دافئ/ناعم'},
    {'id': 'voice_sara',  'name': 'سارة', 'desc': 'رقيق'},
    {'id': 'voice_user',  'name': 'صوت المستخدم', 'desc': 'مميز (Pro)'},
  ];

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get selectedVoice => _selectedVoice;
  double get speed => _speed;
  List<Map<String, String>> get voices => availableVoices;

  TTSService() { _initTts(); }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() { _isSpeaking = false; notifyListeners(); });
    _flutterTts.setErrorHandler((msg) { _isSpeaking = false; debugPrint('TTS Error: $msg'); notifyListeners(); });
  }

  void setSpeed(double value) {
    _speed = value;
    _flutterTts.setSpeechRate(value);
    notifyListeners();
  }

  Future<void> setVoice(String voiceId) async {
    _selectedVoice = voiceId;
    switch (voiceId) {
      case 'voice_seif':  await _flutterTts.setPitch(0.7); await _flutterTts.setSpeechRate(0.4); break;
      case 'voice_salma': await _flutterTts.setPitch(1.0); await _flutterTts.setSpeechRate(0.5); break;
      case 'voice_sama':  await _flutterTts.setPitch(1.2); await _flutterTts.setSpeechRate(0.42); break;
      case 'voice_sara':  await _flutterTts.setPitch(1.5); await _flutterTts.setSpeechRate(0.48); break;
      case 'voice_user':  await _flutterTts.setPitch(1.0); await _flutterTts.setSpeechRate(0.5); break;
    }
    notifyListeners();
  }

  Future<void> speak(String text, {String? language}) async {
    if (_isSpeaking) await stop();
    _isSpeaking = true;
    notifyListeners();
    await _flutterTts.setLanguage(language ?? 'ar');
    await _flutterTts.speak(text);
  }

  Future<void> stop() async { await _flutterTts.stop(); _isSpeaking = false; _isPaused = false; notifyListeners(); }
  Future<void> pause() async { await _flutterTts.pause(); _isPaused = true; notifyListeners(); }
  Future<void> resume() async { _isPaused = false; notifyListeners(); }

  Future<List<dynamic>> getAvailableLanguages() async => await _flutterTts.getLanguages;

  @override
  void dispose() { _flutterTts.stop(); super.dispose(); }
}
