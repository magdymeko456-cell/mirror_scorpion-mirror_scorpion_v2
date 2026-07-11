import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dash_bubble_local/dash_bubble_local.dart';

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
      final hasOverlay = await DashBubble.instance.hasOverlayPermission();
      if (!hasOverlay) {
        final granted = await DashBubble.instance.requestOverlayPermission();
        if (!granted) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('يجب تفعيل إذن الظهور فوق التطبيقات')),
            );
          }
          return;
        }
      }
      final started = await DashBubble.instance.startBubble(
        bubbleOptions: BubbleOptions(
          bubbleIcon: "launcher_icon",
          distanceToClose: 100,
          enableAnimateToEdge: true,
          enableClose: true,
          bubbleSize: _size.toDouble(),
          opacity: _opacity,
        ),
        onTap: () => _onBubbleTapped(context),
      );
      if (started) {
        _isStarted = true;
        _isEnabled = true;
        await _saveSettings();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error starting bubble: $e');
      _isStarted = false;
    }
  }

  Future stopBubble() async {
    try {
      final stopped = await DashBubble.instance.stopBubble();
      if (stopped) {
        _isStarted = false;
        _isEnabled = false;
        await _saveSettings();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error stopping bubble: $e');
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
    if (_isStarted) {
      await stopBubble();
    }
    notifyListeners();
  }

  Future setSize(int size) async {
    _size = size.clamp(60, 200);
    await _saveSettings();
    if (_isStarted) {
      await stopBubble();
    }
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

  void _onBubbleTapped(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ميرور سكربيون - ترجمة فورية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('الفقاعة العائمة نشطة.'),
            const SizedBox(height: 10),
            Text('اللغة الحالية: $_selectedLanguage'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
