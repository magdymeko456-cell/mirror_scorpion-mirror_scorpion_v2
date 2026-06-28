import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TranslationService extends ChangeNotifier {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  bool _isTranslating = false;
  String _lastError = '';

  bool get isTranslating => _isTranslating;
  String get lastError => _lastError;

  /// ترجمة مع دعم UTF-8 الكامل
  Future<String> translate(String text, {String from = 'auto', String to = 'ar'}) async {
    if (text.trim().isEmpty) return '';
    _isTranslating = true;
    _lastError = '';
    notifyListeners();

    try {
      // استخدام LibreTranslate API (مفتوح المصدر)
      final uri = Uri.parse('https://libretranslate.com/translate');
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode({
          'q': text,
          'source': from == 'auto' ? 'auto' : from,
          'target': to,
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final data = jsonDecode(body) as Map<String, dynamic>;
        final translated = data['translatedText'] as String? ?? text;

        // إضافة التوقيع في النص المترجم
        final signed = '$translated\n\n

        _isTranslating = false;
        notifyListeners();
        return signed;
      } else {
        _lastError = 'HTTP ${response.statusCode}';
        _isTranslating = false;
        notifyListeners();
        return text;
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      _lastError = e.toString();
      _isTranslating = false;
      notifyListeners();
      return text;
    }
  }

  /// ترجمة مع توقيع مخصص للمشاركة
  Future<String> translateWithSignature(String text, {String from = 'auto', String to = 'ar'}) async {
    final result = await translate(text, from: from, to: to);
    if (!result.contains('Mirror Scorpion')) {
      return '$result\n\n
    }
    return result;
  }

  /// الحصول على النص المترجم مع التوقيع (للمشاركة)
  String addSignature(String translatedText) {
    if (translatedText.contains('Mirror Scorpion')) return translatedText;
    return '$translatedText\n\n
  }

  /// دعم اللغات ذات الحروف الخاصة (تركية، صينية، يابانية، إلخ)
  bool supportsLanguage(String langCode) {
    const supported = [
      'ar', 'en', 'fr', 'es', 'de', 'zh', 'ja', 'ko', 'ru',
      'pt', 'it', 'tr', 'hi', 'ur', 'nl', 'pl', 'sv', 'da',
      'fi', 'el', 'he', 'th', 'vi', 'ms', 'id', 'tl', 'cs',
      'hu', 'ro', 'sk', 'hr', 'sr', 'bg', 'uk', 'ka', 'hy',
      'az', 'kk', 'uz', 'mn', 'ne', 'si', 'km', 'lo', 'my',
    ];
    return supported.contains(langCode);
  }
}
