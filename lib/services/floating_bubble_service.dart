import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class FloatingBubbleService extends ChangeNotifier {
  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;
  double _opacity = 0.8;
  double get opacity => _opacity;
  int _size = 60;
  int get size => _size;
  bool _autoTranslate = false;
  bool get autoTranslate => _autoTranslate;

  void toggle() { _isEnabled = !_isEnabled; notifyListeners(); }
  void enable() { _isEnabled = true; notifyListeners(); }
  void disable() { _isEnabled = false; notifyListeners(); }

  Future<void> showBubble() async { debugPrint('FloatingBubble: shown'); }
  Future<void> hideBubble() async { debugPrint('FloatingBubble: hidden'); }

  Future<void> toggleBubble(BuildContext context, bool value) async {
    _isEnabled = value;
    notifyListeners();
    debugPrint('FloatingBubble: toggleBubble $value');
  }

  void setOpacity(double value) { _opacity = value; notifyListeners(); }
  void setSize(int value) { _size = value; notifyListeners(); }
  void toggleAutoTranslate(bool value) { _autoTranslate = value; notifyListeners(); }
}
