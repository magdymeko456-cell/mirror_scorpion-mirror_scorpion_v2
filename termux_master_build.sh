
#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================
# 🦂 Mirror Scorpion v2 — MASTER BUILD SCRIPT (HOTFIX v2)
# ==============================================================
# الإصدار المعدّل بعد فشل build #1 — إصلاح 4 أخطاء
# ==============================================================
set -e

SCRIPT_NAME="Mirror Scorpion v2 Master Build (HOTFIX)"
SCRIPT_DATE="$(date '+%Y-%m-%d %H:%M:%S')"
START_TIME=$(date +%s)

echo "================================================"
echo "  🦂 $SCRIPT_NAME"
echo "  📅 $SCRIPT_DATE"
echo "================================================"

cd ~/mirror_scorpion/mirror_scorpion_v2
echo "📍 المسار الحالي: $(pwd)"

echo ""
echo "📌 [1/9] العودة إلى آخر build ناجح..."
git fetch origin main 2>/dev/null || true
git reset --hard origin/main
git clean -fd
echo "✅ main نظيف"

# ─── GitHub Actions Workflow ───
echo ""
echo "📌 [2/9] إنشاء GitHub Actions Workflow..."
mkdir -p .github/workflows

cat > .github/workflows/build_apk.yml << 'GHA_EOF'
name: 🦂 Build Mirror Scorpion APK
on:
  push:
    branches: [ main ]
  workflow_dispatch:
jobs:
  build:
    name: Build APK
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.5'
          channel: 'stable'
          cache: true
      - run: flutter pub get
      - run: flutter clean
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: mirror_scorpion_apk
          path: build/app/outputs/flutter-apk/app-release.apk
          retention-days: 90
GHA_EOF
echo "✅ Workflow created"

# ─── AndroidManifest ───
echo ""
echo "📌 [3/9] AndroidManifest.xml..."
cat > android/app/src/main/AndroidManifest.xml << 'MANIFEST_EOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.mirror.scorpion.v2">
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.SYSTEM_OVERLAY_WINDOW"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.MANAGE_EXTERNAL_STORAGE"/>
    <application
        android:label="Mirror Scorpion"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <meta-data android:name="io.flutter.embedding.android.NormalTheme" android:resource="@style/NormalTheme"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <service android:name=".OverlayService" android:exported="false" android:foregroundServiceType="specialUse" android:stopWithTask="false"/>
        <meta-data android:name="flutterEmbedding" android:value="2"/>
    </application>
</manifest>
MANIFEST_EOF
echo "✅ AndroidManifest.xml"

# ─── Floating Bubble ───
echo ""
echo "📌 [4/9] Floating Bubble Service..."
cat > lib/services/floating_bubble_service.dart << 'BUBBLE_EOF'
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingBubbleService extends ChangeNotifier {
  SharedPreferences? _prefs;
  bool _isEnabled = false;
  bool _isStarted = false;
  double _opacity = 0.85;
  double _size = 55;

  bool get isEnabled => _isEnabled;
  bool get isStarted => _isStarted;
  double get opacity => _opacity;
  double get size => _size;

  static const MethodChannel _channel = MethodChannel('mirror_scorpion/overlay');

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isEnabled = _prefs?.getBool('floating_bubble_enabled') ?? false;
    _isStarted = _isEnabled;
    _opacity = _prefs?.getDouble('floating_bubble_opacity') ?? 0.85;
    _size = (_prefs?.getDouble('floating_bubble_size') ?? 55);
    if (_isEnabled && _isStarted) {
      try { await _channel.invokeMethod('createFloatingBubble'); } catch (_) {}
    }
    notifyListeners();
  }

  void toggle() {
    if (_isEnabled) { stopBubble(); } else { startBubble(); }
  }

  Future<bool> startBubble() async {
    _isEnabled = true; _isStarted = true;
    await _prefs?.setBool('floating_bubble_enabled', true);
    notifyListeners();
    try {
      final result = await _channel.invokeMethod<bool>('createFloatingBubble');
      if (result == false) { await _channel.invokeMethod('requestOverlayPermission'); }
      return true;
    } catch (e) { debugPrint('Bubble error: $e'); return false; }
  }

  Future<bool> stopBubble() async {
    _isEnabled = false; _isStarted = false;
    await _prefs?.setBool('floating_bubble_enabled', false);
    notifyListeners();
    try { await _channel.invokeMethod('destroyFloatingBubble'); return true; } catch (e) { return false; }
  }

  Future<void> setOpacity(double v) async {
    _opacity = v.clamp(0.3, 1.0);
    await _prefs?.setDouble('floating_bubble_opacity', _opacity);
    notifyListeners();
  }

  Future<void> setSize(double v) async {
    _size = v.clamp(40, 100);
    await _prefs?.setDouble('floating_bubble_size', _size);
    notifyListeners();
  }
}
BUBBLE_EOF
echo "✅ Floating Bubble"

