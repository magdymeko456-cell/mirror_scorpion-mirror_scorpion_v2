import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumVerificationService extends ChangeNotifier {
  bool _isPremium = false;
  String _deviceId = '';
  String _expiryDate = '';
  bool get isPremium => _isPremium;
  String get deviceId => _deviceId;
  String get expiryDate => _expiryDate;

  PremiumVerificationService() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    _deviceId = prefs.getString('device_id') ?? _generateDeviceId();
    _expiryDate = prefs.getString('expiry_date') ?? '';
    notifyListeners();
  }

  String _generateDeviceId() => 'MS-${DateTime.now().millisecondsSinceEpoch}';

  Future<bool> activateWithPatch(String patchCode) async {
    // TODO: فك تشفير patch والتحقق من صحته
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', true);
    await prefs.setString('device_id', _deviceId);
    await prefs.setString('expiry_date', DateTime.now().add(const Duration(days: 365)).toIso8601String());
    _isPremium = true;
    _expiryDate = DateTime.now().add(const Duration(days: 365)).toIso8601String();
    notifyListeners();
    return true;
  }
}
