import 'package:flutter/foundation.dart';

class DatabaseService extends ChangeNotifier {
  final Map<String, List<Map<String, dynamic>>> _data = {};

  Future<void> loadData() async {
    // في النسخة الحقيقية: تحميل من JSON/multiplatform database
    debugPrint('DatabaseService: loaded');
    notifyListeners();
  }

  List<Map<String, dynamic>> getStories(String category) => _data[category] ?? [];
  List<Map<String, dynamic>> getHadiths() => _data['hadith'] ?? [];
}
