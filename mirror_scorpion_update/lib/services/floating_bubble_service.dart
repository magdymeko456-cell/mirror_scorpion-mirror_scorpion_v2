import 'package:flutter/material.dart';
import 'package:dash_bubble_local/dash_bubble_local.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

/// خدمة الفقاعة العائمة - ترجمة فورية من أي تطبيق
class FloatingBubbleService extends ChangeNotifier {
  static final FloatingBubbleService _instance = FloatingBubbleService._internal();
  factory FloatingBubbleService() => _instance;
  FloatingBubbleService._internal();

  bool _isStarted = false;
  bool _autoTranslate = false;
  String _sourceLang = 'auto';
  String _targetLang = 'ar';
  double _opacity = 0.9;
  double _bubbleSize = 110;

  bool get isStarted => _isStarted;
  bool get autoTranslate => _autoTranslate;
  String get sourceLang => _sourceLang;
  String get targetLang => _targetLang;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _autoTranslate = prefs.getBool('bubble_auto_translate') ?? false;
    _sourceLang = prefs.getString('bubble_source_lang') ?? 'auto';
    _targetLang = prefs.getString('bubble_target_lang') ?? 'ar';
  }

  Future<void> startBubble(BuildContext context) async {
    if (_isStarted) return;
    try {
      final hasPermission = await DashBubble.instance.hasOverlayPermission();
      if (!hasPermission) {
        await DashBubble.instance.requestOverlayPermission();
      }

      await DashBubble.instance.startBubble(
        bubbleOptions: BubbleOptions(
          bubbleIcon: "launcher_icon",
          bubbleSize: _bubbleSize,
          opacity: _opacity,
          enableClose: true,
          distanceToClose: 90,
        ),
        onTap: () => _handleBubbleTap(context),
      );

      _isStarted = true;
      notifyListeners();
      debugPrint('✅ الفقاعة العائمة مفعلة');
    } catch (e) {
      debugPrint('❌ خطأ في تشغيل الفقاعة: $e');
    }
  }

  void _handleBubbleTap(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("🦂 ميرور سكربيون",
                    style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(color: Colors.white10),
            ListTile(
              leading: const Icon(Icons.translate, color: Colors.blueAccent),
              title: const Text("ترجمة النص من الحافظة", style: TextStyle(color: Colors.white)),
              subtitle: const Text("ترجمة فورية لأي نص تنسخه", style: TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                await _translateClipboard(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: Colors.orangeAccent),
              title: const Text("تبديل لغات الترجمة", style: TextStyle(color: Colors.white)),
              trailing: Text("$_sourceLang → $_targetLang",
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () {
                Navigator.pop(ctx);
                _swapLanguages();
              },
            ),
            ListTile(
              leading: Icon(_autoTranslate ? Icons.toggle_on : Icons.toggle_off_outlined,
                  color: _autoTranslate ? Colors.greenAccent : Colors.white54),
              title: const Text("ترجمة تلقائية", style: TextStyle(color: Colors.white)),
              subtitle: const Text("ترجمة كل ما تنسخه تلقائياً", style: TextStyle(color: Colors.white38, fontSize: 12)),
              onTap: () {
                _autoTranslate = !_autoTranslate;
                _saveSettings();
                notifyListeners();
                Navigator.pop(ctx);
              },
            ),
            if (_isStarted)
              ListTile(
                leading: const Icon(Icons.stop_circle, color: Colors.redAccent),
                title: const Text("إيقاف الفقاعة", style: TextStyle(color: Colors.redAccent)),
                onTap: () async {
                  Navigator.pop(ctx);
                  await stopBubble();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _translateClipboard(BuildContext context) async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text == null || data.text!.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("لا يوجد نص في الحافظة للترجمة")),
          );
        }
        return;
      }

      final text = data.text!;
      // ترجمة باستخدام Google Translate
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_targetLang&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final translated = (result[0] as List).map((e) => e[0] as String).join();

        if (context.mounted) {
          await Clipboard.setData(ClipboardData(text: translated));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("✅ تمت الترجمة: $translated"),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في ترجمة الحافظة: $e');
    }
  }

  void _swapLanguages() {
    final temp = _sourceLang;
    _sourceLang = _targetLang;
    _targetLang = temp;
    _saveSettings();
    notifyListeners();
  }

  Future<void> stopBubble() async {
    try {
      await DashBubble.instance.stopBubble();
      _isStarted = false;
      notifyListeners();
      debugPrint('✅ تم إيقاف الفقاعة العائمة');
    } catch (e) {
      debugPrint('❌ خطأ في إيقاف الفقاعة: $e');
    }
  }

  void setOpacity(double value) {
    _opacity = value;
  }

  void setSize(double size) {
    _bubbleSize = size;
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bubble_auto_translate', _autoTranslate);
    await prefs.setString('bubble_source_lang', _sourceLang);
    await prefs.setString('bubble_target_lang', _targetLang);
  }
}
