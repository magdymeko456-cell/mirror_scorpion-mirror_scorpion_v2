import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PremiumVerificationService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isPremium = false;
  DateTime? _expiryDate;

  bool get isPremium => _isPremium;
  DateTime? get expiryDate => _expiryDate;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isPremium = _prefs.getBool('is_pro_version') ?? false;
    final expiryStr = _prefs.getString('pro_expiry_date');
    if (expiryStr != null) {
      _expiryDate = DateTime.tryParse(expiryStr);
      if (_expiryDate != null && _expiryDate!.isBefore(DateTime.now())) {
        _isPremium = false;
        await _prefs.setBool('is_pro_version', false);
        await _prefs.remove('pro_expiry_date');
      }
    }
    notifyListeners();
  }

  Future<DateTime?> _fetchNetworkTime() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('https://worldtimeapi.org/api/ip')).timeout(const Duration(seconds: 5)),
        http.get(Uri.parse('https://timeapi.io/api/Time/current/zone?timeZone=UTC')).timeout(const Duration(seconds: 5)),
      ]);
      for (final response in responses) {
        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data['utc_datetime'] != null) {
            return DateTime.tryParse(data['utc_datetime'] as String);
          } else if (data['dateTime'] != null) {
            return DateTime.tryParse(data['dateTime'] as String);
          }
        }
      }
    } catch (_) {}
    return null;
  }

  Future<bool> activateWithPatch(String patch) async {
    try {
      final parts = patch.split('-');
      if (parts.length < 3) return false;
      final durationStr = parts[parts.length - 2];
      final months = int.tryParse(durationStr) ?? 0;
      if (months <= 0 || months > 60) return false;

      DateTime now;
      final networkTime = await _fetchNetworkTime();
      if (networkTime != null) {
        now = networkTime;
      } else {
        now = DateTime.now();
        debugPrint('⚠️ استخدام الوقت المحلي');
      }

      final expiry = DateTime(now.year, now.month + months, now.day);
      _isPremium = true;
      _expiryDate = expiry;
      await _prefs.setBool('is_pro_version', true);
      await _prefs.setString('pro_expiry_date', expiry.toIso8601String());
      await _prefs.setString('pro_activation_patch', patch);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> deactivate() async {
    _isPremium = false;
    _expiryDate = null;
    await _prefs.setBool('is_pro_version', false);
    await _prefs.remove('pro_expiry_date');
    await _prefs.remove('pro_activation_patch');
    notifyListeners();
  }

  bool hasFeature(String feature) {
    if (!_isPremium) return false;
    if (_expiryDate != null && _expiryDate!.isBefore(DateTime.now())) return false;
    return true;
  }
}
