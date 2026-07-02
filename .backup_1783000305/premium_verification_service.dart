import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PremiumVerificationService extends ChangeNotifier {
  bool _isPremium = false;
  String _deviceId = '';
  String _expiryDate = '';
  bool _isLoading = false;

  // ⚠️ غيّر الرابط إلى رابط السيرفر الخاص بك
  static const String _serverUrl = 'https://example.com/api/activate.php';

  bool get isPremium => _isPremium;
  String get deviceId => _deviceId;
  String get encryptedDeviceId => _deviceId;
  String get expiryDate => _expiryDate;
  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    _expiryDate = prefs.getString('expiry_date') ?? '';
    _deviceId = await _generateDeviceId();
    if (_isPremium) await _verifyWithServer(showError: false);
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

  // التفعيل اليدوي
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

  // التفعيل السحابي
  Future<bool> activateWithServer() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'activate',
          'device_id': _deviceId,
          'device_name': Platform.localHostname,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_premium', true);
          _expiryDate = data['expiry'] ?? '${DateTime.now().year + 1}/1/1';
          await prefs.setString('expiry_date', _expiryDate);
          _isPremium = true;
          _isLoading = false;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('❌ Server activation error: $e');
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> _verifyWithServer({bool showError = true}) async {
    try {
      final response = await http.post(
        Uri.parse(_serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'action': 'check', 'device_id': _deviceId}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid'] == true) return true;
      }
    } catch (e) {
      debugPrint('❌ Server check error: $e');
    }
    return _isPremium;
  }

  Future<void> deactivatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', false);
    await prefs.remove('activation_code');
    await prefs.remove('expiry_date');
    _isPremium = false;
    _expiryDate = '';
    notifyListeners();
  }
}
