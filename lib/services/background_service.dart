import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

/// خدمة إدارة الخلفية المخصصة للكروت
class BackgroundService extends ChangeNotifier {
  static final BackgroundService _instance = BackgroundService._internal();
  
  factory BackgroundService() => _instance;
  BackgroundService._internal();
  
  late SharedPreferences _prefs;
  String? _customBackgroundPath;
  bool _isInitialized = false;
  
  Future initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _customBackgroundPath = _prefs.getString('custom_background_path');
    _isInitialized = true;
    notifyListeners();
  }

  /// حفظ مسار خلفية مخصص (يُستدعى من واجهة المستخدم)
  Future<bool> setBackgroundPath(String path) async {
    try {
      _customBackgroundPath = path;
      await _prefs.setString('custom_background_path', path);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// إزالة الخلفية المخصصة
  Future<bool> removeBackground() async {
    try {
      if (_customBackgroundPath != null) {
        final file = File(_customBackgroundPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
      _customBackgroundPath = null;
      await _prefs.remove('custom_background_path');
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  String? get customBackgroundPath => _customBackgroundPath;
  bool get hasCustomBackground => _customBackgroundPath != null;
}
