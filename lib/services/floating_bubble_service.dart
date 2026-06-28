import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Enhanced Floating Bubble Service with overlay permissions
class FloatingBubbleService extends ChangeNotifier {
  static final FloatingBubbleService _instance = FloatingBubbleService._internal();
  
  factory FloatingBubbleService() => _instance;
  FloatingBubbleService._internal();
  
  late SharedPreferences _prefs;
  bool _isStarted = false;
  bool _isEnabled = false;
  double _opacity = 0.8;
  int _size = 120;
  String _selectedLanguage = 'en';
  bool _autoTranslate = true;
  bool _soundEnabled = true;
  
  static const MethodChannel _channel = MethodChannel('mirror_scorpion/bubble');

  // Getters
  bool get isStarted => _isStarted;
  bool get isEnabled => _isEnabled;
  double get opacity => _opacity;
  int get size => _size;
  String get selectedLanguage => _selectedLanguage;
  bool get autoTranslate => _autoTranslate;
  bool get soundEnabled => _soundEnabled;
  
  Future initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _loadSettings();
  }

  void _loadSettings() {
    _isEnabled = _prefs.getBool('bubble_enabled') ?? false;
    _opacity = _prefs.getDouble('bubble_opacity') ?? 0.8;
    _size = _prefs.getInt('bubble_size') ?? 120;
    _selectedLanguage = _prefs.getString('bubble_language') ?? 'en';
    _autoTranslate = _prefs.getBool('bubble_auto_translate') ?? true;
    _soundEnabled = _prefs.getBool('bubble_sound') ?? true;
    notifyListeners();
  }

  Future _saveSettings() async {
    await _prefs.setBool('bubble_enabled', _isEnabled);
    await _prefs.setDouble('bubble_opacity', _opacity);
    await _prefs.setInt('bubble_size', _size);
    await _prefs.setString('bubble_language', _selectedLanguage);
    await _prefs.setBool('bubble_auto_translate', _autoTranslate);
    await _prefs.setBool('bubble_sound', _soundEnabled);
  }

  Future startBubble(BuildContext context) async {
    if (_isStarted) return;
    try {
      await _channel.invokeMethod('createFloatingBubble', {
        'opacity': _opacity,
        'size': _size,
        'language': _selectedLanguage,
      });
      _isStarted = true;
      _isEnabled = true;
      await _saveSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error starting bubble: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الفقاعة العائمة غير مدعومة على هذا الجهاز')),
        );
      }
    }
  }

  Future stopBubble() async {
    try {
      await _channel.invokeMethod('stopBubble');
      _isStarted = false;
      _isEnabled = false;
      await _saveSettings();
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error stopping bubble: $e');
    }
  }

  Future toggleBubble(BuildContext context, bool enabled) async {
    if (enabled) {
      await startBubble(context);
    } else {
      await stopBubble();
    }
    notifyListeners();
  }

  Future setOpacity(double opacity) async {
    _opacity = opacity.clamp(0.3, 1.0);
    await _saveSettings();
    notifyListeners();
  }

  Future setSize(int size) async {
    _size = size.clamp(60, 200);
    await _saveSettings();
    notifyListeners();
  }

  Future setTargetLanguage(String language) async {
    _selectedLanguage = language;
    await _saveSettings();
    notifyListeners();
  }

  Future toggleAutoTranslate(bool enabled) async {
    _autoTranslate = enabled;
    await _saveSettings();
    notifyListeners();
  }
}
