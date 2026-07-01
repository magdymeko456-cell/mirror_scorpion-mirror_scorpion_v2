import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingBubbleService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isEnabled = false;
  bool _isVisible = false;
  double _opacity = 0.85;
  int _size = 60;

  bool get isEnabled => _isEnabled;
  bool get isVisible => _isVisible;
  double get opacity => _opacity;
  int get size => _size;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isEnabled = _prefs.getBool('floating_bubble_enabled') ?? false;
    _opacity = _prefs.getDouble('floating_bubble_opacity') ?? 0.85;
    _size = _prefs.getInt('floating_bubble_size') ?? 60;
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

  void toggleVisibility() {
    _isVisible = !_isVisible;
    notifyListeners();
  }

  Future<bool> startBubble() async {
    _isEnabled = true;
    await _prefs.setBool('floating_bubble_enabled', true);
    notifyListeners();
    try {
      await const MethodChannel('mirror_scorpion/overlay')
          .invokeMethod('createFloatingBubble', {
        'sourceLanguage': 'en',
        'targetLanguage': 'ar',
      });
      return true;
    } catch (e) {
      debugPrint('Bubble error: $e');
      return false;
    }
  }

  Future<bool> stopBubble() async {
    _isEnabled = false;
    await _prefs.setBool('floating_bubble_enabled', false);
    notifyListeners();
    try {
      await const MethodChannel('mirror_scorpion/overlay')
          .invokeMethod('destroyFloatingBubble');
      return true;
    } catch (e) {
      debugPrint('Bubble stop error: $e');
      return false;
    }
  }

  Future<void> setOpacity(double v) async {
    _opacity = v;
    await _prefs.setDouble('floating_bubble_opacity', v);
    notifyListeners();
  }

  Future<void> setSize(int v) async {
    _size = v;
    await _prefs.setInt('floating_bubble_size', v);
    notifyListeners();
  }
}
