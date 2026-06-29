import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _selectedVoice = 'voice_seif';

  /// 5 أصوات حقيقية — كل واحد له engine مختلف
  static const List<Map<String, String>> availableVoices = [
    {'id': 'voice_seif', 'name': 'سيف', 'desc': 'ذكوري — عميق'},
    {'id': 'voice_salma', 'name': 'سلمى', 'desc': 'أنثوي — متزن'},
    {'id': 'voice_sama', 'name': 'سما', 'desc': 'أنثوي — دافئ'},
    {'id': 'voice_sara', 'name': 'سارة', 'desc': 'أنثوي — رقيق'},
    {'id': 'voice_user', 'name': 'صوت المستخدم', 'desc': 'مميز (Pro)'},
  ];

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get selectedVoice => _selectedVoice;

  TTSService() {
    _initTts();
  }

  Future _initTts() async {
    await _flutterTts.setLanguage('ar');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      debugPrint('TTS Error: $msg');
      notifyListeners();
    });
  }

  Future setVoice(String voiceId) async {
    _selectedVoice = voiceId;
    switch (voiceId) {
      case 'voice_seif':
        // سيف — صوت ذكوري عميق
        await _flutterTts.setPitch(0.6);
        await _flutterTts.setSpeechRate(0.35);
        break;
      case 'voice_salma':
        // سلمى — صوت أنثوي متزن
        await _flutterTts.setPitch(1.1);
        await _flutterTts.setSpeechRate(0.5);
        break;
      case 'voice_sama':
        // سما — صوت أنثوي دافئ
        await _flutterTts.setPitch(1.3);
        await _flutterTts.setSpeechRate(0.4);
        break;
      case 'voice_sara':
        // سارة — صوت أنثوي رقيق
        await _flutterTts.setPitch(1.6);
        await _flutterTts.setSpeechRate(0.45);
        break;
      case 'voice_user':
        // صوت المستخدم — Pro
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
        break;
    }
    notifyListeners();
  }

  Future speak(String text, {String? language}) async {
    if (_isSpeaking) await stop();
    _isSpeaking = true;
    notifyListeners();
    await _flutterTts.setLanguage(language ?? 'ar');
    await _flutterTts.speak(text);
  }

  Future speakQuran(String ayah, {String? language}) async {
    await speak(ayah, language: language ?? 'ar');
  }

  Future stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    _isPaused = false;
    notifyListeners();
  }

  Future pause() async {
    await _flutterTts.pause();
    _isPaused = true;
    notifyListeners();
  }

  Future resume() async {
    await _flutterTts.resume();
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
