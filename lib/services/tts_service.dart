import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _selectedVoice = 'voice_salma';
  double _speed = 0.5;

  static const List<Map<String, String>> availableVoices = [
    {'id': 'voice_seif',  'name': 'سيف',    'desc': 'خشن/عميق — مناسب للأخبار'},
    {'id': 'voice_salma', 'name': 'سلمى',   'desc': 'متزن — مناسب للترجمة العامة'},
    {'id': 'voice_sama',  'name': 'سما',    'desc': 'دافئ/ناعم — مناسب للقصص'},
    {'id': 'voice_sara',  'name': 'سارة',   'desc': 'رقيق — مناسب للمستندات'},
    {'id': 'voice_user',  'name': 'صوت المستخدم', 'desc': 'مميز (Pro) — استنساخ بصوتك'},
  ];

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get selectedVoice => _selectedVoice;
  double get speed => _speed;
  List<Map<String, String>> get voices => availableVoices;

  TTSService() {
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(_speed);
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _isPaused = false;
      notifyListeners();
    });
  }

  void setVoice(String voiceId) {
    _selectedVoice = voiceId;
    notifyListeners();
    if (voiceId == 'voice_seif') {
      _flutterTts.setPitch(0.8);
      _flutterTts.setSpeechRate(_speed + 0.2);
    } else if (voiceId == 'voice_salma') {
      _flutterTts.setPitch(1.0);
      _flutterTts.setSpeechRate(_speed);
    } else if (voiceId == 'voice_sama') {
      _flutterTts.setPitch(1.2);
      _flutterTts.setSpeechRate(_speed - 0.1);
    } else if (voiceId == 'voice_sara') {
      _flutterTts.setPitch(1.4);
      _flutterTts.setSpeechRate(_speed - 0.15);
    } else if (voiceId == 'voice_user') {
      _flutterTts.setPitch(1.0);
      _flutterTts.setSpeechRate(_speed);
    }
  }

  Future<void> speak(String text) async {
    _isSpeaking = true;
    _isPaused = false;
    notifyListeners();
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
    await _flutterTts.speak('');
    _isPaused = false;
    notifyListeners();
  }

  void setSpeed(double val) {
    _speed = val;
    _flutterTts.setSpeechRate(val);
    notifyListeners();
  }
}
