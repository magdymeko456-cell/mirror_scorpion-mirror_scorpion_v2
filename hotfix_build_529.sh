#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================
# 🦂 HOTFIX — إصلاح Build Error #529
# ==============================================================
# الأخطاء:
# 1. settings_screen.dart — أسرار import/class خارج الملف
# 2. tts_service.dart — getVoices() + setVoice() غير متوافقين
# ==============================================================
set -e

cd ~/mirror_scorpion/mirror_scorpion_v2

echo "================================================"
echo "  🦂 PHASE 1 HOTFIX — Build Error #529"
echo "  📅 $(date '+%Y-%m-%d %H:%M:%S')"
echo "================================================"

# ────────────────────────────────────────────────
# الإصلاح 1: settings_screen.dart — إزالة الأسطر الزائدة
# ────────────────────────────────────────────────
echo ""
echo "📌 [1/2] إصلاح settings_screen.dart — إزالة import/class المكرر..."

# نحتفظ فقط بالأسطر من بداية الملف حتى السطر الذي يظهر فيه الملف الأصلي
# المشكلة: الباش السابق وضع heredoc داخل heredoc فتكررت الأسطر
# سنحذف الملف ونعيد إنشاؤه من جديد بشكل صحيح

cat > lib/features/settings/settings_screen.dart << 'SETTINGS_EOF'
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import '../../services/premium_verification_service.dart';
import '../../services/ai_service.dart';
import '../../services/floating_bubble_service.dart';
import '../../core/widgets/shared_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _patchController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _darkMode = true;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  void _loadApiKey() {
    final ai = context.read<AIService>();
    if (_apiKeyController.text.isEmpty) {
      _apiKeyController.text = ai.apiKey;
    }
  }

  void _saveApiKey() {
    final ai = context.read<AIService>();
    ai.apiKey = _apiKeyController.text;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم حفظ مفتاح API')),
    );
  }

  @override
  void dispose() {
    _patchController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tts = context.watch<TTSService>();
    final premium = context.watch<PremiumVerificationService>();
    final langService = context.watch<LanguageService>();
    final bubbleService = context.watch<FloatingBubbleService>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== الوضع المظلم =====
          Card(
            color: Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.dark_mode, color: Colors.amber),
              title: const Text('الوضع الداكن', style: TextStyle(color: Colors.white)),
              trailing: Switch(
                value: _darkMode,
                activeColor: Colors.amber,
                onChanged: (val) {
                  setState(() => _darkMode = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== الصوت الحالي =====
          Card(
            color: Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.record_voice_over, color: Colors.pinkAccent),
                  title: const Text('الصوت الحالي', style: TextStyle(color: Colors.white)),
                  subtitle: Text(
                    '${tts.currentVoiceName} — ${tts.availableVoices[tts.currentVoiceIndex]['desc'] ?? ''}',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white70),
                        onPressed: () => tts.previousVoice(),
                      ),
                      Text('${tts.currentVoiceIndex + 1}/${tts.availableVoices.length}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12)),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white70),
                        onPressed: () => tts.nextVoice(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Colors.white12),
                ListTile(
                  leading: const Icon(Icons.volume_up, color: Colors.white54),
                  title: const Text('اختبار الصوت', style: TextStyle(color: Colors.white54, fontSize: 14)),
                  onTap: () => tts.speak('بسم الله الرحمن الرحيم'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ===== الفقاعة العائمة =====
          Card(
            color: Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: Icon(Icons.bubble_chart, color: bubbleService.isStarted ? Colors.blueAccent : Colors.grey),
              title: const Text('الفقاعة العائمة', style: TextStyle(color: Colors.white)),
              subtitle: Text(
                bubbleService.isStarted ? 'نشطة' : 'غير نشطة',
                style: TextStyle(color: bubbleService.isStarted ? Colors.greenAccent : Colors.white54),
              ),
              trailing: Switch(
                value: bubbleService.isStarted,
                activeColor: Colors.blueAccent,
                onChanged: (_) => bubbleService.toggleBubble(),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== الذكاء الاصطناعي — مفتاح API =====
          Card(
            color: Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.tealAccent, size: 20),
                      SizedBox(width: 8),
                      Text('الذكاء الاصطناعي', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('أدخل مفتاح Gemini API لتفعيل الإلهام الذكي والرسائل المخصصة',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _apiKeyController,
                    decoration: InputDecoration(
                      hintText: 'مفتاح Gemini API...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.all(12),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.save, color: Colors.tealAccent),
                        onPressed: _saveApiKey,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    obscureText: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ===== تنزيل اللغات =====
          Card(
            color: Colors.white.withOpacity(0.05),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: ListTile(
              leading: const Icon(Icons.language, color: Colors.cyanAccent),
              title: const Text('تنزيل اللغات', style: TextStyle(color: Colors.white)),
              subtitle: const Text('تحميل حزم اللغات للترجمة بدون إنترنت',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              trailing: const Icon(Icons.download, color: Colors.cyanAccent),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: const Color(0xFF1B2838),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (ctx) {
                    final codes = langService.getLanguageCodes();
                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('اختر لغة للتحميل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 8),
                          const Text('اللغات التي تم تحميلها ستعمل بدون إنترنت',
                              style: TextStyle(color: Colors.white54, fontSize: 12)),
                          const Divider(color: Colors.white24),
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              itemCount: codes.length,
                              itemBuilder: (_, i) {
                                final code = codes[i];
                                final downloaded = langService.downloadedLanguages.containsKey(code);
                                return ListTile(
                                  dense: true,
                                  title: Text(langService.getLanguageName(code), style: const TextStyle(color: Colors.white, fontSize: 14)),
                                  trailing: downloaded
                                      ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
                                      : IconButton(
                                          icon: const Icon(Icons.download, color: Colors.cyanAccent, size: 20),
                                          onPressed: () {
                                            langService.downloadLanguage(code);
                                            Navigator.pop(ctx);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('✅ جارِ تحميل ${langService.getLanguageName(code)}')),
                                            );
                                          },
                                        ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // ===== النسخة PRO =====
          Card(
            color: Colors.amber.withOpacity(0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.amber.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(premium.isPremium ? Icons.workspace_premium : Icons.lock,
                          color: Colors.amber, size: 28),
                      const SizedBox(width: 8),
                      Text(premium.isPremium ? '👑 PRO مفعلة' : '👑 النسخة PRO',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'مزايا PRO:\n• ترجمة مستندات غير محدودة\n• استنساخ صوت المستخدم (AI)\n• تحويل القصص إلى فيديوهات\n• ترجمة أوفلاين بدون إنترنت',
                    style: TextStyle(fontSize: 13, height: 1.6), textAlign: TextAlign.center),
                  const SizedBox(height: 16),

                  if (!premium.isPremium) ...[
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text('ID: ${premium.deviceId}',
                                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.white70)),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.amber),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: premium.deviceId));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✅ تم نسخ معرف الجهاز')));
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _patchController,
                      decoration: InputDecoration(
                        labelText: '🔑 أدخل باتش التفعيل المشفر',
                        labelStyle: const TextStyle(color: Colors.white54),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.paste, color: Colors.grey),
                          onPressed: () async {
                            final data = await Clipboard.getData(Clipboard.kTextPlain);
                            if (data?.text != null) _patchController.text = data!.text!;
                          },
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_patchController.text.isNotEmpty) {
                            final success = await premium.activatePremium(_patchController.text);
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('🎉 تم تفعيل النسخة PRO بنجاح!'), backgroundColor: Colors.green));
                            } else if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('❌ كود التفعيل غير صالح'), backgroundColor: Colors.red));
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        ),
                        child: const Text('🔓 تفعيل الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 48),
                          SizedBox(height: 8),
                          Text('✅ PRO نشطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),
                  const Text('📞 للدعم:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                  const Text('واتس: 01017341250\n01031680816\n01558203456',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const Text('📧 dosoky.server@gmail.com',
                      style: TextStyle(color: Colors.white54, fontSize: 12)),
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 8),
                  const Text('للاستفسارات والتفعيل:', style: TextStyle(color: Colors.white54, fontSize: 11)),
                  const Text('واتساب: 01017341250', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const Text('واتساب: 01031680816', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const Text('واتساب: 01558203456', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  const Text('البريد: dosoky.server@gmail.com', style: TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Opacity(
              opacity: 0.3,
              child: Column(
                children: [
                  const WatermarkText(text: 'Mirror Scorpion'),
                  Text('v1.2.0 — ${premium.isPremium ? "PRO" : "Free"}',
                      style: const TextStyle(fontSize: 11, color: Colors.white54)),
                  const Text('المطور: Tamer Eldosoky', style: TextStyle(fontSize: 11, color: Colors.white54)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
SETTINGS_EOF
echo "✅ settings_screen.dart — تم إعادة الإنشاء بشكل صحيح"

# ────────────────────────────────────────────────
# الإصلاح 2: tts_service.dart — getVoices() + setVoice()
# ────────────────────────────────────────────────
echo ""
echo "📌 [2/2] إصلاح tts_service.dart — إزالة getVoices() + setVoice() غير المتوافقين..."

cat > lib/services/tts_service.dart << 'TTS_EOF'
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  double _volume = 1.0, _rate = 0.5, _pitch = 1.0;
  String _currentVoiceId = 'ar-xa';
  String _currentVoiceName = 'سارة';
  int _currentVoiceIndex = 0;

  bool get isSpeaking => _isSpeaking;
  double get volume => _volume;
  double get rate => _rate;
  double get pitch => _pitch;
  String get currentVoiceId => _currentVoiceId;
  String get currentVoiceName => _currentVoiceName;
  int get currentVoiceIndex => _currentVoiceIndex;

  // ===== 5 أصوات =====
  static const List<Map<String, String>> availableVoices = [
    {'id': 'ar-xa', 'name': 'سارة', 'gender': 'أنثى', 'desc': 'صوت أنثوي عربي دافئ'},
    {'id': 'ar-xa-warm', 'name': 'سلمى', 'gender': 'أنثى', 'desc': 'صوت أنثوي عربي ناعم'},
    {'id': 'ar-xa-female', 'name': 'سما', 'gender': 'أنثى', 'desc': 'صوت أنثوي عربي واضح'},
    {'id': 'ar-xa-male', 'name': 'سيف', 'gender': 'ذكر', 'desc': 'صوت ذكوري عربي قوي'},
    {'id': 'voice_clone_premium', 'name': 'المستخدم', 'gender': 'نسخ', 'desc': 'نسخة من صوتك (PRO)'},
  ];

  final Map<String, String> voiceLanguageMap = {
    'ar-xa': 'ar',
    'ar-xa-warm': 'ar',
    'ar-xa-female': 'ar',
    'ar-xa-male': 'ar',
    'voice_clone_premium': 'ar',
  };

  TTSService() {
    _tts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _tts.setErrorHandler((msg) {
      debugPrint('TTS Error: $msg');
      _isSpeaking = false;
      notifyListeners();
    });
  }

  /// النطق مع دعم اللغة والصوت المحدد
  Future<void> speak(String text, {String language = 'ar'}) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    notifyListeners();

    try {
      await _tts.setLanguage(language);
      await _tts.setSpeechRate(_rate);
      await _tts.setVolume(_volume);
      await _tts.setPitch(_pitch);
      await _tts.speak(text);
    } catch (e) {
      debugPrint('TTS Speak Error: $e');
      _isSpeaking = false;
      notifyListeners();
    }
  }

  /// إيقاف النطق
  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  /// تعيين الصوت المحدد
  Future<void> setVoice(String voiceId) async {
    _currentVoiceId = voiceId;
    final found = availableVoices.indexWhere((v) => v['id'] == voiceId);
    if (found >= 0) {
      _currentVoiceName = availableVoices[found]['name']!;
      _currentVoiceIndex = found;
    }
    final lang = voiceLanguageMap[voiceId] ?? 'ar';
    await _tts.setLanguage(lang);
    notifyListeners();
  }

  /// التبديل للصوت التالي
  Future<void> nextVoice() async {
    _currentVoiceIndex = (_currentVoiceIndex + 1) % availableVoices.length;
    await setVoice(availableVoices[_currentVoiceIndex]['id']!);
  }

  /// التبديل للصوت السابق
  Future<void> previousVoice() async {
    _currentVoiceIndex = (_currentVoiceIndex - 1 + availableVoices.length) % availableVoices.length;
    await setVoice(availableVoices[_currentVoiceIndex]['id']!);
  }

  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    await _tts.setVolume(_volume);
    notifyListeners();
  }

  Future<void> setRate(double r) async {
    _rate = r.clamp(0.0, 1.0);
    await _tts.setSpeechRate(_rate);
    notifyListeners();
  }

  Future<void> setPitch(double p) async {
    _pitch = p.clamp(0.5, 2.0);
    await _tts.setPitch(_pitch);
    notifyListeners();
  }
}
TTS_EOF
echo "✅ tts_service.dart — تم إزالة getVoices() + setVoice() غير المتوافق"

# ────────────────────────────────────────────────
# رفع التعديلات
# ────────────────────────────────────────────────
echo ""
echo "================================================"
echo " ✅ HOTFIX COMPLETE"
echo "================================================"
echo ""
echo "📊 الإصلاحات:"
echo " 1. settings_screen.dart — ✅ إزالة الأسطر الزائدة، إعادة إنشاء نظيف"
echo " 2. tts_service.dart — ✅ إزالة getVoices() + إزالة invocation غير صحيح"
echo ""

cd ~/mirror_scorpion/mirror_scorpion_v2
git add -A
git commit -m "🐛 HOTFIX Build #529: إصلاح settings_screen و tts_service
- settings_screen.dart: إزالة import/class المكرر في نهاية الملف
- tts_service.dart: إزالة getVoices() (غير موجود في flutter_tts 4.2.5)
- tts_service.dart: إزالة setVoice() التي تستخدم Map<dynamic,dynamic>"
git push origin main

echo ""
echo "================================================"
echo " ✅ PUSH COMPLETE — سيبدأ البناء تلقائياً"
echo " https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/actions"
echo "================================================"
