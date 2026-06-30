import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LanguageService extends ChangeNotifier {
  String _deviceLang = 'ar';
  String getDeviceLanguage() => _deviceLang;
  Future<void> initialize() async {
    final p = await SharedPreferences.getInstance();
    _deviceLang = p.getString('device_language') ?? 'ar';
  }
  String getLanguageForScreen(String s) => '';
  Future<void> saveLanguageForScreen(String s, String l) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('lang_$s', l);
  }
  List<String> getLanguageCodes() => ['ar','en','fr','de','es','it','pt','ru','zh','ja','ko','hi','tr','ur','fa'];
  String getLanguageName(String c) {
    final m = {'ar':'العربية','en':'English','fr':'Français','de':'Deutsch','es':'Español','it':'Italiano','pt':'Português','ru':'Русский','zh':'中文','ja':'日本語','ko':'한국어','hi':'हिन्दी','tr':'Türkçe','ur':'اردو','fa':'فارسی'};
    return m[c] ?? c;
  }
}
