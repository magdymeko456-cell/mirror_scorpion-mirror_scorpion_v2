import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text, {required String languageCode}) async {
    if (text.isEmpty) return;
    await _flutterTts.setLanguage(languageCode);
    await _flutterTts.speak(text);
  }
}
