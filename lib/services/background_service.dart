import 'package:flutter/foundation.dart';

class BackgroundService extends ChangeNotifier {
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  Future<void> initialize() async { debugPrint('BackgroundService: initialized'); }

  Future<void> start() async { _isRunning = true; notifyListeners(); }
  Future<void> stop() async { _isRunning = false; notifyListeners(); }
}