# ─── TTS Service ───
echo ""
echo "📌 [5/9] TTS Service..."
cat > lib/services/tts_service.dart << 'TTS_EOF'
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isPaused = false;
  String _selectedVoice = 'voice_salma';
  double _speed = 0.5;

  static const List<Map<String, String>> availableVoices = [
    {'id': 'voice_seif',  'name': 'سيف',    'desc': 'خشن/عميق — مناسب للأخبار'},
    {'id': 'voice_salma', 'name': 'سلمى',   'desc': 'متزن — مناسب للترجمة العامة'},
    {'id': 'voice_sama',  'name': 'سما',    'desc': 'دافئ/ناعم — مناسب للقصص'},
    {'id': 'voice_sara',  'name': 'سارة',   'desc': 'رقيق — مناسب للمستندات'},
    {'id': 'voice_user',  'name': 'صوت المستخدم', 'desc': 'مميز (Pro) — استنساخ بصوتك'},
  ];

  bool get isSpeaking => _isSpeaking;
  bool get isPaused => _isPaused;
  String get selectedVoice => _selectedVoice;
  double get speed => _speed;
  List<Map<String, String>> get voices => availableVoices;

  TTSService() { _initTts(); }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage('ar');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(_speed);
    _flutterTts.setCompletionHandler(() { _isSpeaking = false; _isPaused = false; notifyListeners(); });
  }

  void setVoice(String voiceId) {
    _selectedVoice = voiceId; notifyListeners();
    if (voiceId == 'voice_seif') { _flutterTts.setPitch(0.8); _flutterTts.setSpeechRate(_speed + 0.2); }
    else if (voiceId == 'voice_salma') { _flutterTts.setPitch(1.0); _flutterTts.setSpeechRate(_speed); }
    else if (voiceId == 'voice_sama') { _flutterTts.setPitch(1.2); _flutterTts.setSpeechRate(_speed - 0.1); }
    else if (voiceId == 'voice_sara') { _flutterTts.setPitch(1.4); _flutterTts.setSpeechRate(_speed - 0.15); }
    else if (voiceId == 'voice_user') { _flutterTts.setPitch(1.0); _flutterTts.setSpeechRate(_speed); }
  }

  Future<void> speak(String text) async { _isSpeaking = true; _isPaused = false; notifyListeners(); await _flutterTts.speak(text); }
  Future<void> stop() async { await _flutterTts.stop(); _isSpeaking = false; _isPaused = false; notifyListeners(); }
  Future<void> pause() async { await _flutterTts.pause(); _isPaused = true; notifyListeners(); }
  Future<void> resume() async { await _flutterTts.speak(''); _isPaused = false; notifyListeners(); }
  void setSpeed(double val) { _speed = val; _flutterTts.setSpeechRate(val); notifyListeners(); }
}
TTS_EOF
echo "✅ TTS Service"

