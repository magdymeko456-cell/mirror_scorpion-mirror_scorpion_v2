import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// 🦂 AI Language Merger — ذكاء اصطناعي لدمج اللغات المتقاربة
///
/// المهمة:
/// 1. تحديد اللهجة/اللغة الدقيقة للمستخدم
/// 2. تطبيع اللهجات إلى اللغة الأم
/// 3. ترجمة دقيقة مع مراعاة الاختلافات اللهجوية
/// 4. اكتشاف الخطأ في الترجمة وإعادة التوجيه تلقائياً
class AILanguageMerger extends ChangeNotifier {
  late SharedPreferences _prefs;
  String _apiKey = '';
  bool _isPremium = false;

  // ===== خريطة اللغات المتقاربة (Clusters) =====
  static const Map<String, LanguageCluster> languageClusters = {
    // العربية ولهجاتها
    'arabic': LanguageCluster(
      name: 'العربية ولهجاتها',
      icon: '🇸🇦',
      languages: {
        'ar': 'العربية الفصحى',
        'arz': '🇪🇬 مصري',
        'apc': '🇸🇾 شامي',
        'acq': '🇮🇶 عراقي',
        'ary': '🇲🇦 مغربي',
        'arq': '🇩🇿 جزائري',
        'aeb': '🇹🇳 تونسي',
        'ayl': '🇱🇾 ليبي',
        'apd': '🇸🇩 سوداني',
        'acm': '🇮🇶 عراقي (بغدادي)',
      },
      normalizeMap: {
        'arz': 'ar', 'apc': 'ar', 'acq': 'ar',
        'ary': 'ar', 'arq': 'ar', 'aeb': 'ar',
        'ayl': 'ar', 'apd': 'ar', 'acm': 'ar',
      },
      dialectWords: {
        'ازاي': 'كيف', 'عامل ايه': 'كيف حالك', 'كده': 'هكذا',
        'شو': 'ماذا', 'مين': 'من', 'لأ': 'لا', 'ايش': 'ماذا',
        'شنو': 'ماذا', 'وين': 'أين', 'شلون': 'كيف',
        'واش': 'ماذا', 'دابا': 'الآن', 'بزاف': 'كثيراً',
        'شنوة': 'ماذا', 'عليش': 'لماذا', 'هسة': 'الآن',
      },
    ),

    // الإنجليزية ولهجاتها
    'english': LanguageCluster(
      name: 'English Dialects',
      icon: '🇬🇧',
      languages: {
        'en': '🇬🇧 English UK',
        'en-us': '🇺🇸 English US',
        'en-au': '🇦🇺 English AU',
        'en-ca': '🇨🇦 English CA',
        'en-in': '🇮🇳 English IN',
        'en-za': '🇿🇦 English ZA',
        'en-nz': '🇳🇿 English NZ',
        'en-ie': '🇮🇪 English IE',
        'en-sg': '🇸🇬 English SG',
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
    'turkic': LanguageCluster(
      name: 'Türk Dilleri',
      icon: '🇹🇷',
      languages: {
        'tr': '🇹🇷 Türkiye Türkçesi',
        'az': '🇦🇿 Azərbaycan',
        'tk': '🇹🇲 Türkmen',
        'uz': '🇺🇿 Oʻzbek',
        'kk': '🇰🇿 Қазақ',
        'ky': '🇰🇬 Кыргыз',
        'crh': 'Qırımtatar',
        'ug': 'ئۇيغۇرچە',
        'ba': 'Башҡорт',
        'tt': 'Татар',
      },
      normalizeMap: {
        'az': 'tr', 'tk': 'tr', 'uz': 'tr',
        'kk': 'tr', 'ky': 'tr', 'crh': 'tr',
        'ug': 'tr', 'ba': 'tr', 'tt': 'tr',
      },
      dialectWords: {
        'nə': 'ne', 'deyil': 'değil', 'bəli': 'evet',
        'xeyr': 'hayır', 'çox': 'çok', 'kiçik': 'küçük',
        'böyük': 'büyük', 'gözəl': 'güzel', 'adam': 'insan',
        'qız': 'kız', 'oğlan': 'oğlan', 'su': 'su',
      },
    ),

    // الهندية والمتعلقة بها
    'indo_aryan': LanguageCluster(
      name: 'भारतीय भाषाएँ',
      icon: '🇮🇳',
      languages: {
        'hi': '🇮🇳 हिन्दी',
        'ur': '🇵🇰 اردو',
        'bn': '🇧🇩 বাংলা',
        'pa': '🇮🇳 ਪੰਜਾਬੀ',
        'mr': '🇮🇳 मराठी',
        'gu': '🇮🇳 ગુજરાતી',
        'bh': '🇮🇳 भोजपुरी',
        'ne': '🇳🇵 नेपाली',
        'sd': 'سنڌي',
        'si': '🇱🇰 සිංහල',
      },
      normalizeMap: {
        'ur': 'hi', 'bn': 'hi', 'pa': 'hi',
        'mr': 'hi', 'gu': 'hi', 'bh': 'hi',
        'ne': 'hi', 'sd': 'hi', 'si': 'hi',
      },
      dialectWords: {
        'आप': 'तुम', 'हम': 'मैं', 'वो': 'वह',
        'क्यों': 'काहे', 'कैसे': 'कइसे', 'अच्छा': 'ठीक',
        'पानी': 'जल', 'खाना': 'भोजन', 'सोना': 'निद्रा',
      },
    ),

    // درافيدية (جنوب الهند)
    'dravidian': LanguageCluster(
      name: 'தென்னிந்திய மொழிகள்',
      icon: '🇮🇳',
      languages: {
        'ta': '🇮🇳 தமிழ்',
        'te': '🇮🇳 తెలుగు',
        'kn': '🇮🇳 ಕನ್ನಡ',
        'ml': '🇮🇳 മലയാളം',
        'or': '🇮🇳 ଓଡ଼ିଆ',
      },
      normalizeMap: {
        'te': 'ta', 'kn': 'ta', 'ml': 'ta', 'or': 'ta',
      },
      dialectWords: {},
    ),

    // صينية
    'chinese': LanguageCluster(
      name: '中文方言',
      icon: '🇨🇳',
      languages: {
        'zh': '🇨🇳 普通話',
        'yue': '🇭🇰 廣東話',
        'nan': '🇹🇼 閩南語',
        'hak': '客家話',
        'wuu': '吳語',
        'cdo': '閩東語',
        'hsn': '湘語',
        'gan': '贛語',
      },
      normalizeMap: {
        'yue': 'zh', 'nan': 'zh', 'hak': 'zh',
        'wuu': 'zh', 'cdo': 'zh', 'hsn': 'zh',
        'gan': 'zh',
      },
      dialectWords: {
        '我': '我', '你': '你', '他': '他',
        '唔該': '謝謝', '早晨': '早上好',
      },
    ),

    // إسبانية ولهجاتها
    'spanish': LanguageCluster(
      name: 'Español',
      icon: '🇪🇸',
      languages: {
        'es': '🇪🇸 Español',
        'es-mx': '🇲🇽 Español MX',
        'es-ar': '🇦🇷 Español AR',
        'es-cl': '🇨🇱 Español CL',
        'es-co': '🇨🇴 Español CO',
        'es-pe': '🇵🇪 Español PE',
        'es-ve': '🇻🇪 Español VE',
      },
      normalizeMap: {
        'es-mx': 'es', 'es-ar': 'es', 'es-cl': 'es',
        'es-co': 'es', 'es-pe': 'es', 'es-ve': 'es',
      },
      dialectWords: {
        'vos': 'tú', 'che': 'amigo', 'carro': 'coche',
        'computadora': 'ordenador', 'jugo': 'zumo',
        'banana': 'plátano', 'chaqueta': 'campera',
      },
    ),

    // برتغالية
    'portuguese': LanguageCluster(
      name: 'Português',
      icon: '🇵🇹',
      languages: {
        'pt': '🇵🇹 Português PT',
        'pt-br': '🇧🇷 Português BR',
        'pt-ao': '🇦🇴 Português AO',
        'pt-mz': '🇲🇿 Português MZ',
      },
      normalizeMap: {
        'pt-br': 'pt', 'pt-ao': 'pt', 'pt-mz': 'pt',
      },
      dialectWords: {
        'você': 'tu', 'menino': 'garoto', 'ônibus': 'autocarro',
        'café da manhã': 'pequeno-almoço', 'geladeira': 'frigorífico',
      },
    ),

    // فرنسية
    'french': LanguageCluster(
      name: 'Français',
      icon: '🇫🇷',
      languages: {
        'fr': '🇫🇷 Français',
        'fr-ca': '🇨🇦 Français CA',
        'fr-be': '🇧🇪 Français BE',
        'fr-ch': '🇨🇭 Français CH',
      },
      normalizeMap: {
        'fr-ca': 'fr', 'fr-be': 'fr', 'fr-ch': 'fr',
      },
      dialectWords: {
        'char': 'voiture', 'magasinage': 'shopping',
        'courriel': 'e-mail', 'fin de semaine': 'weekend',
        'stationnement': 'parking', 'sac d'école': 'cartable',
      },
    ),

    // ألمانية
    'german': LanguageCluster(
      name: 'Deutsch',
      icon: '🇩🇪',
      languages: {
        'de': '🇩🇪 Deutsch',
        'de-at': '🇦🇹 Deutsch AT',
        'de-ch': '🇨🇭 Deutsch CH',
      },
      normalizeMap: {
        'de-at': 'de', 'de-ch': 'de',
      },
      dialectWords: {
        'Semmel': 'Brötchen', 'Tschüss': 'Servus',
        'Pfannkuchen': 'Palatschinken', 'Tomaten': 'Paradeiser',
        'Jänner': 'Januar', 'Feber': 'Februar',
      },
    ),

    // فارسية
    'persian': LanguageCluster(
      name: 'فارسی',
      icon: '🇮🇷',
      languages: {
        'fa': '🇮🇷 فارسی',
        'prs': '🇦🇫 Dari',
        'tg': '🇹🇯 Тоҷикӣ',
        'glk': 'گیلکی',
        'mzn': 'مازرونی',
      },
      normalizeMap: {
        'prs': 'fa', 'tg': 'fa', 'glk': 'fa', 'mzn': 'fa',
      },
      dialectWords: {
        'خوب': 'باس', 'نون': 'نان', 'آب': 'او',
        'بله': 'هان', 'نه': 'نه', 'خواهر': 'خاخور',
      },
    ),
  };

  // قائمة كل أكواد اللغات للـ API
  static const Map<String, String> _hundredLanguages = {
    'ar': '🇸🇦 العربية', 'en': '🇬🇧 English', 'fr': '🇫🇷 Français',
    'de': '🇩🇪 Deutsch', 'es': '🇪🇸 Español', 'pt': '🇵🇹 Português',
    'it': '🇮🇹 Italiano', 'nl': '🇳🇱 Nederlands', 'pl': '🇵🇱 Polski',
    'sv': '🇸🇪 Svenska', 'da': '🇩🇰 Dansk', 'no': '🇳🇴 Norsk',
    'fi': '🇫🇮 Suomi', 'el': '🇬🇷 Ελληνικά', 'ro': '🇷🇴 Română',
    'hu': '🇭🇺 Magyar', 'cs': '🇨🇿 Čeština', 'sk': '🇸🇰 Slovenčina',
    'hr': '🇭🇷 Hrvatski', 'sr': '🇷🇸 Српски', 'bg': '🇧🇬 Български',
    'uk': '🇺🇦 Українська', 'sq': '🇦🇱 Shqip', 'bs': '🇧🇦 Bosanski',
    'mk': '🇲🇰 Македонски', 'zh': '🇨🇳 中文', 'ja': '🇯🇵 日本語',
    'ko': '🇰🇷 한국어', 'vi': '🇻🇳 Tiếng Việt', 'th': '🇹🇭 ไทย',
    'my': '🇲🇲 မြန်မာ', 'km': '🇰🇭 ភាសាខ្មែរ', 'lo': '🇱🇦 ລາວ',
    'mn': '🇲🇳 Монгол', 'ne': '🇳🇵 नेपाली', 'si': '🇱🇰 සිංහල',
    'hi': '🇮🇳 हिन्दी', 'bn': '🇧🇩 বাংলা', 'pa': '🇮🇳 ਪੰਜਾਬੀ',
    'mr': '🇮🇳 मराठी', 'gu': '🇮🇳 ગુજરાતી', 'ta': '🇮🇳 தமிழ்',
    'te': '🇮🇳 తెలుగు', 'kn': '🇮🇳 ಕನ್ನಡ', 'ml': '🇮🇳 മലയാളം',
    'or': '🇮🇳 ଓଡ଼ିଆ', 'as': '🇮🇳 অসমীয়া', 'ks': '🇮🇳 कॉशुर',
    'tr': '🇹🇷 Türkçe', 'az': '🇦🇿 Azərbaycan', 'kk': '🇰🇿 Қазақ',
    'ky': '🇰🇬 Кыргыз', 'uz': '🇺🇿 Oʻzbek', 'tk': '🇹🇲 Türkmen',
    'crh': 'Qırımtatar', 'ba': 'Башҡорт', 'tt': 'Татар',
    'fa': '🇮🇷 فارسی', 'ur': '🇵🇰 اردو', 'ps': '🇦🇫 پښتو',
    'ku': '🇮🇶 Kurdî', 'sd': 'سنڌي', 'bal': 'بلوچی',
    'sw': '🇹🇿 Kiswahili', 'ha': '🇳🇬 Hausa', 'yo': '🇳🇬 Yorùbá',
    'ig': '🇳🇬 Igbo', 'am': '🇪🇹 አማርኛ', 'so': '🇸🇴 Soomaali',
    'rw': '🇷🇼 Kinyarwanda', 'sn': '🇿🇼 Shona', 'st': '🇿🇦 Sesotho',
    'tl': '🇵🇭 Filipino', 'ms': '🇲🇾 Bahasa Melayu', 'id': '🇮🇩 Bahasa Indonesia',
    'jw': 'Basa Jawa', 'su': 'Basa Sunda', 'ceb': 'Cebuano',
    'lb': '🇱🇺 Lëtzebuergesch', 'mt': '🇲🇹 Malti', 'ga': '🇮🇪 Gaeilge',
    'cy': '🏴 Cymraeg', 'gd': '🏴 Gàidhlig', 'is': '🇮🇸 Íslenska',
    'lv': '🇱🇻 Latviešu', 'lt': '🇱🇹 Lietuvių', 'et': '🇪🇪 Eesti',
    'hy': '🇦🇲 Հայերեն', 'ka': '🇰🇳 ქართული',
  };

  Map<String, double> _dialectConfidence = {};

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _apiKey = _prefs.getString('ai_api_key') ?? '';
    _isPremium = _prefs.getBool('is_premium') ?? false;
    notifyListeners();
  }

  /// 🎯 الوظيفة الرئيسية: تحليل النص وتحديد اللهجة
  LanguageCluster? detectDialect(String text, {String? preferredCluster}) {
    if (text.trim().isEmpty) return null;

    // حساب الثقة لكل كتلة لغوية
    Map<LanguageCluster, double> scores = {};

    for (final cluster in languageClusters.values) {
      double score = 0;
      int matches = 0;

      // فحص كلمات اللهجة
      for (final word in cluster.dialectWords.keys) {
        if (text.contains(word)) {
          score += 1.0;
          matches++;
        }
      }

      // فحص رموز اللغة
      for (final langCode in cluster.languages.keys) {
        final langName = cluster.languages[langCode] ?? '';
        if (text.toLowerCase().contains(langName.toLowerCase())) {
          score += 0.5;
        }
      }

      // تحسين النتيجة بناءً على المحارف الخاصة
      if (_hasSpecialChars(text, cluster)) {
        score += 0.3;
      }

      if (score > 0) {
        scores[cluster] = score + (matches * 0.2);
      }
    }

    // اختيار أفضل كتلة
    if (scores.isEmpty) return null;

    final bestCluster = scores.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    _dialectConfidence = {for (final c in scores.entries) c.key.name: c.value};

    return bestCluster;
  }

  /// 🔗 تحويل اللهجة إلى اللغة الأم
  String normalizeDialect(String text, LanguageCluster cluster) {
    String normalized = text;

    // تطبيق قاموس اللهجة
    for (final entry in cluster.dialectWords.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }

    return normalized;
  }

  /// 🌐 تحديد لغة الترجمة المثلى
  String resolveTargetLanguage(String userLang, String targetFromUI) {
    // هل اللغة الهدف ضمن كتلة لغوية؟
    for (final cluster in languageClusters.values) {
      if (cluster.languages.containsKey(targetFromUI)) {
        // اللغة المطلوبة هي لغة رئيسية
        return targetFromUI;
      }
      // هل اللغة المطلوبة لهجة من هذه الكتلة؟
      if (cluster.normalizeMap.containsKey(targetFromUI)) {
        return cluster.normalizeMap[targetFromUI] ?? targetFromUI;
      }
    }
    return targetFromUI;
  }

  /// 🔄 إعادة التوجيه الذكي: إذا الترجمة عادت بلغة مختلفة
  String? smartRedirect(String translatedText, String targetLang) {
    // تحقق من أن النص المترجم ينتمي للغة الهدف
    for (final cluster in languageClusters.values) {
      if (cluster.languages.containsKey(targetLang)) {
        // تحقق من محارف اللغة
        if (!_hasSpecialChars(translatedText, cluster)) {
          // الترجمة قد تكون خاطئة — جرب لغة أخرى من نفس الكتلة
          for (final altLang in cluster.languages.keys) {
            if (altLang != targetLang) {
              return altLang; // اقتراح لغة بديلة
            }
          }
        }
      }
    }
    return null; // الترجمة صحيحة
  }

  /// 🧪 التحقق من المحارف الخاصة بالكتلة اللغوية
  bool _hasSpecialChars(String text, LanguageCluster cluster) {
    switch (cluster.name) {
      case 'العربية ولهجاتها':
        return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      case 'English Dialects':
        return RegExp(r'[a-zA-Z]').hasMatch(text);
      case 'Türk Dilleri':
        return RegExp(r'[a-zA-ZğüşıöçĞÜŞİÖÇ]').hasMatch(text);
      case 'भारतीय भाषाएँ':
        return RegExp(r'[\u0900-\u097F]').hasMatch(text);
      case 'தென்னிந்திய மொழிகள்':
        return RegExp(r'[\u0B80-\u0BFF\u0C00-\u0C7F\u0C80-\u0CFF\u0D00-\u0D7F]').hasMatch(text);
      case '中文方言':
        return RegExp(r'[\u4E00-\u9FFF]').hasMatch(text);
      case 'Español':
        return RegExp(r'[a-zA-ZáéíóúñüÁÉÍÓÚÑÜ]').hasMatch(text);
      case 'Português':
        return RegExp(r'[a-zA-ZáâãçéêíóôõúüÁÂÃÇÉÊÍÓÔÕÚÜ]').hasMatch(text);
      case 'Français':
        return RegExp(r'[a-zA-ZàâçéèêëîïôùûüÀÂÇÉÈÊËÎÏÔÙÛÜ]').hasMatch(text);
      case 'Deutsch':
        return RegExp(r'[a-zA-ZäöüßÄÖÜ]').hasMatch(text);
      case 'فارسی':
        return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      default:
        return false;
    }
  }

  /// 📊 الحصول على نسبة الثقة باللهجة المكتشفة
  Map<String, double> getConfidence() => Map.unmodifiable(_dialectConfidence);

  /// 💡 اقتراح أفضل لغة ترجمة بناءً على النص
  String suggestTargetLanguage(String text) {
    final cluster = detectDialect(text);
    if (cluster == null) return 'en';

    // اقتراح لغة مختلفة عن لغة المستخدم
    for (final code in cluster.languages.keys) {
      if (code != 'ar' && code != cluster.normalizeMap.keys.first) {
        return code;
      }
    }
    return 'en';
  }

  /// 📋 الحصول على كل اللغات (100 لغة)
  Map<String, String> getAllLanguages() => Map.unmodifiable(_hundredLanguages);

  /// 📋 الحصول على اللغات المجمّعة (Clustered View)
  Map<String, Map<String, String>> getClusteredLanguages() {
    final result = <String, Map<String, String>>{};

    for (final cluster in languageClusters.values) {
      result[cluster.name] = Map.from(cluster.languages);
    }

    // باقي اللغات (غير المجمّعة)
    final usedCodes = <String>{};
    for (final cluster in languageClusters.values) {
      usedCodes.addAll(cluster.languages.keys);
    }

    final others = <String, String>{};
    for (final entry in _hundredLanguages.entries) {
      if (!usedCodes.contains(entry.key)) {
        others[entry.key] = entry.value;
      }
    }
    if (others.isNotEmpty) {
      result['🌐 لغات أخرى'] = others;
    }

    return result;
  }

  /// 🏷️ الحصول على اسم الكتلة اللغوية
  String getClusterName(String langCode) {
    for (final cluster in languageClusters.values) {
      if (cluster.languages.containsKey(langCode)) {
        return '${cluster.icon} ${cluster.name}';
      }
    }
    return '🌐 أخرى';
  }

  /// 🎯 الترجمة الذكية مع اكتشاف اللهجة وإعادة التوجيه
  Future<String> smartTranslate(String text, String targetLang, {String? apiKey}) async {
    if (text.trim().isEmpty) return '';

    // 1. كشف اللهجة
    final cluster = detectDialect(text);
    String normalizedText = text;
    String actualTarget = targetLang;

    if (cluster != null) {
      // 2. تطبيع اللهجة
      normalizedText = normalizeDialect(text, cluster);

      // 3. حل اللغة الهدف (إذا كانت لهجة، نحولها للغة الأم)
      actualTarget = resolveTargetLanguage('auto', targetLang);

      debugPrint('🦂 AI Merger: Detected ${cluster.name} → Normalized → Translating to $actualTarget');
    }

    // 4. ترجمة عبر API
    try {
      final key = apiKey ?? _apiKey;
      if (key.isNotEmpty) {
        // Gemini API للترجمة الذكية
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=$key',
        );
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'contents': [{
              'parts': [{
                'text': 'أنت مترجم ذكي ومحلل لهجات. النص التالي قد يكون بلهجة محلية. '
                    'قم بتحليل اللهجة أولاً، ثم ترجم إلى $actualTarget. '
                    'أعد فقط الترجمة:\n\n$normalizedText'
              }]
            }],
            'generationConfig': {
              'temperature': 0.3,
              'maxOutputTokens': 500,
            },
          }),
        ).timeout(const Duration(seconds: 15));

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          final translated =
              data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
          if (translated != null && translated.isNotEmpty) {
            // 5. التحقق من الترجمة وإعادة التوجيه إذا لزم الأمر
            final redirect = smartRedirect(translated, actualTarget);
            if (redirect != null) {
              debugPrint('🦂 AI Merger: Redirect suggested → $redirect');
              // إعادة الترجمة باللغة المصححة
              return smartTranslate(text, redirect, apiKey: key);
            }
            return translated;
          }
        }
      }

      // Fallback: LibreTranslate
      final resp = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': normalizedText,
          'source': 'auto',
          'target': actualTarget,
          'format': 'text',
        }),
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
}

/// 🏗️ هيكل الكتلة اللغوية
class LanguageCluster {
  final String name;
  final String icon;
  final Map<String, String> languages;
  final Map<String, String> normalizeMap;
  final Map<String, String> dialectWords;

  const LanguageCluster({
    required this.name,
    required this.icon,
    required this.languages,
    required this.normalizeMap,
    required this.dialectWords,
  });
}
