import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  String _currentLang = 'ar';
  String _sourceLang = 'auto';
  String _targetLang = 'ar';
  bool _isInitialized = false;

  String get currentLang => _currentLang;
  String get sourceLang => _sourceLang;
  String get targetLang => _targetLang;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLang = prefs.getString('app_lang') ?? 'ar';
    _sourceLang = prefs.getString('source_lang') ?? 'auto';
    _targetLang = prefs.getString('target_lang') ?? 'ar';
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setSourceLang(String lang) async {
    _sourceLang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('source_lang', lang);
    notifyListeners();
  }

  Future<void> setTargetLang(String lang) async {
    _targetLang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('target_lang', lang);
    notifyListeners();
  }
}
