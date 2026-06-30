import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService extends ChangeNotifier {
  List<Map<String, dynamic>> _hadiths = [];
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _revelationReasons = [];
  List<Map<String, dynamic>> _translations = [];

  List<Map<String, dynamic>> get hadiths => _hadiths;
  List<Map<String, dynamic>> get stories => _stories;
  List<Map<String, dynamic>> get revelationReasons => _revelationReasons;

  Future<void> initialize() async {
    await loadLocalData();
    await _loadTranslations();
  }

  Future<void> loadLocalData() async {
    // أحاديث قدسية
    try {
      final hadithData = await rootBundle.loadString('assets/data/hadith_qudsi.json');
      _hadiths = List<Map<String, dynamic>>.from(json.decode(hadithData));
    } catch (_) {
      _hadiths = [
        {'text': 'يقول الله تعالى: أنا عند ظن عبدي بي', 'source': 'قدسي'},
        {'text': 'يقول الله: يا عبادي إني حرمت الظلم على نفسي', 'source': 'قدسي'},
      ];
    }

    // قصص
    try {
      final storiesData = await rootBundle.loadString('assets/data/stories.json');
      _stories = List<Map<String, dynamic>>.from(json.decode(storiesData));
    } catch (_) {
      _stories = [
        {'title': 'قصة أصحاب الكهف', 'text': 'قصة الفتية الذين آمنوا بربهم...', 'category': 'quran'},
        {'title': 'قصة موسى مع الخضر', 'text': 'قصة موسى عليه السلام مع الخضر...', 'category': 'prophets'},
      ];
    }

    // أسباب نزول
    try {
      final asbabData = await rootBundle.loadString('assets/data/asbab_nuzul.json');
      _revelationReasons = List<Map<String, dynamic>>.from(json.decode(asbabData));
    } catch (_) {
      _revelationReasons = [
        {'surah': 'الفاتحة', 'ayah': '1', 'reason': 'سبب نزول سورة الفاتحة...', 'text': ''},
      ];
    }

    notifyListeners();
  }

  Future<void> _loadTranslations() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString('translation_history');
    if (s != null) {
      try {
        _translations = List<Map<String, dynamic>>.from(
          (json.decode(s) as List).map((e) => Map<String, dynamic>.from(e)),
        );
      } catch (_) {}
    }
  }

  Future<void> saveTranslation(String src, String trg, {String? sourceLang, String? targetLang}) async {
    _translations.insert(0, {
      'source': src,
      'translated': trg,
      'sourceLang': sourceLang ?? 'auto',
      'targetLang': targetLang ?? 'ar',
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (_translations.length > 50) _translations = _translations.sublist(0, 50);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('translation_history', json.encode(_translations));
  }

  Map<String, dynamic> getRandomHadith() {
    if (_hadiths.isEmpty) return {'text': 'لا إله إلا الله'};
    return _hadiths[Random().nextInt(_hadiths.length)];
  }

  Map<String, dynamic> getRandomStory() {
    if (_stories.isEmpty) return {'title': 'قصة', 'text': 'لم يتم تحميل القصص'};
    return _stories[Random().nextInt(_stories.length)];
  }

  Map<String, dynamic> getRandomAsbab() {
    if (_revelationReasons.isEmpty) return {'surah': '', 'ayah': '', 'reason': '', 'text': ''};
    return _revelationReasons[Random().nextInt(_revelationReasons.length)];
  }

  List<Map<String, dynamic>> getStoriesByCategory(String c) {
    return _stories.where((s) => s['category'] == c).toList();
  }
}
