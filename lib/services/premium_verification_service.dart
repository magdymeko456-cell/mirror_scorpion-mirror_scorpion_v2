import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumVerificationService extends ChangeNotifier {
  bool _isPremium = false;
  String _deviceId = '';
  String _expiryDate = '';

  bool get isPremium => _isPremium;
  String get deviceId => _deviceId;
  String get expiryDate => _expiryDate;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    _deviceId = prefs.getString('device_id') ?? '';
    _expiryDate = prefs.getString('expiry_date') ?? '';
  }

  Future<bool> activatePremium(String activationCode) async {
    // التحقق من كود التفعيل
    if (activationCode.length >= 20) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', true);
      await prefs.setString('activation_code', activationCode);
      _isPremium = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> deactivatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', false);
    await prefs.remove('activation_code');
    _isPremium = false;
    notifyListeners();
  }
}
