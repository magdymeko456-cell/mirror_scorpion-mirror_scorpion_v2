import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingBubbleService extends ChangeNotifier {
  bool _isEnabled = false, _isStarted = false, _autoTranslate = true, _isOverlayVisible = false;
  double _opacity = 0.8, _bubbleSize = 60;
  String _sourceLang = 'auto', _targetLang = 'ar';
  static const MethodChannel _channel = MethodChannel('mirror_scorpion/overlay');
  final StreamController<Map<String, dynamic>> _cmdCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get commands => _cmdCtrl.stream;
  bool get isEnabled => _isEnabled; bool get isStarted => _isStarted; double get opacity => _opacity;
  double get bubbleSize => _bubbleSize; bool get autoTranslate => _autoTranslate;
  bool get isOverlayVisible => _isOverlayVisible; String get sourceLang => _sourceLang; String get targetLang => _targetLang;

  Future<void> initialize() async { _isEnabled = true; _isStarted = false; notifyListeners(); }

  Future<void> startBubble() async {
    try { await _channel.invokeMethod('createFloatingBubble', {'sourceLanguage': _sourceLang, 'targetLanguage': _targetLang});
      _isStarted = true; _isEnabled = true; _isOverlayVisible = true;
      _cmdCtrl.add({'action':'show','sourceLang':_sourceLang,'targetLang':_targetLang}); notifyListeners();
    } catch (e) { debugPrint('Bubble Error: $e'); }
  }

  Future<void> stopBubble() async { try { await _channel.invokeMethod('destroyFloatingBubble'); } catch (_) {}
    _isStarted = false; _isOverlayVisible = false; _cmdCtrl.add({'action':'hide'}); notifyListeners(); }

  void toggleBubble() { if (_isStarted) stopBubble(); else startBubble(); }
  void onBubbleClosed() { _isStarted = false; _isOverlayVisible = false; _cmdCtrl.add({'action':'restore_original'}); notifyListeners(); }
  void setSourceLang(String l) { _sourceLang = l; _cmdCtrl.add({'action':'update_lang','sourceLang':l}); notifyListeners(); }
  void setTargetLang(String l) { _targetLang = l; _cmdCtrl.add({'action':'update_lang','targetLang':l}); notifyListeners(); }
  void setOpacity(double v) { _opacity = v; notifyListeners(); }
  void setBubbleSize(double v) { _bubbleSize = v; notifyListeners(); }
  void setAutoTranslate(bool v) { _autoTranslate = v; _cmdCtrl.add({'action':'auto_translate','enabled':v}); notifyListeners(); }
  @override void dispose() { _cmdCtrl.close(); super.dispose(); }
}