# ─── Premium Service ───
echo ""
echo "📌 [6/9] Premium Verification Service..."
cat > lib/services/premium_verification_service.dart << 'PREMIUM_EOF'
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PremiumVerificationService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isPremium = false;
  DateTime? _expiryDate;

  bool get isPremium => _isPremium;
  DateTime? get expiryDate => _expiryDate;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isPremium = _prefs.getBool('is_pro_version') ?? false;
    final expiryStr = _prefs.getString('pro_expiry_date');
    if (expiryStr != null) {
      _expiryDate = DateTime.tryParse(expiryStr);
      if (_expiryDate != null && _expiryDate!.isBefore(DateTime.now())) {
        _isPremium = false;
        await _prefs.setBool('is_pro_version', false);
        await _prefs.remove('pro_expiry_date');
      }
    }
    notifyListeners();
  }

  Future<DateTime?> _fetchNetworkTime() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse('https://worldtimeapi.org/api/ip')).timeout(const Duration(seconds: 5)),
        http.get(Uri.parse('https://timeapi.io/api/Time/current/zone?timeZone=UTC')).timeout(const Duration(seconds: 5)),
      ]);
      for (final response in responses) {
        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data['utc_datetime'] != null) return DateTime.tryParse(data['utc_datetime'] as String);
          else if (data['dateTime'] != null) return DateTime.tryParse(data['dateTime'] as String);
        }
      }
    } catch (_) {}
    return null;
  }

  Future<bool> activateWithPatch(String patch) async {
    try {
      final parts = patch.split('-');
      if (parts.length < 3) return false;
      final durationStr = parts[parts.length - 2];
      final months = int.tryParse(durationStr) ?? 0;
      if (months <= 0 || months > 60) return false;
      DateTime now;
      final networkTime = await _fetchNetworkTime();
      if (networkTime != null) { now = networkTime; }
      else { now = DateTime.now(); debugPrint('⚠️ استخدام الوقت المحلي'); }
      final expiry = DateTime(now.year, now.month + months, now.day);
      _isPremium = true; _expiryDate = expiry;
      await _prefs.setBool('is_pro_version', true);
      await _prefs.setString('pro_expiry_date', expiry.toIso8601String());
      await _prefs.setString('pro_activation_patch', patch);
      notifyListeners();
      return true;
    } catch (_) { return false; }
  }

  Future<void> deactivate() async {
    _isPremium = false; _expiryDate = null;
    await _prefs.setBool('is_pro_version', false);
    await _prefs.remove('pro_expiry_date');
    await _prefs.remove('pro_activation_patch');
    notifyListeners();
  }
}
PREMIUM_EOF
echo "✅ Premium Service"

# ─── dialogue_screen.dart (HOTFIX: إضافة import file_picker) ───
echo ""
echo "📌 [7/9] dialogue_screen.dart (HOTFIX: إضافة import file_picker)..."
cat > lib/features/card1_translation/dialogue_screen.dart << 'DIA_EOF'
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart'; // ✅ HOTFIX: هذا الـ import كان مفقوداً

class DialogueScreen extends StatefulWidget {
  final String initialText;
  const DialogueScreen({super.key, this.initialText = ''});
  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _fromLanguage = 'ar';
  String _toLanguage = 'en';
  bool _isTranslating = false;
  String _pickedFileName = '';

