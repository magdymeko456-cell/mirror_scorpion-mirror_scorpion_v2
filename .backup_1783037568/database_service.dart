import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class DatabaseService extends ChangeNotifier {
  List<Map<String, dynamic>> _hadiths = [];
  List<Map<String, dynamic>> _hadithQudsi = [];
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _reasons = [];
  List<Map<String, dynamic>> _prophetStories = [];

  List<Map<String, dynamic>> get hadiths => _hadiths;
  List<Map<String, dynamic>> get hadithQudsi => _hadithQudsi;
  List<Map<String, dynamic>> get stories => _stories;
  List<Map<String, dynamic>> get revelationReasons => _reasons;
  List<Map<String, dynamic>> get prophetStories => _prophetStories;

  List<Map<String, dynamic>> get quranStories =>
      _stories.where((s) => s['category'] == 'quran').toList();
  List<Map<String, dynamic>> get prophetList =>
      _prophetStories;
  List<Map<String, dynamic>> get womenStories =>
      _stories.where((s) => s['category'] == 'women').toList();
  List<Map<String, dynamic>> get animalStories =>
      _stories.where((s) => s['category'] == 'animal').toList();
  List<Map<String, dynamic>> get humanStories =>
      _stories.where((s) => s['category'] == 'human').toList();
  List<Map<String, dynamic>> get nationsStories =>
      _stories.where((s) => s['category'] == 'nations').toList();

  Future initialize() async {
    await _loadData();
  }

  Future _loadData() async {
    // الأحاديث القدسية
    try {
      final d = await rootBundle.loadString('assets/data/hadith_qudsi.json');
      _hadithQudsi = List<Map<String, dynamic>>.from(json.decode(d));
    } catch (_) {
      _hadithQudsi = [
        {'text': 'يقول الله تعالى: أنا عند ظن عبدي بي', 'source': 'حديث قدسي'},
        {'text': 'يقول الله تعالى: يا ابن آدم، إنك ما دعوتني ورجوتني غفرت لك', 'source': 'حديث قدسي'},
        {'text': 'يقول الله تعالى: قسمتُ الصلاة بيني وبين عبدي نصفين', 'source': 'حديث قدسي'},
      ];
    }

    // الأحاديث النبوية
    try {
      final d = await rootBundle.loadString('assets/data/hadiths.json');
      _hadiths = List<Map<String, dynamic>>.from(json.decode(d));
    } catch (_) {
      _hadiths = [
        {'text': 'إنما الأعمال بالنيات', 'source': 'رواه البخاري'},
        {'text': 'اتق الله حيثما كنت', 'source': 'رواه الترمذي'},
        {'text': 'لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه', 'source': 'رواه البخاري'},
      ];
    }

    // القصص
    try {
      final d = await rootBundle.loadString('assets/data/stories.json');
      _stories = List<Map<String, dynamic>>.from(json.decode(d));
    } catch (_) {
      _stories = [
        {'title': 'أصحاب الكهف', 'text': 'قصة الفتية الذين آمنوا بربهم وفرّوا بدينهم إلى الكهف...', 'category': 'quran'},
        {'title': 'موسى والخضر', 'text': 'قصة نبي الله موسى عليه السلام مع الخضر...', 'category': 'quran'},
        {'title': 'أصحاب الفيل', 'text': 'قصة أبرهة وجيشه وجيش الله...', 'category': 'quran'},
        {'title': 'هاجر عليها السلام', 'text': 'قصة أم إسماعيل والسعي بين الصفا والمروة...', 'category': 'women'},
        {'title': 'ناقة صالح', 'text': 'قصة ناقة نبي الله صالح عليه السلام...', 'category': 'animal'},
        {'title': 'قارون', 'text': 'قصة الغني الذي خسف الله به الأرض...', 'category': 'human'},
        {'title': 'قوم عاد', 'text': 'قوم هود الذين أهلكهم الله بريح صرصر...', 'category': 'nations'},
        {'title': 'قوم ثمود', 'text': 'قوم صالح الذين عقروا الناقة...', 'category': 'nations'},
      ];
    }

    // أسباب النزول
    try {
      final d = await rootBundle.loadString('assets/data/asbab_nuzul.json');
      _reasons = List<Map<String, dynamic>>.from(json.decode(d));
    } catch (_) {
      _reasons = [
        {'surah': 'الفاتحة', 'ayah': '1', 'text': 'بسم الله الرحمن الرحيم', 'reason': 'أول ما نزل من القرآن'},
        {'surah': 'العلق', 'ayah': '1', 'text': 'اقرأ باسم ربك الذي خلق', 'reason': 'أول آية نزلت على النبي صلى الله عليه وسلم في غار حراء'},
        {'surah': 'المسد', 'ayah': '1', 'text': 'تبت يدا أبي لهب', 'reason': 'نزلت في أبي لهب حين قال للنبي صلى الله عليه وسلم: تباً لك'},
        {'surah': 'الكوثر', 'ayah': '1', 'text': 'إنا أعطيناك الكوثر', 'reason': 'نزلت تسلية للنبي صلى الله عليه وسلم حين قالوا: إنه أبتر'},
      ];
    }

    // قصص الأنبياء (ابن كثير)
    try {
      final d = await rootBundle.loadString('assets/data/prophet_stories_ibn_kathir.json');
      _prophetStories = List<Map<String, dynamic>>.from(json.decode(d));
    } catch (_) {
      _prophetStories = [
        {'name': 'آدم عليه السلام', 'title': 'أبو البشر', 'text': 'خلق الله آدم من طين...'},
        {'name': 'نوح عليه السلام', 'title': 'شيخ المرسلين', 'text': 'أول الرسل، دعا قومه ألف سنة إلا خمسين عاماً...'},
        {'name': 'إبراهيم عليه السلام', 'title': 'خليل الرحمن', 'text': 'أبو الأنبياء، حطم الأصنام...'},
        {'name': 'موسى عليه السلام', 'title': 'كليم الله', 'text': 'أرسل إلى فرعون وقومه...'},
        {'name': 'عيسى عليه السلام', 'title': 'روح الله', 'text': 'ولد من غير أب، آتاه الله الإنجيل...'},
        {'name': 'محمد صلى الله عليه وسلم', 'title': 'خاتم الأنبياء', 'text': 'أشرف الخلق، خاتم المرسلين...'},
      ];
    }

    notifyListeners();
  }

  Map<String, dynamic> getRandomHadith() =>
      _hadiths.isEmpty ? {'text': 'لا إله إلا الله', 'source': ''}
          : _hadiths[Random().nextInt(_hadiths.length)];

  Map<String, dynamic> getRandomQudsi() =>
      _hadithQudsi.isEmpty ? {'text': 'الله أكبر', 'source': ''}
          : _hadithQudsi[Random().nextInt(_hadithQudsi.length)];

  Map<String, dynamic> getRandomAsbab() =>
      _reasons.isEmpty ? {'surah': '', 'ayah': '', 'reason': '', 'text': ''}
          : _reasons[Random().nextInt(_reasons.length)];

  List<Map<String, dynamic>> getStoriesByCategory(String c) =>
      _stories.where((s) => s['category'] == c).toList();
}
