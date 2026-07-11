import 'package:flutter/material.dart';

class BackgroundService extends ChangeNotifier {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  bool _isRunning = false;
  bool get isRunning => _isRunning;

  Future<void> initialize() async {
    _isRunning = true;
    notifyListeners();
  }

  Future<void> stop() async {
    _isRunning = false;
    notifyListeners();
  }
}
