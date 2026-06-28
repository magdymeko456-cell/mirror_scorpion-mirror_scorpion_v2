import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class DatabaseService extends ChangeNotifier {
  List<Map<String, dynamic>> hadiths = [];
  List<Map<String, dynamic>> quranStories = [];
  List<Map<String, dynamic>> prophetStories = [];
  List<Map<String, dynamic>> womenStories = [];
  List<Map<String, dynamic>> animalStories = [];
  List<Map<String, dynamic>> humanStories = [];
  List<Map<String, dynamic>> asbabNuzul = [];
  bool _loaded = false;

  Future<void> loadAllData() async {
    if (_loaded) return;
    try {
      hadiths = await _loadJson('assets/data/hadiths.json');
      quranStories = await _loadJson('assets/data/quran_stories.json');
      prophetStories = await _loadJson('assets/data/prophet_stories_ibn_kathir.json');
      asbabNuzul = await _loadJson('assets/data/asbab_nuzul.json');
      _loaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Database load error: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _loadJson(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final List<dynamic> list = jsonDecode(raw);
      return list.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Error loading $path: $e');
      return [];
    }
  }
}
