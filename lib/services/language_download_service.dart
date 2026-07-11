import 'package:flutter/material.dart';

class LanguageDownloadService extends ChangeNotifier {
  static final LanguageDownloadService _instance = LanguageDownloadService._internal();
  factory LanguageDownloadService() => _instance;
  LanguageDownloadService._internal();

  final Map<String, bool> _downloaded = {};
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  Future<void> initialize() async {
    notifyListeners();
  }

  bool isLanguageDownloaded(String lang) => _downloaded[lang] ?? false;

  Future<void> downloadLanguage(String lang) async {
    _isDownloading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 2));
    _downloaded[lang] = true;
    _isDownloading = false;
    notifyListeners();
  }
}
