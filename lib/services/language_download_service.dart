import 'package:flutter/foundation.dart';

class LanguageDownloadService extends ChangeNotifier {
  final List<Map<String, String>> _downloadedLanguages = [];
  List<Map<String, String>> get downloadedLanguages => _downloadedLanguages;
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  Future<void> initialize() async { debugPrint('LanguageDownloadService: initialized'); }

  Future<bool> downloadLanguage(String langCode) async {
    _isDownloading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _downloadedLanguages.add({'code': langCode, 'name': langCode});
    _isDownloading = false;
    notifyListeners();
    return true;
  }

  bool isLanguageDownloaded(String langCode) => _downloadedLanguages.any((l) => l['code'] == langCode);

  Future<void> deleteLanguage(String langCode) async {
    _downloadedLanguages.removeWhere((l) => l['code'] == langCode);
    notifyListeners();
    debugPrint('LanguageDownloadService: deleted $langCode');
  }
}
