import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingBubbleService extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _isEnabled = false;
  bool _isStarted = false;
  double _opacity = 0.85;
  double _size = 55;

  bool get isEnabled => _isEnabled;
  bool get isStarted => _isStarted;
  double get opacity => _opacity;
  double get size => _size;

  static const MethodChannel _channel = MethodChannel('mirror_scorpion/overlay');

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isEnabled = _prefs?.getBool('floating_bubble_enabled') ?? false;
    _isStarted = _isEnabled;
    _opacity = _prefs?.getDouble('floating_bubble_opacity') ?? 0.85;
    _size = (_prefs?.getDouble('floating_bubble_size') ?? 55);
    if (_isEnabled && _isStarted) {
      try { await _channel.invokeMethod('createFloatingBubble'); } catch (_) {}
    }
    notifyListeners();
  }

  void toggle() {
    if (_isEnabled) { stopBubble(); } else { startBubble(); }
  }

  Future<bool> startBubble() async {
    _isEnabled = true; _isStarted = true;
    await _prefs?.setBool('floating_bubble_enabled', true);
    notifyListeners();
    try {
      final result = await _channel.invokeMethod<bool>('createFloatingBubble');
      if (result == false) { await _channel.invokeMethod('requestOverlayPermission'); }
      return true;
    } catch (e) { debugPrint('Bubble error: $e'); return false; }
  }

  Future<bool> stopBubble() async {
    _isEnabled = false; _isStarted = false;
    await _prefs?.setBool('floating_bubble_enabled', false);
    notifyListeners();
    try { await _channel.invokeMethod('destroyFloatingBubble'); return true; } catch (e) { return false; }
  }

  Future<void> setOpacity(double v) async {
    _opacity = v.clamp(0.3, 1.0);
    await _prefs?.setDouble('floating_bubble_opacity', _opacity);
    notifyListeners();
  }

  Future<void> setSize(double v) async {
    _size = v.clamp(40, 100);
    await _prefs?.setDouble('floating_bubble_size', _size);
    notifyListeners();
  }
}
