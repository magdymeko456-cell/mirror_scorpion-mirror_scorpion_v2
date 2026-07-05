import 'package:flutter/foundation.dart';

class FloatingBubbleService extends ChangeNotifier {
  bool _isEnabled = false;
  bool get isEnabled => _isEnabled;

  void toggle() { _isEnabled = !_isEnabled; notifyListeners(); }
  void enable() { _isEnabled = true; notifyListeners(); }
  void disable() { _isEnabled = false; notifyListeners(); }

  Future<void> showBubble() async { debugPrint('FloatingBubble: shown'); }
  Future<void> hideBubble() async { debugPrint('FloatingBubble: hidden'); }
}
