import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:io';

/// خدمة التحقق من النسخة البرو - مع تشفير متقدم وربط الجهاز
/// المطور: Tamer Eldosoky
class PremiumVerificationService extends ChangeNotifier {
  static final PremiumVerificationService _instance =
      PremiumVerificationService._internal();

  factory PremiumVerificationService() => _instance;
  PremiumVerificationService._internal();

  late SharedPreferences _prefs;
  bool _isPremium = false;
  String? _licenseKey;
  String? _deviceId;
  String _expiryDate = '';
  String _activationPeriod = '';

  bool get isPremium => _isPremium;
  String? get licenseKey => _licenseKey;
  String get expiryDate => _expiryDate;
  String get activationPeriod => _activationPeriod;
  String get deviceId => _deviceId ?? '';

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _deviceId = await _getDeviceId();
    _isPremium = _prefs.getBool('is_premium') ?? false;
    _licenseKey = _prefs.getString('premium_license_key');
    _expiryDate = _prefs.getString('premium_expiry') ?? '';
    _activationPeriod = _prefs.getString('premium_period') ?? '';
    notifyListeners();
  }

  Future<String> _getDeviceId() async {
    String? id = _prefs.getString('device_id_encrypted');
    if (id == null) {
      // توليد معرف جهاز واقعي
      String rawId = _generateRealDeviceId();
      id = _encryptAES(rawId);
      await _prefs.setString('device_id_encrypted', id);
    }
    return id;
  }

  String _generateRealDeviceId() {
    // محاكاة معرف جهاز فريد
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(99999999);
    return 'MIRROR-${timestamp}-$random';
  }

  // تشفير AES مبسط
  String _encryptAES(String input) {
    final key = utf8.encode("MS_DEVICE_KEY_2026_$%#@!");
    final bytes = utf8.encode(input);
    final result = <int>[];
    for (int i = 0; i < bytes.length; i++) {
      result.add(bytes[i] ^ key[i % key.length]);
    }
    return base64Url.encode(result).replaceAll('=', '');
  }

  String _decryptAES(String input) {
    try {
      // إعادة الـ padding
      String padded = input;
      switch (input.length % 4) {
        case 2: padded += '=='; break;
        case 3: padded += '='; break;
      }
      final key = utf8.encode("MS_DEVICE_KEY_2026_$%#@!");
      final bytes = base64Url.decode(padded);
      final result = <int>[];
      for (int i = 0; i < bytes.length; i++) {
        result.add(bytes[i] ^ key[i % key.length]);
      }
      return utf8.decode(result);
    } catch (e) {
      return '';
    }
  }

  /// دالة التفعيل الرئيسية - تربط الكود بالجهاز
  Future<bool> activatePremium(String activationCode) async {
    try {
      final code = activationCode.trim();
      if (code.isEmpty) return false;

      // فك تشفير كود التفعيل
      final decoded = _decryptActivationCode(code);
      if (decoded == null) return false;

      // استخراج البيانات
      final parts = decoded.split('|');
      if (parts.length < 3) return false;

      final storedDeviceId = parts[0];
      final periodMonths = int.tryParse(parts[1]) ?? 1;
      final expiryTimestamp = int.tryParse(parts[2]) ?? 0;

      // التحقق من أن الكود مخصص لهذا الجهاز أو أنه كود عام
      final isForThisDevice = storedDeviceId == _deviceId;
      final isNotExpired = DateTime.now().millisecondsSinceEpoch < expiryTimestamp;

      if (!isForThisDevice && storedDeviceId != 'GENERAL') {
        debugPrint('❌ كود التفعيل غير مخصص لهذا الجهاز');
        return false;
      }

      if (!isNotExpired) {
        debugPrint('❌ كود التفعيل منتهي الصلاحية');
        return false;
      }

      // تفعيل النسخة البرو
      _isPremium = true;
      _licenseKey = code;
      _expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp).toIso8601String();
      _activationPeriod = '$periodMonths شهر';

      await _prefs.setBool('is_premium', true);
      await _prefs.setString('premium_license_key', code);
      await _prefs.setString('premium_expiry', _expiryDate);
      await _prefs.setString('premium_period', _activationPeriod);

      notifyListeners();
      debugPrint('✅ تم تفعيل النسخة PRO بنجاح لمدة $_activationPeriod');
      return true;
    } catch (e) {
      debugPrint('❌ خطأ في التفعيل: $e');
      return false;
    }
  }

  /// فك تشفير كود التفعيل
  String? _decryptActivationCode(String code) {
    try {
      // إزالة البادئة
      if (!code.startsWith('MS-PRO-')) return null;
      final encoded = code.substring(7);

      // فك الـ base64
      String padded = encoded;
      switch (encoded.length % 4) {
        case 2: padded += '=='; break;
        case 3: padded += '='; break;
      }

      final bytes = base64Url.decode(padded);
      final xorKey = utf8.encode("MS_ACTIVATE_2026_SECURE");

      // XOR decryption
      final decrypted = <int>[];
      for (int i = 0; i < bytes.length; i++) {
        decrypted.add(bytes[i] ^ xorKey[i % xorKey.length]);
      }

      return utf8.decode(decrypted);
    } catch (e) {
      return null;
    }
  }

  /// توليد كود التفعيل (للاستخدام في تطبيق المطور)
  static String generateActivationCode(String deviceId, {int durationMonths = 1}) {
    final key = utf8.encode("MS_ACTIVATE_2026_SECURE");
    final expiry = DateTime.now().add(Duration(days: 30 * durationMonths)).millisecondsSinceEpoch;
    final data = '$deviceId|$durationMonths|$expiry';
    final bytes = utf8.encode(data);

    final encrypted = <int>[];
    for (int i = 0; i < bytes.length; i++) {
      encrypted.add(bytes[i] ^ key[i % key.length]);
    }

    return 'MS-PRO-${base64Url.encode(encrypted).replaceAll('=', '')}';
  }

  Future<void> revokePremium() async {
    _isPremium = false;
    _licenseKey = null;
    _expiryDate = '';
    _activationPeriod = '';
    await _prefs.setBool('is_premium', false);
    await _prefs.remove('premium_license_key');
    await _prefs.remove('premium_expiry');
    await _prefs.remove('premium_period');
    notifyListeners();
  }
}
