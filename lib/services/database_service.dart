import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
class DatabaseService extends ChangeNotifier {
  List<Map<String, dynamic>> _hadiths = [];
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _reasons = [];
  List<Map<String, dynamic>> get hadiths => _hadiths;
  List<Map<String, dynamic>> get stories => _stories;
  List<Map<String, dynamic>> get revelationReasons => _reasons;
  Future<void> initialize() async { await _loadData(); }
  Future<void> _loadData() async {
    try { final d = await rootBundle.loadString('assets/data/hadith_qudsi.json'); _hadiths = List<Map<String, dynamic>>.from(json.decode(d)); } catch (_) { _hadiths = [{'text':'يقول الله تعالى: أنا عند ظن عبدي بي','source':'قدسي'}]; }
    try { final d = await rootBundle.loadString('assets/data/stories.json'); _stories = List<Map<String, dynamic>>.from(json.decode(d)); } catch (_) { _stories = [{'title':'قصة أصحاب الكهف','text':'قصة الفتية الذين آمنوا...','category':'quran'}]; }
    try { final d = await rootBundle.loadString('assets/data/asbab_nuzul.json'); _reasons = List<Map<String, dynamic>>.from(json.decode(d)); } catch (_) { _reasons = [{'surah':'الفاتحة','ayah':'1','reason':'سبب نزول سورة الفاتحة...'}]; }
    notifyListeners();
  }
  List<Map<String, dynamic>> getStoriesByCategory(String c) => _stories.where((s) => s['category'] == c).toList();
  Map<String, dynamic> getRandomHadith() => _hadiths.isEmpty ? {'text':'لا إله إلا الله'} : _hadiths[Random().nextInt(_hadiths.length)];
  Map<String, dynamic> getRandomAsbab() => _reasons.isEmpty ? {'surah':'','ayah':'','reason':''} : _reasons[Random().nextInt(_reasons.length)];
}
