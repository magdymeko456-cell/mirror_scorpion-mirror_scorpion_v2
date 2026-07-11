import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static final LanguageService _instance = LanguageService._internal();
  factory LanguageService() => _instance;
  LanguageService._internal();

  Future<void> initialize() async {
    notifyListeners();
  }

  Future<void> saveLastUsedLanguages({required String source, required String target}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('source_lang', source);
    await prefs.setString('target_lang', target);
  }

  Future<Map<String, String>?> getLastUsedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final source = prefs.getString('source_lang');
    final target = prefs.getString('target_lang');
    if (source != null && target != null) {
      return {'source': source, 'target': target};
    }
    return null;
  }

  Future<String> getLanguageForScreen(String screen) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('lang_$screen') ?? 'ar';
  }

  Future<void> saveLanguageForScreen(String screen, String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('lang_$screen', lang);
    notifyListeners();
  }
}
