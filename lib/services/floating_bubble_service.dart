import 'package:flutter/material.dart';

class FloatingBubbleService extends ChangeNotifier {
  bool _isEnabled = false;
  bool _isStarted = false;
  double _opacity = 0.8;
  double _bubbleSize = 120;
  bool _autoTranslate = true;

  bool get isEnabled => _isEnabled;
  bool get isStarted => _isStarted;
  double get opacity => _opacity;
  double get bubbleSize => _bubbleSize;
  bool get autoTranslate => _autoTranslate;

  Future<void> initialize() async {
    _isEnabled = true;
    _isStarted = false;
    notifyListeners();
  }

  Future<void> startBubble(BuildContext context) async {
    _isStarted = true;
    _isEnabled = true;
    notifyListeners();
  }

  Future<void> stopBubble() async {
    _isStarted = false;
    notifyListeners();
  }

  void toggleBubble() {
    if (_isStarted) {
      _isStarted = false;
      _isEnabled = false;
    } else {
      _isStarted = true;
      _isEnabled = true;
    }
    notifyListeners();
  }

  void setOpacity(double value) {
    _opacity = value;
    notifyListeners();
  }

  void setBubbleSize(double value) {
    _bubbleSize = value;
    notifyListeners();
  }

  void setAutoTranslate(bool value) {
    _autoTranslate = value;
    notifyListeners();
  }
}
