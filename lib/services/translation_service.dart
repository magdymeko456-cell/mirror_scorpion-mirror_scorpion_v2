import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TranslationService extends ChangeNotifier {
  bool _isTranslating = false;
  String _lastError = '';

  bool get isTranslating => _isTranslating;
  String get lastError => _lastError;

  /// ترجمة حقيقية باستخدام LibreTranslate API (مفتوح المصدر)
  Future<String> translate(String text, {String from = 'auto', String to = 'ar'}) async {
    if (text.trim().isEmpty) return '';
    _isTranslating = true;
    _lastError = '';
    notifyListeners();

    try {
      // المحاولة الأولى: LibreTranslate
      String result = await _libreTranslate(text, from, to);
      if (result.isNotEmpty && result != text) {
        _isTranslating = false;
        notifyListeners();
        return result;
      }

      // المحاولة الثانية: Google Translate عبر API مفتوح (lingva)
      result = await _lingvaTranslate(text, from, to);
      if (result.isNotEmpty && result != text) {
        _isTranslating = false;
        notifyListeners();
        return result;
      }

      // المحاولة الثالثة: MyMemory API
      result = await _myMemoryTranslate(text, from, to);
      if (result.isNotEmpty) {
        _isTranslating = false;
        notifyListeners();
        return result;
      }

      // في حال فشلت كل المحاولات، نعيد النص الأصلي
      _isTranslating = false;
      notifyListeners();
      return text;

    } catch (e) {
      debugPrint('Translation error: $e');
      _lastError = e.toString();
      _isTranslating = false;
      notifyListeners();
      return text;
    }
  }

  /// LibreTranslate API
  Future<String> _libreTranslate(String text, String from, String to) async {
    try {
      final servers = [
        'https://libretranslate.com/translate',
        'https://translate.terraprint.co/translate',
        'https://libretranslate.de/translate',
      ];

      for (final server in servers) {
        try {
          final response = await http.post(
            Uri.parse(server),
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
          ).timeout(const Duration(seconds: 8));

          if (response.statusCode == 200) {
            final body = utf8.decode(response.bodyBytes);
            final data = jsonDecode(body) as Map<String, dynamic>;
            final translated = data['translatedText'] as String?;
            if (translated != null && translated.isNotEmpty && translated != text) {
              return _addSignature(translated);
            }
          }
        } catch (_) {
          continue;
        }
      }
    } catch (_) {}
    return '';
  }

  /// Lingva Translate (Google Translate واجهة مفتوحة)
  Future<String> _lingvaTranslate(String text, String from, String to) async {
    try {
      final source = from == 'auto' ? 'auto' : from;
      final url = 'https://lingva.ml/api/v1/$source/$to/${Uri.encodeComponent(text)}';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final translated = data['translation'] as String?;
        if (translated != null && translated.isNotEmpty && translated != text) {
          return _addSignature(translated);
        }
      }
    } catch (_) {}
    return '';
  }

  /// MyMemory API (يدعم 100+ لغة)
  Future<String> _myMemoryTranslate(String text, String from, String to) async {
    try {
      final source = from == 'auto' ? '' : '$from|';
      final url = 'https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=$source$to&de=dosoky.server@gmail.com';
      final response = await http.get(Uri.parse(url))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['responseStatus'] as int? == 200) {
          final translated = data['responseData']?['translatedText'] as String?;
          if (translated != null && translated.isNotEmpty) {
            return _addSignature(translated);
          }
        }
      }
    } catch (_) {}
    return '';
  }

  /// إضافة توقيع التطبيق للترجمة
  String _addSignature(String translated) {
    if (translated.contains('Mirror Scorpion')) return translated;
    return '$translated\n\n— Mirror Scorpion \u{1F982}';
  }

  /// ترجمة مع توقيع مخصص للمشاركة
  Future<String> translateWithSignature(String text, {String from = 'auto', String to = 'ar'}) async {
    final result = await translate(text, from: from, to: to);
    if (!result.contains('Mirror Scorpion')) {
      return '$result\n\n— Mirror Scorpion \u{1F982}';
    }
    return result;
  }

  /// الحصول على النص المترجم مع التوقيع
  String addSignature(String translatedText) {
    if (translatedText.contains('Mirror Scorpion')) return translatedText;
    return '$translatedText\n\n— Mirror Scorpion \u{1F982}';
  }
}
