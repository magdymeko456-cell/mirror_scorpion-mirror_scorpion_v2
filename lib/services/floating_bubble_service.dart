import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingBubbleService extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _isEnabled = false;
  double _opacity = 0.85;
  double _size = 55;

  bool get isEnabled => _isEnabled;
  double get opacity => _opacity;
  double get size => _size;

  static const MethodChannel _channel = MethodChannel('mirror_scorpion/overlay');

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isEnabled = _prefs?.getBool('floating_bubble_enabled') ?? false;
    _opacity = _prefs?.getDouble('floating_bubble_opacity') ?? 0.85;
    _size = (_prefs?.getDouble('floating_bubble_size') ?? 55);
    if (_isEnabled) {
      try { await _channel.invokeMethod('createFloatingBubble'); } catch (_) {}
    }
    notifyListeners();
  }

  void toggle() {
    if (_isEnabled) { stopBubble(); } else { startBubble(); }
  }

  void startBubble() {
    _isEnabled = true;
    _prefs?.setBool('floating_bubble_enabled', true);
    notifyListeners();
    try { _channel.invokeMethod('createFloatingBubble'); } catch (e) { debugPrint('Bubble: $e'); }
  }

  void stopBubble() {
    _isEnabled = false;
    _prefs?.setBool('floating_bubble_enabled', false);
    notifyListeners();
    try { _channel.invokeMethod('destroyFloatingBubble'); } catch (e) { debugPrint('Bubble: $e'); }
  }

  void setOpacity(double v) {
    _opacity = v.clamp(0.3, 1.0);
    _prefs?.setDouble('floating_bubble_opacity', _opacity);
    notifyListeners();
  }

  void setSize(double v) {
    _size = v.clamp(40, 100);
    _prefs?.setDouble('floating_bubble_size', _size);
    notifyListeners();
  }
}
