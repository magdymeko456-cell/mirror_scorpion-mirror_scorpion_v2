import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static final SharedPreferencesService instance = SharedPreferencesService._();
  SharedPreferencesService._();
  
  late SharedPreferences _prefs;
  
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  SharedPreferences get prefs => _prefs;
  
  Future<void> saveString(String key, String value) => _prefs.setString(key, value);
  String getString(String key, {String defaultValue = ''}) => _prefs.getString(key) ?? defaultValue;
  Future<void> saveBool(String key, bool value) => _prefs.setBool(key, value);
  bool getBool(String key, {bool defaultValue = false}) => _prefs.getBool(key) ?? defaultValue;
}