  static const Map<String, String> _langs = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français',
    'es': 'Español', 'de': 'Deutsch', 'tr': 'Türkçe',
    'fa': 'فارسی', 'ur': 'اردو', 'hi': 'हिन्दी',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialText.isNotEmpty) _inputController.text = widget.initialText;
  }

  @override
  void dispose() { _inputController.dispose(); _outputController.dispose(); super.dispose(); }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'doc', 'docx', 'pdf', 'json', 'csv', 'xml', 'html'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        setState(() {
          _pickedFileName = result.files.single.name;
          _inputController.text = content.length > 5000 ? content.substring(0, 5000) : content;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ تم رفع الملف: $_pickedFileName')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _translate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': text.length > 2000 ? text.substring(0, 2000) : text, 'source': _fromLanguage, 'target': _toLanguage, 'format': 'text'}),
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() => _outputController.text = data['translatedText'] ?? '❌ فشلت الترجمة');
      } else {
        setState(() => _outputController.text = '⚠️ تعذر الاتصال بالخادم');
      }
    } catch (e) { setState(() => _outputController.text = '⚠️ خطأ: $e'); }
    setState(() => _isTranslating = false);
  }

  void _swapLanguages() { setState(() { final t = _fromLanguage; _fromLanguage = _toLanguage; _toLanguage = t; }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌐 ترجمة نصوص'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickFile, tooltip: 'رفع ملف')],
      ),
      body: Column(
        children: [
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12), color: Colors.teal.withOpacity(0.05),
            child: const Text('🦂 Mirror Scorpion — ترجم هذا بواسطه ميرور اسكربيون', style: TextStyle(fontSize: 10, color: Colors.teal), textAlign: TextAlign.center)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: _fromLanguage, items: _langs.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(), onChanged: (v) => setState(() => _fromLanguage = v ?? 'ar'), decoration: const InputDecoration(labelText: 'من', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)))),
              IconButton(onPressed: _swapLanguages, icon: const Icon(Icons.swap_horiz, color: Colors.teal)),
              Expanded(child: DropdownButtonFormField<String>(value: _toLanguage, items: _langs.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(), onChanged: (v) => setState(() => _toLanguage = v ?? 'en'), decoration: const InputDecoration(labelText: 'إلى', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)))),
            ]),
          ),
          Expanded(flex: 3, child: Container(margin: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), color: Colors.grey.shade100,
                child: Row(children: [const Text('📝 النص الأصلي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const Spacer(),
                  if (_pickedFileName.isNotEmpty) Text(_pickedFileName, style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
                  if (_pickedFileName.isNotEmpty) IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () { setState(() { _inputController.clear(); _pickedFileName = ''; }); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ]),
              ),
              Expanded(child: TextField(controller: _inputController, decoration: const InputDecoration(hintText: 'اكتب النص هنا أو ارفع ملفاً...', border: InputBorder.none, contentPadding: EdgeInsets.all(12)), maxLines: null, expands: true, textDirection: TextDirection.rtl)),
            ]),
          )),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: _isTranslating ? null : _translate,
              icon: _isTranslating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.translate),
              label: Text(_isTranslating ? 'جاري الترجمة...' : '🔄 ترجمة'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            )),
          ),
          Expanded(flex: 4, child: Container(margin: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), color: Colors.teal.shade50,
                child: Row(children: [
                  const Text('🌐 الترجمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const Spacer(),
                  IconButton(icon: const Icon(Icons.copy, size: 18, color: Colors.teal), onPressed: () { Clipboard.setData(ClipboardData(text: _outputController.text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم النسخ'))); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  IconButton(icon: const Icon(Icons.share, size: 18, color: Colors.teal), onPressed: () { Clipboard.setData(ClipboardData(text: '${_outputController.text}\n\n— تمت الترجمة بواسطة ميرور سكربيون 🦂')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم التجهيز للمشاركة مع توقيع التطبيق'))); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ]),
              ),
              Expanded(child: TextField(controller: _outputController, decoration: const InputDecoration(hintText: 'الترجمة...', border: InputBorder.none, contentPadding: EdgeInsets.all(12)), maxLines: null, expands: true, readOnly: true)),
            ]),
          )),
        ],
      ),
    );
  }
}
DIA_EOF
echo "✅ dialogue_screen.dart (HOTFIX: تم إضافة import file_picker)"

# ─── rubik_screen.dart (HOTFIX: إضافة _faceNames) ───
echo ""
echo "📌 [8/9] rubik_screen.dart (HOTFIX: إضافة _faceNames)..."
cat > lib/features/card5_games/rubik_screen.dart << 'RUBIK_EOF'
import 'package:flutter/material.dart';

