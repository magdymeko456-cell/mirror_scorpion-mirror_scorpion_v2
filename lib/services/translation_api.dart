import 'dart:convert';
import 'package:http/http.dart' as http;

/// محرك الترجمة السحابي لميرور سكربيون
/// نقطة نهاية عامة مجانية (Google gtx) تدعم 100+ لغة — بدون مفاتيح
/// يُستخدم من: المترجم النصي، الحوار المترجم، المستندات، والفقاعة
class TranslationApi {
  static const String _endpoint =
      'https://translate.googleapis.com/translate_a/single';

  /// ترجمة نص إلى اللغة الهدف. from='auto' للكشف التلقائي.
  /// ترجع '' عند أي فشل ليتكفل المتصل بالاحتياط الأوفلاين.
  static Future<String> translate(
    String text, {
    String to = 'ar',
    String from = 'auto',
  }) async {
    if (text.trim().isEmpty) return '';
    try {
      final uri = Uri.parse(_endpoint).replace(queryParameters: {
        'client': 'gtx',
        'sl': from,
        'tl': to,
        'dt': 't',
        'q': text,
      });
      final res = await http.get(uri).timeout(const Duration(seconds: 15));
      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as List;
        final sb = StringBuffer();
        for (final seg in (data[0] as List)) {
          sb.write(seg[0] ?? '');
        }
        return sb.toString().trim();
      }
      return '';
    } catch (_) {
      return '';
    }
  }
}
