import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();

  Future<void> speak(String text, {String? language}) async {
    if (text.isEmpty) return;
    if (language != null) await _flutterTts.setLanguage(language);
    await _flutterTts.speak(text);
  }

  Future<void> setVoice(String voiceName) async {
    final voices = await _flutterTts.getVoices;
    for (final voice in voices) {
      if (voice['name'] == voiceName) {
        await _flutterTts.setVoice(voice);
        break;
      }
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