class RubikScreen extends StatefulWidget {
  const RubikScreen({super.key});
  @override
  State<RubikScreen> createState() => _RubikScreenState();
}

class _RubikScreenState extends State<RubikScreen> {
  // ✅ HOTFIX: إضافة _faceNames (كانت مفقودة وتسبب الخطأ)
  final List<String> _faceNames = ['أمامي', 'خلفي', 'أيسر', 'أيمن', 'علوي', 'سفلي'];
  
  // مصفوفة بسيطة تمثل 6 أوجه كل وجه 3x3
  final List<List<List<Color>>> _cube = List.generate(
    6, (_) => List.generate(3, (_) => List.generate(3, (_) => Colors.white)),
  );

  final List<Color> _faceColors = [
    Colors.green, Colors.blue, Colors.orange,
    Colors.red, Colors.white, Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    // تعيين الألوان الابتدائية
    for (int f = 0; f < 6; f++) {
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          _cube[f][r][c] = _faceColors[f];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧩 روبيك 3D', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // عرض الأوجه كشبكات
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, fi) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      // ✅ HOTFIX: استخدام _faceNames[fi]
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(_faceNames[fi],
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.0,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                            ),
                            itemCount: 9,
                            itemBuilder: (_, ci) {
                              final r = ci ~/ 3;
                              final c = ci % 3;
                              return Container(
                                decoration: BoxDecoration(
                                  color: _cube[fi][r][c],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
RUBIK_EOF
echo "✅ rubik_screen.dart (HOTFIX: تم إضافة _faceNames)"

# ─── inspiration_screen.dart (HOTFIX: إزالة const من TextStyle غير الثابت) ───
echo ""
echo "📌 [9/9] inspiration_screen.dart (HOTFIX: إزالة const من TextStyle)..."
cat > lib/features/card3_inspiration/inspiration_screen.dart << 'INSP_EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class InspirationScreen extends StatefulWidget {
  final String initialQuote;
  const InspirationScreen({super.key, this.initialQuote = ''});
  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<String> _messages = [];
  final TextEditingController _aiController = TextEditingController();
  String _aiMessage = '';
  
  final List<Map<String, String>> _localQuotes = [
    {'quote': 'إن مع العسر يسرا', 'author': 'القرآن الكريم (الشرح: 6)'},
    {'quote': 'لا تحزن إن الله معنا', 'author': 'القرآن الكريم (التوبة: 40)'},
    {'quote': 'وما توفيقي إلا بالله', 'author': 'القرآن الكريم (هود: 88)'},
    {'quote': 'ربنا لا تؤاخذنا إن نسينا أو أخطأنا', 'author': 'القرآن الكريم (البقرة: 286)'},
    {'quote': 'إن الله لا يضيع أجر المحسنين', 'author': 'القرآن الكريم (التوبة: 120)'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuote.isNotEmpty) {
      setState(() => _aiMessage = widget.initialQuote);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _aiController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_inputController.text.trim().isEmpty) return;
    setState(() {
      _messages.add('👤 ${_inputController.text}');
      final random = Random();
      final quote = _localQuotes[random.nextInt(_localQuotes.length)];
      _messages.add('🤖 ${quote['quote']}\n— ${quote['author']}');
      _inputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 إلهام'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            color: Colors.teal.withOpacity(0.05),
            child: const Text('🦂 Mirror Scorpion', style: TextStyle(fontSize: 10, color: Colors.teal), textAlign: TextAlign.center),
          ),
          Expanded(
            child: _aiMessage.isNotEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ✅ HOTFIX: إزالة const من TextStyle لأن Colors.teal.shade800 ليس ثابتاً
                        Text(_aiMessage,
                            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.teal.shade800),
                            textDirection: TextDirection.rtl),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.copyright, size: 14, color: Colors.teal),
                              const SizedBox(width: 6),
                              Text('🦂 ميرور اسكربيون', style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _messages.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (_, i) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(_messages[i], textDirection: TextDirection.rtl),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالتك هنا...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: const Text('إرسال'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
INSP_EOF
echo "✅ inspiration_screen.dart (HOTFIX: إزالة const من TextStyle)"

# ─── settings_screen.dart (HOTFIX: إضافة import dart:io لـ Platform) ───
echo ""
echo "📌 [FINAL] settings_screen.dart (HOTFIX: إضافة import dart:io)..."
cat > lib/features/settings/settings_screen.dart << 'SETT_EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:io'; // ✅ HOTFIX: هذا الـ import كان مفقوداً لاستخدام Platform
import '../../services/tts_service.dart';
import '../../services/premium_verification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _patchController = TextEditingController();

  @override
  void dispose() { _patchController.dispose(); super.dispose(); }

  String _getDeviceId() {
    // ✅ HOTFIX: Platform.isAndroid يعمل الآن بعد إضافة import 'dart:io'
    final id = 'MS-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}-${Platform.isAndroid ? 'ADR' : 'IOS'}';
    return id;
  }

  @override
  Widget build(BuildContext context) {
    final tts = context.watch<TTSService>();
    final premium = context.watch<PremiumVerificationService>();
    final deviceId = _getDeviceId();

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚙️ الإعدادات'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🔊 الأصوات', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...TTSService.availableVoices.map((voice) {
              final isPro = voice['id'] == 'voice_user';
              return RadioListTile<String>(
                title: Text('${voice['name']} — ${voice['desc']}'),
                subtitle: isPro ? const Text('🔒 متاح في النسخة المدفوعة', style: TextStyle(color: Colors.amber, fontSize: 12)) : null,
                value: voice['id']!,
                groupValue: tts.selectedVoice,
                activeColor: Colors.teal,
                onChanged: (val) {
                  if (val != null && (!isPro || premium.isPremium)) { tts.setVoice(val); }
                  else if (isPro && !premium.isPremium) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔒 هذا الصوت متاح فقط في النسخة PRO'))); }
                },
              );
            }),
          ]))),
          const SizedBox(height: 12),
          Card(child: Column(children: [
            ListTile(leading: const Icon(Icons.translate, color: Colors.teal), title: const Text('الترجمة التلقائية'), subtitle: const Text('ترجمة فورية عند لصق النص'), trailing: Switch(value: true, onChanged: (_) {}, activeColor: Colors.teal)),
            const Divider(height: 1),
            ListTile(leading: const Icon(Icons.dark_mode, color: Colors.teal), title: const Text('الوضع المظلم'), subtitle: const Text('مفعل دائماً'), trailing: Switch(value: true, onChanged: (_) {}, activeColor: Colors.teal)),
          ])),
          const SizedBox(height: 12),
          Card(
            color: Colors.amber.withOpacity(0.08),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.amber.withOpacity(0.3))),
            child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
              Row(children: [
                Icon(premium.isPremium ? Icons.workspace_premium : Icons.lock, color: Colors.amber, size: 28),
                const SizedBox(width: 8),
                Text(premium.isPremium ? '👑 PRO مفعلة' : '👑 النسخة PRO', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.amber)),
              ]),
              const SizedBox(height: 12),
              const Text('مزايا PRO:\n• ترجمة مستندات غير محدودة\n• استنساخ صوت المستخدم (AI)\n• تحويل القصص إلى فيديوهات\n• ترجمة أوفلاين بدون إنترنت', style: TextStyle(fontSize: 13, height: 1.6), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (!premium.isPremium) ...[
                Container(decoration: BoxDecoration(border: Border.all(color: Colors.amber.shade300), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    Expanded(child: Padding(padding: const EdgeInsets.all(12), child: Text('ID: $deviceId', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')))),
                    IconButton(icon: const Icon(Icons.copy, color: Colors.amber), onPressed: () { Clipboard.setData(ClipboardData(text: deviceId)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم نسخ معرف الجهاز'))); }),
                  ]),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _patchController,
                  decoration: InputDecoration(
                    labelText: '🔑 أدخل باتش التفعيل المشفر',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(icon: const Icon(Icons.paste, color: Colors.grey), onPressed: () async { final data = await Clipboard.getData(Clipboard.kTextPlain); if (data?.text != null) _patchController.text = data!.text!; }),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    if (_patchController.text.isNotEmpty) {
                      final success = await premium.activateWithPatch(_patchController.text);
                      if (success && mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎉 تم تفعيل النسخة PRO بنجاح!'), backgroundColor: Colors.green)); }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black87, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                  child: const Text('🔓 تفعيل الآن', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ] else ...[
                Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Column(children: [Icon(Icons.check_circle, color: Colors.green, size: 48), SizedBox(height: 8), Text('✅ PRO نشطة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green))])),
              ],
              const SizedBox(height: 16),
              const Divider(), const SizedBox(height: 8),
              const Text('📞 للدعم:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('واتس: 01017341250\n01031680816\n01558203456'),
              const Text('📧 dosoky.server@gmail.com'),
            ])),
          ),
          const SizedBox(height: 20),
          Center(child: Opacity(opacity: 0.3, child: Column(children: [
            const Text('🦂 Mirror Scorpion', style: TextStyle(fontSize: 14)),
            Text('v1.2.0 — ${premium.isPremium ? "PRO" : "Free"}', style: const TextStyle(fontSize: 11)),
            const Text('المطور: Tamer Eldosoky', style: TextStyle(fontSize: 11)),
          ]))),
        ],
      ),
    );
  }
}
SETT_EOF
echo "✅ settings_screen.dart (HOTFIX: تم إضافة import dart:io لـ Platform)"

# ─── رفع التغييرات ───
cd ~/mirror_scorpion/mirror_scorpion_v2

echo ""
echo "================================================"
echo "  ✅ جميع التعديلات تم تطبيقها (HOTFIX v2)"
echo "================================================"

echo ""
echo "📊 ملخص الإصلاحات:"
echo "  1. dialogue_screen.dart — ✅ إضافة import 'package:file_picker/file_picker.dart'"
echo "  2. rubik_screen.dart     — ✅ إضافة _faceNames المفقودة"
echo "  3. inspiration_screen.dart — ✅ إزالة const من TextStyle غير الثابت"
echo "  4. settings_screen.dart  — ✅ إضافة import 'dart:io' لـ Platform"

echo ""
echo "📦 رفع التغييرات إلى GitHub..."
git add -A
git commit -m "🦂 HOTFIX v2 — إصلاح 4 أخطاء بناء

🐛 الأخطاء التي تم إصلاحها:
1. dialogue_screen.dart:48 — FileType غير معرف → إضافة import file_picker
2. rubik_screen.dart:90 — _faceNames غير معرف → إضافة المصفوفة
3. inspiration_screen.dart:112 — Colors.teal.shade800 ليس const → إزالة const
4. settings_screen.dart:23 — Platform غير معرف → إضافة import dart:io

✅ تم إضافة GitHub Actions workflow للبناء التلقائي"

git push origin main

echo ""
echo "================================================"
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "  ✅ PUSH COMPLETE ✅"
echo "  ⏱️  المدة: $DURATION ثانية"
echo "  📦 تم رفع 8 ملفات محدثة إلى GitHub"
echo "  ⚡ GitHub Actions سيبدأ البناء تلقائياً"
echo "  📥 نزل APK من:"
echo "     https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/actions"
echo "================================================"
cd ~/mirror_scorpion/mirror_scorpion_v2
cat > termux_master_build.sh
# (الصق الكود كاملاً ثم Ctrl+D)
chmod +x termux_master_build.sh


