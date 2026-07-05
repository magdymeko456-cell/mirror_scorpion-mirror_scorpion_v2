class ApiConfig {
  static const String googleApiKey = String.fromEnvironment(
    'GOOGLE_API_KEY',
    defaultValue: '',
  );

  static const String translateUrl = 'https://translation.googleapis.com/language/translate/v2';
  static const String geminiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
}
