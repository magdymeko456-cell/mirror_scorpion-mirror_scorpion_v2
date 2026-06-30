import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingBubbleService extends ChangeNotifier {
  static const platform = MethodChannel('com.mirror.scorpion.v2/overlay');

  bool _isStarted = false;
  double _opacity = 0.8;

  bool get isStarted => _isStarted;
  double get opacity => _opacity;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isStarted = prefs.getBool('bubble_active') ?? false;
    _opacity = prefs.getDouble('bubble_opacity') ?? 0.8;
  }

  Future<void> requestOverlayPermission() async {
    try {
      await platform.invokeMethod('requestOverlay');
    } catch (_) {}
  }

  Future<bool> isOverlayGranted() async {
    try {
      return await platform.invokeMethod('isOverlayGranted') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> startBubble(BuildContext context) async {
    _isStarted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bubble_active', true);
    notifyListeners();
  }

  Future<void> stopBubble() async {
    _isStarted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bubble_active', false);
    notifyListeners();
  }

  void toggle() {
    if (_isStarted) {
      _isStarted = false;
    } else {
      _isStarted = true;
    }
    notifyListeners();
  }

  Future<void> setOpacity(double value) async {
    _opacity = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bubble_opacity', value);
    notifyListeners();
  }
}
