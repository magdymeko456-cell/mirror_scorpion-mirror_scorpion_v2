import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingBubbleService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isEnabled = false;
  bool _isStarted = false;

  bool get isEnabled => _isEnabled;
  bool get isStarted => _isStarted;

  Future initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isEnabled = _prefs.getBool('floating_bubble_enabled') ?? false;
    notifyListeners();
  }

  void toggle() {
    _isEnabled = !_isEnabled;
    _prefs.setBool('floating_bubble_enabled', _isEnabled);
    if (_isEnabled) {
      startBubble();
    } else {
      stopBubble();
    }
    notifyListeners();
  }

  Future<bool> startBubble([BuildContext? context]) async {
    _isStarted = true;
    _isEnabled = true;
    await _prefs.setBool('floating_bubble_enabled', true);
    notifyListeners();
    try {
      await const MethodChannel('mirror_scorpion/overlay').invokeMethod('createFloatingBubble', {
        'sourceLanguage': 'ar',
        'targetLanguage': 'en',
      });
      return true;
    } catch (e) {
      debugPrint('FloatingBubble start error: $e');
      return false;
    }
  }

  Future<bool> stopBubble() async {
    _isStarted = false;
    _isEnabled = false;
    await _prefs.setBool('floating_bubble_enabled', false);
    notifyListeners();
    try {
      await const MethodChannel('mirror_scorpion/overlay').invokeMethod('destroyFloatingBubble');
      return true;
    } catch (e) {
      debugPrint('FloatingBubble stop error: $e');
      return false;
    }
  }
}
