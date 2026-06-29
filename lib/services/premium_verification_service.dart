import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumVerificationService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isPremium = false;
  String _deviceId = '';
  String _activationPatch = '';
  final Random _random = Random();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isPremium = _prefs.getBool('is_premium') ?? false;
    _deviceId = _prefs.getString('device_id') ?? _generateDeviceId();
    _activationPatch = _prefs.getString('activation_patch') ?? '';
    if (_prefs.getString('device_id') == null) {
      await _prefs.setString('device_id', _deviceId);
    }
    notifyListeners();
  }

  bool get isPremium => _isPremium;
  String get deviceId => _deviceId;
  String get activationPatch => _activationPatch;

  String _generateDeviceId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final randomPart = _random.nextInt(99999);
    final hash = (now ^ randomPart).toRadixString(16).toUpperCase();
    return 'MS-$hash-${now % 10000}';
  }

  String encryptDeviceId() {
    try {
      final bytes = utf8.encode('MS_DEVICE:$_deviceId');
      return base64Encode(bytes);
    } catch (e) {
      return 'ERROR';
    }
  }

  bool verifyActivationPatch(String patch) {
    if (patch.isEmpty) return false;
    try {
      final decoded = utf8.decode(base64Decode(patch));
      final parts = decoded.split(':');
      if (parts.length < 2) return false;
      final patchDeviceId = parts[0];
      final timestampStr = parts[1];
      final timestamp = int.tryParse(timestampStr);
      if (timestamp == null) return false;
      if (patchDeviceId != _deviceId) return false;
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - timestamp;
      const thirtyDays = 30 * 24 * 60 * 60 * 1000;
      if (diff > thirtyDays) return false;
      _activationPatch = patch;
      _prefs.setString('activation_patch', patch);
      _isPremium = true;
      _prefs.setBool('is_premium', true);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Premium verify error: $e');
      return false;
    }
  }

  String generatePatchForDevice(String deviceId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final raw = '$deviceId:$now';
    return base64Encode(utf8.encode(raw));
  }

  String getFormattedDeviceId() {
    final encrypted = encryptDeviceId();
    return 'Device ID: $_deviceId\nEncrypted: $encrypted';
  }

  Future<void> deactivate() async {
    _isPremium = false;
    _activationPatch = '';
    await _prefs.setBool('is_premium', false);
    await _prefs.setString('activation_patch', '');
    notifyListeners();
  }

  Future<bool> validateSubscription() async {
    if (!_isPremium || _activationPatch.isEmpty) return false;
    try {
      final decoded = utf8.decode(base64Decode(_activationPatch));
      final parts = decoded.split(':');
      if (parts.length < 2) return false;
      final timestamp = int.tryParse(parts[1]);
      if (timestamp == null) return false;
      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - timestamp;
      const thirtyDays = 30 * 24 * 60 * 60 * 1000;
      if (diff > thirtyDays) {
        _isPremium = false;
        await _prefs.setBool('is_premium', false);
        notifyListeners();
        return false;
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  String get version => '1.0.0';
}
