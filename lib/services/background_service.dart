import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class BackgroundService extends ChangeNotifier {
  bool _isRunning = false;
  bool get isRunning => _isRunning;
  bool _hasCustomBackground = false;
  bool get hasCustomBackground => _hasCustomBackground;
  String? _backgroundPath;
  String? get backgroundPath => _backgroundPath;

  Future<void> initialize() async { debugPrint('BackgroundService: initialized'); }
  Future<void> start() async { _isRunning = true; notifyListeners(); }
  Future<void> stop() async { _isRunning = false; notifyListeners(); }

  Future<void> pickBackground() async {
    _hasCustomBackground = true;
    _backgroundPath = '/custom/background';
    notifyListeners();
    debugPrint('BackgroundService: pickBackground');
  }

  Future<void> removeBackground() async {
    _hasCustomBackground = false;
    _backgroundPath = null;
    notifyListeners();
    debugPrint('BackgroundService: removeBackground');
  }
}
