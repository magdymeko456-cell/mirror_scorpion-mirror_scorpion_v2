import 'package:flutter/material.dart';

class FloatingBubbleService extends ChangeNotifier {
  bool _isStarted = false;

  bool get isStarted => _isStarted;

  Future<void> initialize() async {
    // التحقق من الإذن
  }

  Future<void> startBubble(BuildContext context) async {
    _isStarted = true;
    notifyListeners();
  }

  Future<void> stopBubble() async {
    _isStarted = false;
    notifyListeners();
  }

  void toggle() {
    _isStarted = !_isStarted;
    notifyListeners();
  }
}
