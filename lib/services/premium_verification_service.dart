import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumVerificationService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isPremium = false;
  String _deviceId = '';
  String _activationPatch = '';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isPremium = _prefs.getBool('is_premium') ?? false;
    _deviceId = _prefs.getString('device_id') ?? _generateDeviceId();
    _activationPatch = _prefs.getString('activation_patch') ?? '';
    if (_deviceId.isNotEmpty) {
      await _prefs.setString('device_id', _deviceId);
    }
    notifyListeners();
  }

  bool get isPremium => _isPremium;
  String get deviceId => _deviceId;
  String get activationPatch => _activationPatch;

  String _generateDeviceId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final hash = now ^ 0x5C4A3B2D; // XOR مع ثابت
    return 'MS-${hash.toRadixString(16).toUpperCase()}-${DateTime.now().second}';
  }

  /// تشفير device ID (للإرسال إلى الخادم)
  String encryptDeviceId() {
    // مفتاح تشفير بسيط (في الإنتاج يستخدم RSA)
    const key = 'MS_DEVICE_KEY_2026_';
    final bytes = utf8.encode('$_deviceId:$key');
    return base64Encode(bytes);
  }

  /// التحقق من patch التفعيل
  bool verifyActivationPatch(String patch) {
    if (patch.isEmpty) return false;
    try {
      // فك التشفير
      final decoded = utf8.decode(base64Decode(patch));
      final parts = decoded.split(':');
      if (parts.length < 2) return false;

      final patchDeviceId = parts[0];
      final timestamp = parts[1];

      // التحقق من device ID
      if (patchDeviceId != _deviceId) return false;

      // التحقق من الصلاحية (30 يوم من timestamp)
      final patchTime = int.tryParse(timestamp);
      if (patchTime == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - patchTime;
      const thirtyDays = 30 * 24 * 60 * 60 * 1000;

      if (diff > thirtyDays) return false;

      // حفظ patch
      _activationPatch = patch;
      _prefs.setString('activation_patch', patch);
      _isPremium = true;
      _prefs.setBool('is_premium', true);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Patch verification error: $e');
      return false;
    }
  }

  /// إنشاء patch جديد (للخادم فقط — للعرض)
  String generatePatchForDevice(String deviceId) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final raw = '$deviceId:$now';
    return base64Encode(utf8.encode(raw));
  }

  /// نسخ الـ ID للتسجيل
  String getFormattedDeviceId() {
    final encrypted = encryptDeviceId();
    return '📱 Device ID: $_deviceId\n🔐 Encrypted: $encrypted';
  }

  /// إلغاء التفعيل
  Future<void> deactivate() async {
    _isPremium = false;
    _activationPatch = '';
    await _prefs.setBool('is_premium', false);
    await _prefs.setString('activation_patch', '');
    notifyListeners();
  }

  /// التحقق من صلاحية التفعيل (يسمى يومياً)
  Future<bool> validateSubscription() async {
    if (!_isPremium) return false;
    if (_activationPatch.isEmpty) return false;

    try {
      final decoded = utf8.decode(base64Decode(_activationPatch));
      final parts = decoded.split(':');
      if (parts.length < 2) return false;

      final timestamp = parts[1];
      final activationTime = int.tryParse(timestamp);
      if (activationTime == null) return false;

      final now = DateTime.now().millisecondsSinceEpoch;
      final diff = now - activationTime;
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

  /// رقم الإصدار للتحقق
  String get version => '1.0.0';
}
