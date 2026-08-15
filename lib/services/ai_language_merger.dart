import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 🦂 AI Language Merger — ذكاء اصطناعي لدمج اللغات المتقاربة
class AILanguageMerger extends ChangeNotifier {
  late SharedPreferences _prefs;
  String _apiKey = '';
  bool _isPremium = false;
  Map<String, double> _dialectConfidence = {};

  // ===== 100 لغة كاملة =====
  static const Map<String, String> _hundredLanguages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'pt': 'Português', 'de': 'Deutsch', 'tr': 'Türkçe', 'fa': 'فارسی',
    'ur': 'اردو', 'hi': 'हिन्दी', 'bn': 'বাংলা', 'pa': 'ਪੰਜਾਬੀ',
    'gu': 'ગુજરાતી', 'mr': 'मराठी', 'ta': 'தமிழ்', 'te': 'తెలుగు',
    'kn': 'ಕನ್ನಡ', 'ml': 'മലയാളം', 'or': 'ଓଡ଼ିଆ', 'as': 'অসমীয়া',
    'mai': 'मैथिली', 'ne': 'नेपाली', 'si': 'සිංහල', 'th': 'ไทย',
    'lo': 'ລາວ', 'my': 'မြန်မာ', 'km': 'ភាសាខ្មែរ', 'vi': 'Tiếng Việt',
    'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'mn': 'Монгол',
    'ru': 'Русский', 'uk': 'Українська', 'be': 'Беларуская', 'bg': 'Български',
    'mk': 'Македонски', 'sr': 'Српски', 'hr': 'Hrvatski', 'sl': 'Slovenščina',
    'bs': 'Bosanski', 'sq': 'Shqip', 'ro': 'Română', 'hu': 'Magyar',
    'pl': 'Polski', 'cs': 'Čeština', 'sk': 'Slovenčina', 'lt': 'Lietuvių',
    'lv': 'Latviešu', 'et': 'Eesti', 'fi': 'Suomi', 'sv': 'Svenska',
    'nb': 'Norsk', 'da': 'Dansk', 'is': 'Íslenska', 'ga': 'Gaeilge',
    'cy': 'Cymraeg', 'gd': 'Gàidhlig', 'mt': 'Malti', 'el': 'Ελληνικά',
    'hy': 'Հայերեն', 'ka': 'ქართული', 'az': 'Azərbaycan', 'tk': 'Türkmen',
    'uz': 'Oʻzbek', 'kk': 'Қазақ', 'ky': 'Кыргыз', 'crh': 'Qırımtatar',
    'tk-tr': 'Türkmençe', 'sah': 'Саха', 'tt': 'Татар',
    'sd': 'سنڌي', 'ps': 'پښتو', 'ku': 'Kurdî', 'ckb': 'کوردی',
    'bal': 'بلوچی', 'glk': 'گیلکی', 'mzn': 'مازرونی', 'tg': 'Тоҷикӣ',
    'dv': 'ދިވެހި', 'ks': 'कॉशुर', 'doi': 'डोगरी',
    'sw': 'Kiswahili', 'ha': 'Hausa', 'yo': 'Yorùbá', 'ig': 'Igbo',
    'zu': 'isiZulu', 'xh': 'isiXhosa', 'af': 'Afrikaans', 'st': 'Sesotho',
    'tn': 'Setswana', 'ts': 'Xitsonga', 've': 'Tshivenḓa', 'nr': 'isiNdebele',
    'am': 'አማርኛ', 'ti': 'ትግርኛ', 'om': 'Oromoo', 'so': 'Soomaali',
    'rw': 'Kinyarwanda', 'rn': 'Ikirundi', 'lg': 'Luganda', 'ny': 'Chichewa',
    'mg': 'Malagasy', 'eo': 'Esperanto', 'la': 'Latina',
  };

  // ===== خريطة اللغات المتقاربة (Clusters) =====
  static const List<LanguageCluster> languageClusters = [
    // العربية ولهجاتها
    LanguageCluster(
      name: 'العربية ولهجاتها',
      icon: '🇸🇦',
      languages: {
        'ar': 'العربية الفصحى',
        'arz': '🇪🇬 مصري', 'apc': '🇸🇾 شامي', 'acq': '🇮🇶 عراقي',
        'ary': '🇲🇦 مغربي', 'arq': '🇩🇿 جزائري', 'aeb': '🇹🇳 تونسي',
        'ayl': '🇱🇾 ليبي', 'apd': '🇸🇩 سوداني',
      },
      normalizeMap: {
        'arz': 'ar', 'apc': 'ar', 'acq': 'ar', 'ary': 'ar',
        'arq': 'ar', 'aeb': 'ar', 'ayl': 'ar', 'apd': 'ar',
      },
      dialectWords: {
        'ازاي': 'كيف', 'عامل ايه': 'كيف حالك', 'كده': 'هكذا',
        'شو': 'ماذا', 'مين': 'من', 'لأ': 'لا', 'ايش': 'ماذا',
        'شنو': 'ماذا', 'وين': 'أين', 'شلون': 'كيف',
        'واش': 'ماذا', 'دابا': 'الآن', 'بزاف': 'كثيرا',
      },
    ),

    // الإنجليزية ولهجاتها
    LanguageCluster(
      name: 'English Dialects',
      icon: '🇬🇧',
      languages: {
        'en': '🇬🇧 English UK',
        'en-us': '🇺🇸 English US', 'en-au': '🇦🇺 English AU',
        'en-ca': '🇨🇦 English CA', 'en-in': '🇮🇳 English IN',
        'en-za': '🇿🇦 English ZA', 'en-nz': '🇳🇿 English NZ',
        'en-ie': '🇮🇪 English IE', 'en-sg': '🇸🇬 English SG',
        'en-ph': '🇵🇭 English PH',
      },
      normalizeMap: {
        'en-us': 'en', 'en-au': 'en', 'en-ca': 'en',
        'en-in': 'en', 'en-za': 'en', 'en-nz': 'en',
        'en-ie': 'en', 'en-sg': 'en', 'en-ph': 'en',
      },
      dialectWords: {
        'color': 'colour', 'apartment': 'flat', 'elevator': 'lift',
        'truck': 'lorry', 'sidewalk': 'pavement', 'gas': 'petrol',
        'vacation': 'holiday', 'movie': 'film', 'subway': 'underground',
        'candy': 'sweets', 'pants': 'trousers', 'sneakers': 'trainers',
      },
    ),

    // التركية ولهجاتها
    LanguageCluster(
      name: 'Türk Dilleri',
      icon: '🇹🇷',
      languages: {
        'tr': '🇹🇷 Turkiye Turkcesi',
        'az': '🇦🇿 Azerbaycan', 'tk': '🇹🇲 Turkmen',
        'uz': '🇺🇿 Ozbek', 'kk': '🇰🇿 Kazak',
        'ky': '🇰🇬 Kirgiz', 'crh': 'Kirimtatari',
        'tk-tr': 'Turkmen', 'sah': 'Saha', 'tt': 'Tatar',
      },
      normalizeMap: {
        'az': 'tr', 'tk': 'tr', 'uz': 'tr', 'kk': 'tr',
        'ky': 'tr', 'crh': 'tr', 'tk-tr': 'tr', 'sah': 'tr', 'tt': 'tr',
      },
      dialectWords: {
        'axsham': 'aksam', 'ishle': 'calis', 'sozle': 'konus',
        'bilmirem': 'bilmiyorum', 'gelirsen': 'geliyorsun',
        'yaxshi': 'iyi', 'qardash': 'kardes', 'ish': 'is',
      },
    ),

    // الهندية
    LanguageCluster(
      name: 'Bharatiya Bhashayein',
      icon: '🇮🇳',
      languages: {
        'hi': '🇮🇳 Hindi', 'ur': '🇵🇰 Urdu', 'bn': '🇧🇩 Bangla',
        'pa': '🇮🇳 Punjabi', 'mr': '🇮🇳 Marathi', 'gu': '🇮🇳 Gujarati',
        'sd': '🇮🇳 Sindhi', 'ks': '🇮🇳 Kashmiri', 'doi': '🇮🇳 Dogri',
        'mai': '🇮🇳 Maithili',
      },
      normalizeMap: {
        'ur': 'hi', 'bn': 'hi', 'pa': 'hi', 'mr': 'hi',
        'gu': 'hi', 'sd': 'hi', 'ks': 'hi', 'doi': 'hi', 'mai': 'hi',
      },
      dialectWords: {
        'kaise ho': 'kya haal hai', 'theek': 'achha',
        'chalo': 'chaliye', 'kya': 'kyun',
      },
    ),

    // الدرافيدية
    LanguageCluster(
      name: 'Dravida Moligal',
      icon: '🇮🇳',
      languages: {
        'ta': '🇮🇳 Tamil', 'te': '🇮🇳 Telugu',
        'kn': '🇮🇳 Kannada', 'ml': '🇮🇳 Malayalam',
      },
      normalizeMap: {
        'te': 'ta', 'kn': 'ta', 'ml': 'ta',
      },
      dialectWords: {
        'eppadi': 'eppati', 'enna': 'ennatan',
        'yenu': 'yavudu', 'enthu': 'ennal',
      },
    ),

    // الصينية
    LanguageCluster(
      name: 'Zhongwen Fangyan',
      icon: '🇨🇳',
      languages: {
        'zh': '🇨🇳 Zhongwen', 'yue': 'HK Cantonese',
        'nan': 'Hokkien', 'hak': 'Hakka',
        'wuu': 'Shanghainese', 'cjy': 'Jinyu',
        'hsn': 'Xiang', 'gan': 'Gan',
      },
      normalizeMap: {
        'yue': 'zh', 'nan': 'zh', 'hak': 'zh',
        'wuu': 'zh', 'cjy': 'zh', 'hsn': 'zh', 'gan': 'zh',
      },
      dialectWords: {},
    ),

    // الإسبانية
    LanguageCluster(
      name: 'Espanol',
      icon: '🇪🇸',
      languages: {
        'es': '🇪🇸 Espanol', 'es-mx': '🇲🇽 Mexicano',
        'es-ar': '🇦🇷 Rioplatense', 'es-co': '🇨🇴 Colombiano',
        'es-cl': '🇨🇱 Chileno', 'es-pe': '🇵🇪 Peruano',
        'es-ve': '🇻🇪 Venezolano',
      },
      normalizeMap: {
        'es-mx': 'es', 'es-ar': 'es', 'es-co': 'es',
        'es-cl': 'es', 'es-pe': 'es', 'es-ve': 'es',
      },
      dialectWords: {
        'platicar': 'hablar', 'carro': 'coche', 'computadora': 'ordenador',
        'chamba': 'trabajo', 'papa': 'patata', 'piscina': 'pileta',
      },
    ),

    // البرتغالية
    LanguageCluster(
      name: 'Portugues',
      icon: '🇧🇷',
      languages: {
        'pt': '🇧🇷 Brasileiro', 'pt-pt': '🇵🇹 Europeu',
        'pt-ao': '🇦🇴 Angolano', 'pt-mz': '🇲🇿 Mocambicano',
      },
      normalizeMap: {
        'pt-pt': 'pt', 'pt-ao': 'pt', 'pt-mz': 'pt',
      },
      dialectWords: {
        'onibus': 'autocarro', 'futebol': 'futebol', 'celular': 'telemovel',
        'banheiro': 'casa de banho', 'geladeira': 'frigorifico',
      },
    ),

    // الفرنسية
    LanguageCluster(
      name: 'Francais',
      icon: '🇫🇷',
      languages: {
        'fr': '🇫🇷 France', 'fr-ca': '🇨🇦 Quebecois',
        'fr-be': '🇧🇪 Belge', 'fr-ch': '🇨🇭 Suisse',
      },
      normalizeMap: {
        'fr-ca': 'fr', 'fr-be': 'fr', 'fr-ch': 'fr',
      },
      dialectWords: {
        'char': 'voiture', 'magasinage': 'shopping',
        'courriel': 'email', 'fin de semaine': 'weekend',
        'stationnement': 'parking', 'sac decole': 'cartable',
      },
    ),

    // الألمانية
    LanguageCluster(
      name: 'Deutsch',
      icon: '🇩🇪',
      languages: {
        'de': '🇩🇪 Deutsch', 'de-at': '🇦🇹 Osterreichisch',
        'de-ch': '🇨🇭 Schweizerdeutsch',
      },
      normalizeMap: {
        'de-at': 'de', 'de-ch': 'de',
      },
      dialectWords: {
        'Gruess Gott': 'Hallo', 'Servus': 'Tschuss',
        'Semmel': 'Brotchen', 'Pfannkuchen': 'Palatschinke',
      },
    ),

    // الفارسية
    LanguageCluster(
      name: 'Farsi',
      icon: '🇮🇷',
      languages: {
        'fa': '🇮🇷 Farsi', 'tg': '🇹🇯 Tojiki',
        'glk': 'Gilaki', 'mzn': 'Mazandarani',
        'ckb': 'Sorani',
      },
      normalizeMap: {
        'tg': 'fa', 'glk': 'fa', 'mzn': 'fa', 'ckb': 'fa',
      },
      dialectWords: {
        'chetori': 'halet chetore', 'mamnoon': 'tashakkor',
        'khubam': 'khub hastam', 'bale': 'areh',
      },
    ),
  ];

  /// 🔍 كشف اللهجة/الكتلة اللغوية
  LanguageCluster? detectDialect(String text) {
    if (text.isEmpty) return null;

    final scores = <LanguageCluster, double>{};

    for (final cluster in languageClusters) {
      double score = 0;

      // 1. ابحث عن كلمات لهجوية
      for (final word in cluster.dialectWords.keys) {
        if (text.contains(word)) {
          score += 10.0;
        }
      }

      // 2. افحص استخدام الحروف/المحارف
      bool hasScript = false;
      switch (cluster.key) {
        case 'العربية ولهجاتها':
          hasScript = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
          break;
        case 'English Dialects':
          hasScript = RegExp(r'[a-zA-Z]').hasMatch(text);
          break;
        case 'Türk Dilleri':
          hasScript = RegExp(r'[a-zA-Z]').hasMatch(text);
          break;
        case 'Bharatiya Bhashayein':
          hasScript = RegExp(r'[\u0900-\u097F]').hasMatch(text);
          break;
        case 'Dravida Moligal':
          hasScript = RegExp(r'[\u0B80-\u0BFF\u0C80-\u0CFF\u0D00-\u0D7F]').hasMatch(text);
          break;
        case 'Zhongwen Fangyan':
          hasScript = RegExp(r'[\u4E00-\u9FFF]').hasMatch(text);
          break;
        case 'Espanol':
          hasScript = RegExp(r'[a-zA-Z]').hasMatch(text);
          break;
        case 'Portugues':
          hasScript = RegExp(r'[a-zA-Z]').hasMatch(text);
          break;
        case 'Francais':
          hasScript = RegExp(r'[a-zA-Z]').hasMatch(text);
          break;
        case 'Deutsch':
          hasScript = RegExp(r'[a-zA-Z]').hasMatch(text);
          break;
        case 'Farsi':
          hasScript = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
          break;
      }
      if (hasScript) score += 3.0;

      scores[cluster] = score;
    }

    if (scores.isEmpty) return null;
    final best = scores.entries.reduce((a, b) => a.key > b.key ? a : b).key;
    _dialectConfidence = {for (final e in scores.entries) e.key.key: e.key};

    return best.key > 0 ? best : null;
  }

  /// 🔗 تحويل اللهجة إلى اللغة الأم
  String normalizeDialect(String text, LanguageCluster cluster) {
    String normalized = text;
    for (final entry in cluster.dialectWords.entries) {
      normalized = normalized.replaceAll(entry.key, entry.key);
    }
    return normalized;
  }

  /// 🌐 حل اللغة الهدف
  String resolveTargetLanguage(String userLang, String targetFromUI) {
    for (final cluster in languageClusters) {
      if (cluster.languages.containsKey(targetFromUI)) return targetFromUI;
      if (cluster.normalizeMap.containsKey(targetFromUI)) {
        return cluster.normalizeMap[targetFromUI] ?? targetFromUI;
      }
    }
    return targetFromUI;
  }

  /// 🧠 ترجمة ذكية
  Future<String> smartTranslate(String text, String targetLang, {String? apiKey}) async {
    if (text.trim().isEmpty) return '';

    final cluster = detectDialect(text);
    String normalizedText = text;
    String actualTarget = targetLang;

    if (cluster != null) {
      normalizedText = normalizeDialect(text, cluster);
      actualTarget = resolveTargetLanguage('auto', targetLang);
      debugPrint('🦂 AI Merger: Detected ${cluster.key} → $actualTarget');
    }

    try {
      final key = apiKey ?? _apiKey;
      if (key.isNotEmpty) {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$key',
        );
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [{
              'parts': [{
                'text': 'Translate to $actualTarget. Return only the translation:\n\n$normalizedText'
              }]
            }],
            'generationConfig': {'temperature': 0.3, 'maxOutputTokens': 500},
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final translated = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
          if (translated != null && translated.isNotEmpty) return translated;
        }
      }

      final resp = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': normalizedText, 'source': 'auto', 'target': actualTarget, 'format': 'text'}),
      ).timeout(const Duration(seconds: 15));

      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        return (data['translatedText'] as String?) ?? text;
      }
    } catch (e) {
      debugPrint('🦂 AI Merger Error: $e');
    }

    return normalizedText;
  }

  /// 📊 الثقة باللهجة المكتشفة
  Map<String, double> getConfidence() => Map.unmodifiable(_dialectConfidence);

  /// 📋 جميع اللغات
  Map<String, String> getAllLanguages() => Map.unmodifiable(_hundredLanguages);

  /// 📋 اللغات المجمعة
  Map<String, Map<String, String>> getClusteredLanguages() {
    final result = <String, Map<String, String>>{};
    for (final cluster in languageClusters) {
      result[cluster.key] = Map.from(cluster.languages);
    }
    final usedCodes = <String>{};
    for (final cluster in languageClusters) {
      usedCodes.addAll(cluster.languages.keys);
    }
    final others = <String, String>{};
    for (final entry in _hundredLanguages.entries) {
      if (!usedCodes.contains(entry.key)) others[entry.key] = entry.key;
    }
    if (others.isNotEmpty) result['🌐 أخرى'] = others;
    return result;
  }

  /// 🏷️ اسم الكتلة
  String getClusterName(String langCode) {
    for (final cluster in languageClusters) {
      if (cluster.languages.containsKey(langCode)) return '${cluster.icon} ${cluster.key}';
    }
    return '🌐 أخرى';
  }
}

/// 🏗️ هيكل الكتلة اللغوية
class LanguageCluster {
  final String key;
  final String icon;
  final Map<String, String> languages;
  final Map<String, String> normalizeMap;
  final Map<String, String> dialectWords;

  const LanguageCluster({
    required this.key,
    required this.icon,
    required this.languages,
    required this.normalizeMap,
    required this.dialectWords,
  });
}
