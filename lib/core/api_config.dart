/// إعدادات API — المفتاح يُقرأ من --dart-define (آمن)
class ApiConfig {
  /// مفتاح Google API — يأتي من --dart-define=GOOGLE_API_KEY=...
  /// إذا كان المفتاح غير معرّف (تشغيل محلي)، استخدم fallback
  static const String googleApiKey = String.fromEnvironment(
    'GOOGLE_API_KEY',
    defaultValue: '__LOCAL_DEV_KEY__',
  );

  static const String translateUrl = 'https://translation.googleapis.com/language/translate/v2';
  static const String geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
}
