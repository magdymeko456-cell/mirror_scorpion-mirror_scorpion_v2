import 'package:flutter/material.dart';
import 'dart:math';

class FloatingBubbleService extends ChangeNotifier {
  bool _isEnabled = false;
  double _opacity = 0.8;
  double _size = 120;
  bool _autoTranslate = true;

  bool get isEnabled => _isEnabled;
  double get opacity => _opacity;
  double get size => _size;
  bool get autoTranslate => _autoTranslate;

  void toggleBubble() {
    _isEnabled = !_isEnabled;
    notifyListeners();
  }

  void setOpacity(double value) {
    _opacity = value;
    notifyListeners();
  }

  void setSize(double value) {
    _size = value;
    notifyListeners();
  }

  void setAutoTranslate(bool value) {
    _autoTranslate = value;
    notifyListeners();
  }
}
