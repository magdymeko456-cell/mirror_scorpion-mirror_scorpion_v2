import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumVerificationService extends ChangeNotifier {
  bool _isPremium = false;
  String _deviceId = '';
  String _expiryDate = '';

  bool get isPremium => _isPremium;
  String get deviceId => _deviceId;
  String get encryptedDeviceId => _deviceId; // ← مطلوب من settings_screen
  String get expiryDate => _expiryDate;

  Future initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    _expiryDate = prefs.getString('expiry_date') ?? '';
    _deviceId = await _generateDeviceId();
  }

  Future<String> _generateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? saved = prefs.getString('device_unique_id');
    if (saved != null && saved.isNotEmpty) return saved;
    final random = DateTime.now().microsecondsSinceEpoch.toString();
    final id = 'MS-${random.substring(random.length - 12)}-${Platform.localHostname.substring(0, 4).toUpperCase()}';
    await prefs.setString('device_unique_id', id);
    return id;
  }

  Future<bool> activatePremium(String activationCode) async {
    if (activationCode.length >= 16) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', true);
      await prefs.setString('activation_code', activationCode);
      final expiry = DateTime.now().add(const Duration(days: 365));
      _expiryDate = '${expiry.year}/${expiry.month}/${expiry.day}';
      await prefs.setString('expiry_date', _expiryDate);
      _isPremium = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future deactivatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', false);
    await prefs.remove('activation_code');
    await prefs.remove('expiry_date');
    _isPremium = false;
    _expiryDate = '';
    notifyListeners();
  }
}
