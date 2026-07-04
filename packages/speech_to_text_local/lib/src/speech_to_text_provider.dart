import 'package:flutter/foundation.dart';
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';

/// Provides speech to text capabilities
class SpeechToTextProvider extends ChangeNotifier {
  SpeechToTextProvider() : _speechToText = SpeechToText();

  final SpeechToText _speechToText;

  /// Initialize speech recognition
  Future<bool> initialize(
    String? localeId,
    bool debugLogging,
    bool onDevice,
    String? options,
  ) async {
    return _speechToText.initialize(
      localeId: localeId,
      debugLogging: debugLogging,
      onDevice: onDevice,
      options: options,
    );
  }

  /// Start listening
  Future<bool> listen({
    String? localeId,
    void Function(SpeechRecognitionResult)? onResult,
    void Function(String)? onSoundLevelChange,
    void Function(String)? onStatus,
    void Function(String)? onError,
    bool partialResults = true,
    int? listenFor,
    int? pauseFor,
    String? locale,
    bool cancelOnError = true,
    double? sampleRate,
    int? maxAlternatives,
  }) async {
    return _speechToText.listen(
      localeId: localeId,
      onResult: onResult,
      onSoundLevelChange: onSoundLevelChange,
      onStatus: onStatus,
      onError: onError,
      partialResults: partialResults,
      listenFor: listenFor,
      pauseFor: pauseFor,
      cancelOnError: cancelOnError,
    );
  }

  /// Stop listening
  Future<void> stop() => _speechToText.stop();

  /// Cancel listening
  Future<void> cancel() => _speechToText.cancel();

  /// Get locales
  Future<List<LocaleName>> locales() => _speechToText.locales();

  /// Check if listening
  bool get isListening => _speechToText.isListening;

  /// Check if available
  bool get isAvailable => _speechToText.isAvailable;
}

/// Legacy SpeechToText class
class SpeechToText extends SpeechToTextProvider {
  SpeechToText() : super();
}
