import 'dart:async';
import 'package:flutter/material.dart';

class FloatingBubbleService extends ChangeNotifier {
  bool _isEnabled = false;
  bool _isStarted = false;
  double _opacity = 0.8;
  double _bubbleSize = 60;
  bool _autoTranslate = true;

  // إعدادات الترجمة من الفقاعة
  String _sourceLang = 'auto';
  String _targetLang = 'ar';
  bool _isOverlayVisible = false;

  // Stream للتواصل مع خدمة الـ Overlay الفعلية
  final StreamController<Map<String, dynamic>> _commandController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get commands => _commandController.stream;

  bool get isEnabled => _isEnabled;
  bool get isStarted => _isStarted;
  double get opacity => _opacity;
  double get bubbleSize => _bubbleSize;
  bool get autoTranslate => _autoTranslate;
  bool get isOverlayVisible => _isOverlayVisible;
  String get sourceLang => _sourceLang;
  String get targetLang => _targetLang;

  Future<void> initialize() async {
    _isEnabled = true;
    _isStarted = false;
    notifyListeners();
  }

  Future<void> startBubble(BuildContext context) async {
    _isStarted = true;
    _isEnabled = true;
    _isOverlayVisible = true;
    _commandController.add({
      'action': 'show',
      'sourceLang': _sourceLang,
      'targetLang': _targetLang,
    });
    notifyListeners();
  }

  Future<void> stopBubble() async {
    _isStarted = false;
    _isOverlayVisible = false;
    _commandController.add({'action': 'hide'});
    notifyListeners();
  }

  void toggleBubble() {
    if (_isStarted) {
      stopBubble();
    } else {
      _isStarted = true;
      _isEnabled = true;
      _isOverlayVisible = true;
      _commandController.add({
        'action': 'show',
        'sourceLang': _sourceLang,
        'targetLang': _targetLang,
      });
    }
    notifyListeners();
  }

  /// عند إغلاق الفقاعة من قبل المستخدم، تعود النصوص المترجمة للغتها الأصلية
  void onBubbleClosed() {
    _isStarted = false;
    _isOverlayVisible = false;
    _commandController.add({'action': 'restore_original'});
    notifyListeners();
  }

  void setSourceLang(String lang) {
    _sourceLang = lang;
    _commandController.add({'action': 'update_lang', 'sourceLang': lang});
    notifyListeners();
  }

  void setTargetLang(String lang) {
    _targetLang = lang;
    _commandController.add({'action': 'update_lang', 'targetLang': lang});
    notifyListeners();
  }

  void setOpacity(double value) {
    _opacity = value;
    notifyListeners();
  }

  void setBubbleSize(double value) {
    _bubbleSize = value;
    notifyListeners();
  }

  void setAutoTranslate(bool value) {
    _autoTranslate = value;
    _commandController.add({'action': 'auto_translate', 'enabled': value});
    notifyListeners();
  }

  @override
  void dispose() {
    _commandController.close();
    super.dispose();
  }
}
