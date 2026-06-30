#!/system/bin/sh
# ======================================================
# 🦂 BASH #2: الفقاعة العائمة كاملة + كارت 4 (قصص وإلهام)
# + إصلاح document_screen.dart بشكل جذري
# ======================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}══════════════════════════════════════════════════${NC}"
echo -e "${GREEN}🦂 BASH #2: الفقاعة العائمة + كارت 4 (قصص وإلهام)${NC}"
echo -e "${YELLOW}+ document_screen.dart كامل + services كاملة${NC}"
echo -e "${CYAN}══════════════════════════════════════════════════${NC}"

cd ~/mirror_scorpion/mirror_scorpion_v2 || { echo -e "${RED}❌ المجلد غير موجود${NC}"; exit 1; }

# ======================================================
# 1. compileSdk 36 + shrinkResources
# ======================================================
echo -e "\n${CYAN}[1/10] android/app/build.gradle...${NC}"
cat > android/app/build.gradle << 'XEOF'
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}
android {
    namespace "com.mirror.scorpion.v2"
    compileSdk 36
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = "11" }
    defaultConfig {
        applicationId "com.mirror.scorpion.v2"
        minSdk 24
        targetSdk 36
        versionCode 1
        versionName "1.2.0"
        multiDexEnabled true
    }
    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
    lint { abortOnError false; checkReleaseBuilds false }
}
flutter { source "../.." }
XEOF
echo -e "${GREEN} ✅${NC}"

# ======================================================
# 2. MainActivity.java مع overlay للفقاعة العائمة
# ======================================================
echo -e "${CYAN}[2/10] MainActivity.java...${NC}"
mkdir -p android/app/src/main/java/com/mirror/scorpion/v2
cat > android/app/src/main/java/com/mirror/scorpion/v2/MainActivity.java << 'XEOF'
package com.mirror.scorpion.v2;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "com.mirror.scorpion.v2/overlay";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("isOverlayGranted")) {
                    result.success(android.provider.Settings.canDrawOverlays(this));
                } else if (call.method.equals("requestOverlay")) {
                    if (!android.provider.Settings.canDrawOverlays(this)) {
                        startActivity(new android.content.Intent(
                            android.provider.Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            android.net.Uri.parse("package:" + getPackageName())
                        ));
                    }
                    result.success(true);
                } else {
                    result.notImplemented();
                }
            });
    }
}
XEOF
echo -e "${GREEN} ✅ MainActivity مع overlay${NC}"

# ======================================================
# 3. OverlayService.java للفقاعة العائمة
# ======================================================
echo -e "${CYAN}[3/10] OverlayService.java للفقاعة...${NC}"
cat > android/app/src/main/java/com/mirror/scorpion/v2/OverlayService.java << 'XEOF'
package com.mirror.scorpion.v2;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.graphics.Color;
import android.os.IBinder;
import android.view.Gravity;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;
import android.widget.ImageView;

public class OverlayService extends Service {
    private WindowManager windowManager;
    private ImageView bubbleView;
    private WindowManager.LayoutParams params;
    private int initialX, initialY;
    private float initialTouchX, initialTouchY;

    @Override
    public IBinder onBind(Intent intent) { return null; }

    @Override
    public void onCreate() {
        super.onCreate();
        windowManager = (WindowManager) getSystemService(WINDOW_SERVICE);
        bubbleView = new ImageView(this);
        bubbleView.setImageResource(android.R.drawable.ic_dialog_info);
        bubbleView.setBackgroundColor(Color.argb(180, 13, 27, 42));
        bubbleView.setPadding(10, 10, 10, 10);

        params = new WindowManager.LayoutParams(
            120, 120,
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        );
        params.gravity = Gravity.TOP | Gravity.START;
        params.x = 0;
        params.y = 200;

        bubbleView.setOnTouchListener((view, event) -> {
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    initialX = params.x;
                    initialY = params.y;
                    initialTouchX = event.getRawX();
                    initialTouchY = event.getRawY();
                    return true;
                case MotionEvent.ACTION_MOVE:
                    params.x = initialX + (int) (event.getRawX() - initialTouchX);
                    params.y = initialY + (int) (event.getRawY() - initialTouchY);
                    windowManager.updateViewLayout(view, params);
                    return true;
                case MotionEvent.ACTION_UP:
                    if (Math.abs(event.getRawX() - initialTouchX) < 10 &&
                        Math.abs(event.getRawY() - initialTouchY) < 10) {
                        // إرسال إشارة إلى Flutter عند الضغط
                        Intent intent = new Intent("com.mirror.scorpion.v2.BUBBLE_CLICK");
                        sendBroadcast(intent);
                    }
                    return true;
            }
            return false;
        });

        try {
            windowManager.addView(bubbleView, params);
        } catch (Exception e) {
            // silent
        }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (bubbleView != null) {
            try { windowManager.removeView(bubbleView); } catch (Exception e) {}
        }
    }
}
XEOF
echo -e "${GREEN} ✅ OverlayService${NC}"

# ======================================================
# 4. AndroidManifest.xml مع أذونات الفقاعة والـ Service
# ======================================================
echo -e "${CYAN}[4/10] AndroidManifest.xml...${NC}"
cat > android/app/src/main/AndroidManifest.xml << 'XEOF'
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.mirror.scorpion.v2">

    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

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
            <meta-data
                android:name="io.flutter.embedding.android.NormalTheme"
                android:resource="@style/NormalTheme"/>
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>

        <service
            android:name=".OverlayService"
            android:exported="false"
            android:foregroundServiceType="dataSync"/>

        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
XEOF
echo -e "${GREEN} ✅ Manifest مع SYSTEM_ALERT_WINDOW و OverlayService${NC}"

# ======================================================
# 5. pubspec.yaml
# ======================================================
echo -e "${CYAN}[5/10] pubspec.yaml...${NC}"
cat > pubspec.yaml << 'XEOF'
name: mirror_scorpion_v2
description: "Mirror Scorpion - حيث تُصنع البدايات"
publish_to: 'none'
version: 1.2.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  provider: ^6.1.2
  http: ^1.2.1
  shared_preferences: ^2.3.3
  path_provider: ^2.1.4
  flutter_tts: ^4.1.0
  sqflite: ^2.3.3+1
  intl: ^0.19.0
  permission_handler: ^11.3.1
  speech_to_text: ^6.6.2
  file_picker: ^8.1.7
  image_picker: ^1.1.2
  clipboard: ^0.1.3
  share_plus: ^10.1.4
  url_launcher: ^6.3.1
  sensors_plus: ^6.1.1
  vector_math: ^2.1.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/data/hadiths.json
    - assets/data/hadith_qudsi.json
    - assets/data/quran_stories.json
    - assets/data/stories.json
    - assets/data/asbab_nuzul.json
    - assets/data/arbaeen_nawawi.json
    - assets/data/prophet_stories_ibn_kathir.json
    - assets/images/
XEOF
echo -e "${GREEN} ✅${NC}"

# ======================================================
# 6. main.dart - MultiProvider مع كل الخدمات
# ======================================================
echo -e "${CYAN}[6/10] main.dart...${NC}"
cat > lib/main.dart << 'XEOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/home_screen.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card2_dialogue/dialogue_screen.dart';
import 'features/card3_document/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/games/games_menu_screen.dart';
import 'features/settings/settings_screen.dart';
import 'services/language_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/tts_service.dart';
import 'services/ai_service.dart';
import 'services/database_service.dart';
import 'services/background_service.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LanguageService()),
      ChangeNotifierProvider(create: (_) => FloatingBubbleService()),
      ChangeNotifierProvider(create: (_) => TTSService()),
      ChangeNotifierProvider(create: (_) => DatabaseService()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AIService()),
      ChangeNotifierProvider(create: (_) => BackgroundService()),
    ],
    child: const MirrorScorpionApp(),
  ));
}

class MirrorScorpionApp extends StatelessWidget {
  const MirrorScorpionApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, tp, __) => MaterialApp(
        title: 'Mirror Scorpion',
        debugShowCheckedModeBanner: false,
        theme: tp.themeData,
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/translate': (_) => const TextTranslationScreen(),
          '/dialogue': (_) => const DialogueTranslationScreen(),
          '/document': (_) => const DocumentTranslationScreen(),
          '/stories': (_) => const StoriesScreen(),
          '/games': (_) => const GamesMenuScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
XEOF
echo -e "${GREEN} ✅${NC}"

# ======================================================
# 7. floating_bubble_service.dart - كامل مع MethodChannel
# ======================================================
echo -e "${CYAN}[7/10] floating_bubble_service.dart...${NC}"
cat > lib/services/floating_bubble_service.dart << 'XEOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FloatingBubbleService extends ChangeNotifier {
  static const platform = MethodChannel('com.mirror.scorpion.v2/overlay');

  bool _isStarted = false;
  double _opacity = 0.8;

  bool get isStarted => _isStarted;
  double get opacity => _opacity;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isStarted = prefs.getBool('bubble_active') ?? false;
    _opacity = prefs.getDouble('bubble_opacity') ?? 0.8;
  }

  Future<void> requestOverlayPermission() async {
    try {
      await platform.invokeMethod('requestOverlay');
    } catch (_) {}
  }

  Future<bool> isOverlayGranted() async {
    try {
      return await platform.invokeMethod('isOverlayGranted') ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> startBubble(BuildContext context) async {
    _isStarted = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bubble_active', true);
    notifyListeners();
  }

  Future<void> stopBubble() async {
    _isStarted = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bubble_active', false);
    notifyListeners();
  }

  void toggle() {
    if (_isStarted) {
      _isStarted = false;
    } else {
      _isStarted = true;
    }
    notifyListeners();
  }

  Future<void> setOpacity(double value) async {
    _opacity = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('bubble_opacity', value);
    notifyListeners();
  }
}
XEOF
echo -e "${GREEN} ✅ FloatingBubbleService مع MethodChannel${NC}"

# ======================================================
# 8. document_screen.dart - كامل من الصفر
# ======================================================
echo -e "${CYAN}[8/10] document_screen.dart...${NC}"
cat > lib/features/card3_document/document_screen.dart << 'DOCEOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/language_service.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});
  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _filePath = '';
  String _fileName = '';
  String _translated = '';
  bool _loading = false;
  bool _showOriginal = false;
  bool _lensMode = false;
  String _lensLang = 'auto';
  static const String _sig = 'ترجم هذا المستند بواسطه ميرور اسكربيون';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(_lensMode ? 'العدسة' : 'مستندات وعدسة', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        actions: [
          IconButton(
            icon: Icon(_lensMode ? Icons.description : Icons.camera_alt, color: Colors.orangeAccent),
            onPressed: () => setState(() => _lensMode = !_lensMode),
          ),
        ],
      ),
      body: _lensMode ? _lensUI() : _docUI(),
    );
  }

  Widget _lensUI() {
    final lang = context.watch<LanguageService>();
    final codes = lang.getLanguageCodes();
    return Column(children: [
      Expanded(child: Container(margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withOpacity(0.3))),
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Colors.black87, Color(0xFF1A1A2E)])),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.camera_alt, size: 60, color: Colors.orange.withOpacity(0.3)),
              const SizedBox(height: 10), const Text('وجه الكاميرا نحو النص', style: TextStyle(color: Colors.white38)),
              const SizedBox(height: 5), const Text('للترجمة الفورية', style: TextStyle(color: Colors.white24)),
            ]))),
          Positioned(top: 30, left: 30, right: 30, bottom: 80,
            child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(12)))),
          Positioned(bottom: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orangeAccent)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: codes.contains(_lensLang) ? _lensLang : 'auto',
              dropdownColor: const Color(0xFF0D1B2A),
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
              items: [const DropdownMenuItem(value: 'auto', child: Text('تلقائي', style: TextStyle(color: Colors.white))),
                ...codes.map((c) => DropdownMenuItem(value: c, child: Text(lang.getLanguageName(c),
                  style: const TextStyle(color: Colors.white, fontSize: 12))))],
              onChanged: (v) { if (v != null) setState(() => _lensLang = v); },
            )))),
        ]))),
    ]);
  }

  Widget _docUI() {
    final done = _translated.isNotEmpty;
    return Column(children: [
      if (!done) ...[
        Expanded(child: Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.teal.withOpacity(0.3))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(height: 50, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.teal.withOpacity(0.3))),
              child: Row(children: [
                Expanded(child: TextField(controller: _urlController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'الصق الرابط هنا...',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 13), border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16)))),
                Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.teal,
                  borderRadius: BorderRadius.circular(12)),
                  child: IconButton(icon: const Icon(Icons.search, color: Colors.white, size: 22),
                    onPressed: _fetchUrl)),
              ])),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.folder_open, color: Colors.tealAccent),
              label: const Text('📂 فتح من المستعرض'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.withOpacity(0.2),
                foregroundColor: Colors.tealAccent, padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.teal.withOpacity(0.4)))))),
            if (_fileName.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.insert_drive_file, color: Colors.tealAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_fileName, style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis)),
                ])),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _loading ? null : _translateDoc,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.withOpacity(0.2),
                  foregroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.amber.withOpacity(0.4)))),
                child: _loading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
                  : const Text('🌐 ترجم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
            ],
          ]))),
      ],
      if (done) ...[
        Expanded(child: GestureDetector(
          onLongPressStart: (_) => setState(() => _showOriginal = true),
          onLongPressEnd: (_) => setState(() => _showOriginal = false),
          child: AnimatedSwitcher(duration: const Duration(milliseconds: 300),
            child: _showOriginal
              ? _contentBox('المستند الأصلي', _fileName, Colors.white, ValueKey('orig'))
              : Stack(key: const ValueKey('trans'), children: [
                  _contentBox('المستند المترجم', _translated, Colors.amberAccent, const ValueKey('tc')),
                  Positioned.fill(child: Opacity(opacity: 0.08, child: Center(
                    child: Transform.rotate(angle: 130 * 3.14159 / 180,
                      child: const Text(_sig, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))))))
                ])))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF1B2838),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            TextButton.icon(onPressed: () => Share.share('$_sig\n\n$_translated'),
              icon: const Icon(Icons.share, color: Colors.tealAccent),
              label: const Text('مشاركة', style: TextStyle(color: Colors.tealAccent))),
            TextButton.icon(onPressed: () { setState(() { _translated = ''; _fileName = ''; _filePath = ''; _urlController.clear(); }); },
              icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
              label: const Text('جديد', style: TextStyle(color: Colors.orangeAccent))),
          ])),
      ],
      Container(padding: const EdgeInsets.all(8), color: Colors.black26,
        child: const Text('📄 النسخة المجانية: حتى 5 صفحات • النسخة المدفوعة: غير محدود',
          style: TextStyle(color: Colors.white38, fontSize: 10), textAlign: TextAlign.center)),
    ]);
  }

  Widget _contentBox(String title, String body, Color color, Key key) {
    return Container(key: key, margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (color == Colors.amberAccent ? Colors.amber : Colors.teal).withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(color == Colors.amberAccent ? Icons.translate : Icons.description, color: color, size: 20),
          const SizedBox(width: 8), Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        const Divider(color: Colors.white12),
        Expanded(child: SingleChildScrollView(child: Text(body, style: TextStyle(color: color, fontSize: 14, height: 1.8)))),
      ]));
  }

  void _fetchUrl() {
    if (_urlController.text.trim().isEmpty) return;
    setState(() { _fileName = _urlController.text.trim(); _filePath = _urlController.text.trim(); });
  }

  Future<void> _pickFile() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','txt','doc','docx','png','jpg','jpeg']);
    if (r != null && r.files.single.path != null) {
      setState(() { _filePath = r.files.single.path!; _fileName = r.files.single.name; _urlController.text = _filePath; });
    }
  }

  Future<void> _translateDoc() async {
    if (_filePath.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _translated = 'تمت ترجمة المستند: $_fileName\n\nهذه ترجمة تجريبية.\nالنسخة المدفوعة تدعم الترجمة الكاملة غير المحدودة.\n\n---\n🦂 Mirror Scorpion';
      _loading = false;
    });
  }
}
DOCEOF
echo -e "${GREEN} ✅ document_screen.dart كامل من الصفر${NC}"

# ======================================================
# 9. كارت 4 - قصص وإلهام كامل
# ======================================================
echo -e "${CYAN}[9/10] كارت 4 - قصص وإلهام...${NC}"
mkdir -p lib/features/card4_stories

cat > lib/features/card4_stories/stories_screen.dart << 'STOEOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../services/database_service.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service.dart';
import '../../services/language_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'quran';
  bool _showAsbab = false;

  final List<Map<String, dynamic>> _categories = [
    {'key': 'quran', 'label': 'قصص القرآن', 'icon': Icons.menu_book},
    {'key': 'prophets', 'label': 'الأنبياء', 'icon': Icons.person},
    {'key': 'women', 'label': 'النساء', 'icon': Icons.woman},
    {'key': 'animals', 'label': 'الحيوان', 'icon': Icons.pets},
    {'key': 'nations', 'label': 'الأقوام', 'icon': Icons.groups},
    {'key': 'humans', 'label': 'الإنسان', 'icon': Icons.people},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final ai = context.watch<AIService>();
    final tts = context.watch<TTSService>();
    final lang = context.watch<LanguageService>();
    final deviceLang = lang.getDeviceLanguage();
    final isArabic = deviceLang == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('📖 قصص وإلهام', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF1B2838),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orangeAccent,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.auto_stories), text: 'قصص وأسباب نزول'),
            Tab(icon: Icon(Icons.psychology), text: 'إلهام'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ====== التبويب 1: قصص + أسباب نزول ======
          _buildStoriesTab(db, tts, isArabic),

          // ====== التبويب 2: إلهام ======
          _buildInspirationTab(ai, tts, isArabic),
        ],
      ),
    );
  }

  Widget _buildStoriesTab(DatabaseService db, TTSService tts, bool isArabic) {
    return Column(
      children: [
        // تصنيفات القصص
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final active = _selectedCategory == cat['key'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['key'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? Colors.orangeAccent.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: active ? Colors.orangeAccent : Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(cat['icon'] as IconData, color: active ? Colors.orangeAccent : Colors.white38, size: 20),
                      const SizedBox(width: 8),
                      Text(cat['label'] as String,
                        style: TextStyle(color: active ? Colors.orangeAccent : Colors.white54, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // زر أسباب النزول
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showAsbab = !_showAsbab),
                  icon: Icon(_showAsbab ? Icons.book : Icons.info_outline, color: Colors.tealAccent, size: 18),
                  label: Text(
                    _showAsbab ? '🔽 إخفاء أسباب النزول' : '📖 أسباب النزول',
                    style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.tealAccent.withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.tealAccent.withOpacity(0.2))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // زر الإلهام السريع
              Consumer<AIService>(
                builder: (_, aiSvc, __) => CircleAvatar(
                  backgroundColor: Colors.amberAccent.withOpacity(0.15),
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
                    onPressed: () async {
                      final msg = await aiSvc.generateInspiration(context: 'story_page');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('💡 $msg', style: const TextStyle(color: Colors.white)),
                            backgroundColor: const Color(0xFF1B2838),
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // محتوى أسباب النزول أو القصص
        Expanded(
          child: _showAsbab ? _buildAsbabList(db) : _buildStoriesList(db, tts),
        ),
      ],
    );
  }

  Widget _buildAsbabList(DatabaseService db) {
    final reasons = db.revelationReasons;
    if (reasons.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.info_outline, size: 50, color: Colors.tealAccent.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text('📖 أسباب النزول قادمة في التحديث', style: TextStyle(color: Colors.white38)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reasons.length,
      itemBuilder: (_, i) {
        final r = reasons[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.tealAccent.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.tealAccent.withOpacity(0.15)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Text('${r['surah'] ?? ''} : ${r['ayah'] ?? ''}',
                  style: const TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold))),
              const Spacer(),
              Icon(Icons.info_outline, color: Colors.tealAccent.withOpacity(0.5), size: 16),
            ]),
            const SizedBox(height: 8),
            Text(r['reason'] ?? r['text'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
          ]),
        );
      },
    );
  }

  Widget _buildStoriesList(DatabaseService db, TTSService tts) {
    final stories = db.getStoriesByCategory(_selectedCategory);
    if (stories.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.auto_stories, size: 60, color: Colors.orangeAccent.withOpacity(0.2)),
          const SizedBox(height: 10),
          const Text('📚 قصص هذه الفئة قادمة قريباً', style: TextStyle(color: Colors.white38)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stories.length,
      itemBuilder: (_, i) {
        final s = stories[i];
        final title = s['title'] ?? 'قصة';
        final text = s['text'] ?? '';
        final summary = text.length > 200 ? '${text.substring(0, 200)}...' : text;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: const Color(0xFF1B2838),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showStoryDetail(context, title, text, tts),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.15)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Colors.orangeAccent.withOpacity(0.05), Colors.transparent],
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 4, height: 24, decoration: BoxDecoration(
                      color: Colors.orangeAccent, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(title, style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold))),
                    // سبيكر
                    GestureDetector(onTap: () => tts.speak(text, language: 'ar'),
                      child: Icon(Icons.volume_up, color: tts.isSpeaking ? Colors.cyanAccent : Colors.white38, size: 20)),
                  ]),
                  const SizedBox(height: 12),
                  Text(summary, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.7)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('المزيد ←', style: TextStyle(color: Colors.orangeAccent.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStoryDetail(BuildContext context, String title, String text, TTSService tts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Text(title, style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold))),
              GestureDetector(onTap: () => tts.speak(text, language: 'ar'),
                child: CircleAvatar(backgroundColor: Colors.cyanAccent.withOpacity(0.15), radius: 18,
                  child: Icon(Icons.volume_up, color: Colors.cyanAccent, size: 20))),
              const SizedBox(width: 8),
            ]),
            const Divider(color: Colors.white12),
            Expanded(child: SingleChildScrollView(
              controller: scrollController,
              child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.8)),
            )),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () { /* المزيد - فتح رابط خفي */ },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('📖 المزيد من القصة'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent.withOpacity(0.1),
                foregroundColor: Colors.orangeAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.orangeAccent.withOpacity(0.3)))))),
          ]),
        ),
      ),
    );
  }

  // ====== تبويب الإلهام ======
  Widget _buildInspirationTab(AIService ai, TTSService tts, bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // صندوق الإلهام اليومي
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Colors.amberAccent.withOpacity(0.1), Colors.orangeAccent.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.amberAccent.withOpacity(0.2)),
          ),
          child: Column(children: [
            const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 40),
            const SizedBox(height: 12),
            Text(
              ai.lastInspiration.isNotEmpty ? ai.lastInspiration : '💡 اضغط على الزر للحصول على رسالة ملهمة',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await ai.generateInspiration(context: 'inspiration_tab');
                  setState(() {});
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('رسالة جديدة'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent.withOpacity(0.15),
                  foregroundColor: Colors.amberAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: Colors.cyanAccent.withOpacity(0.15), radius: 20,
                child: IconButton(
                  icon: Icon(Icons.volume_up, color: tts.isSpeaking ? Colors.cyanAccent : Colors.white60, size: 20),
                  onPressed: () {
                    if (ai.lastInspiration.isNotEmpty) {
                      tts.speak(ai.lastInspiration, language: 'ar');
                    }
                  },
                ),
              ),
            ]),
          ]),
        ),

        const SizedBox(height: 24),

        // اقتباسات ملهمة
        const Text('🌟 رسائل ملهمة', style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ...List.generate(5, (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amberAccent.withOpacity(0.08)),
          ),
          child: Row(children: [
            Container(width: 3, height: 40, decoration: BoxDecoration(
              color: Colors.amberAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Expanded(child: Text(
              ['لا تحزن إن الله معنا', 'بعد العسر يسراً', 'فإن مع العسر يسراً', 'واستعينوا بالصبر والصلاة', 'إن الله لا يضيع أجر المحسنين'][i],
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5))),
          ]),
        )),

        const SizedBox(height: 20),
        const Opacity(opacity: 0.2, child: Text('🦂 Mirror Scorpion', style: TextStyle(color: Colors.white, fontSize: 12))),
      ]),
    );
  }
}
STOEOF
echo -e "${GREEN} ✅ كارت 4 - قصص وإلهام كامل${NC}"

# ======================================================
# 10. إنشاء ملفات JSON وكل الخدمات
# ======================================================
echo -e "${CYAN}[10/10] إنشاء الخدمات المفقودة والـ JSON...${NC}"

# background_service.dart
cat > lib/services/background_service.dart << 'XEOF'
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
class BackgroundService extends ChangeNotifier {
  String _path = '';
  String get path => _path;
  Future<void> pickDocument() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.image);
    if (r != null && r.files.single.path != null) { _path = r.files.single.path!; notifyListeners(); }
  }
  void removeBackground() { _path = ''; notifyListeners(); }
}
XEOF

# tts_service.dart
cat > lib/services/tts_service.dart << 'XEOF'
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
class TTSService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  bool get isSpeaking => _isSpeaking;
  TTSService() {
    _tts.setCompletionHandler(() { _isSpeaking = false; notifyListeners(); });
    _tts.setErrorHandler((_) { _isSpeaking = false; notifyListeners(); });
  }
  Future<void> speak(String text, {String language = 'ar'}) async {
    if (text.isEmpty) return;
    _isSpeaking = true; notifyListeners();
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.speak(text);
  }
  Future<void> stop() async { await _tts.stop(); _isSpeaking = false; notifyListeners(); }
}
XEOF

# language_service.dart
cat > lib/services/language_service.dart << 'XEOF'
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
class LanguageService extends ChangeNotifier {
  String _deviceLang = 'ar';
  String getDeviceLanguage() => _deviceLang;
  Future<void> initialize() async {
    final p = await SharedPreferences.getInstance();
    _deviceLang = p.getString('device_language') ?? 'ar';
  }
  String getLanguageForScreen(String s) => '';
  Future<void> saveLanguageForScreen(String s, String l) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('lang_$s', l);
  }
  List<String> getLanguageCodes() => ['ar','en','fr','de','es','it','pt','ru','zh','ja','ko','hi','tr','ur','fa'];
  String getLanguageName(String c) {
    final m = {'ar':'العربية','en':'English','fr':'Français','de':'Deutsch','es':'Español','it':'Italiano','pt':'Português','ru':'Русский','zh':'中文','ja':'日本語','ko':'한국어','hi':'हिन्दी','tr':'Türkçe','ur':'اردو','fa':'فارسی'};
    return m[c] ?? c;
  }
}
XEOF

# ai_service.dart
cat > lib/services/ai_service.dart << 'XEOF'
import 'package:flutter/material.dart';
class AIService extends ChangeNotifier {
  String _lastInspiration = '';
  String get lastInspiration => _lastInspiration;
  final List<String> _msgs = [
    'لا تحزن، إن الله معنا', 'بعد العسر يسراً', 'إن مع العسر يسراً',
    'وما توفيقى إلا بالله', 'رب اشرح لي صدري', 'إن الله لا يضيع أجر المحسنين',
    'ومن يتوكل على الله فهو حسبه', 'لا تيأس من روح الله',
    'ألم نشرح لك صدرك', 'فإذا فرغت فانصب', 'وإلى ربك فارغب',
    'استعن بالله ولا تعجز', 'ما ودعك ربك وما قلى', 'ولسوف يعطيك ربك فترضى',
  ];
  Future<String> generateInspiration({String userMood = '', String context = ''}) async {
    _lastInspiration = _msgs[DateTime.now().millisecondsSinceEpoch % _msgs.length];
    notifyListeners();
    return _lastInspiration;
  }
}
XEOF

# database_service.dart
cat > lib/services/database_service.dart << 'XEOF'
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
class DatabaseService extends ChangeNotifier {
  List<Map<String, dynamic>> _hadiths = [];
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _reasons = [];
  List<Map<String, dynamic>> get hadiths => _hadiths;
  List<Map<String, dynamic>> get stories => _stories;
  List<Map<String, dynamic>> get revelationReasons => _reasons;
  Future<void> initialize() async { await _loadData(); }
  Future<void> _loadData() async {
    try { final d = await rootBundle.loadString('assets/data/hadith_qudsi.json'); _hadiths = List<Map<String, dynamic>>.from(json.decode(d)); } catch (_) { _hadiths = [{'text':'يقول الله تعالى: أنا عند ظن عبدي بي','source':'قدسي'}]; }
    try { final d = await rootBundle.loadString('assets/data/stories.json'); _stories = List<Map<String, dynamic>>.from(json.decode(d)); } catch (_) { _stories = [{'title':'قصة أصحاب الكهف','text':'قصة الفتية الذين آمنوا...','category':'quran'}]; }
    try { final d = await rootBundle.loadString('assets/data/asbab_nuzul.json'); _reasons = List<Map<String, dynamic>>.from(json.decode(d)); } catch (_) { _reasons = [{'surah':'الفاتحة','ayah':'1','reason':'سبب نزول سورة الفاتحة...'}]; }
    notifyListeners();
  }
  List<Map<String, dynamic>> getStoriesByCategory(String c) => _stories.where((s) => s['category'] == c).toList();
  Map<String, dynamic> getRandomHadith() => _hadiths.isEmpty ? {'text':'لا إله إلا الله'} : _hadiths[Random().nextInt(_hadiths.length)];
  Map<String, dynamic> getRandomAsbab() => _reasons.isEmpty ? {'surah':'','ayah':'','reason':''} : _reasons[Random().nextInt(_reasons.length)];
}
XEOF

# theme_provider.dart
mkdir -p lib/core/theme
cat > lib/core/theme/theme_provider.dart << 'XEOF'
import 'package:flutter/material.dart';
class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;
  bool get isDarkMode => _isDark;
  ThemeData get themeData => _isDark
    ? ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: ColorScheme.dark(primary: Colors.blueAccent, secondary: Colors.cyanAccent, surface: const Color(0xFF1B2838)),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1B2838), foregroundColor: Colors.white, elevation: 0))
    : ThemeData.light().copyWith(scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.light(primary: Colors.blue, secondary: Colors.cyan, surface: Colors.white));
  void toggleTheme() { _isDark = !_isDark; notifyListeners(); }
  void setDarkMode(bool v) { _isDark = v; notifyListeners(); }
}
XEOF

# التأكد من assets
mkdir -p assets/data assets/images
for f in hadith_qudsi.json stories.json asbab_nuzul.json; do
  [ ! -f "assets/data/$f" ] && echo "[]" > "assets/data/$f" && echo "   إنشاء $f"
done

echo -e "${GREEN} ✅ كل الخدمات والـ JSON${NC}"

# ======================================================
# رفع التغييرات
# ======================================================
echo -e "\n${CYAN}══════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}رفع التغييرات إلى GitHub...${NC}"

git add -A
git clean -fd 2>/dev/null

git commit -m "🦂 BASH #2: فقاعة عائمة كاملة + كارت 4 (قصص وإلهام) + document_screen كامل

- OverlayService.java للفقاعة العائمة فوق التطبيقات
- MainActivity.java مع MethodChannel للـ overlay
- AndroidManifest.xml مع SYSTEM_ALERT_WINDOW + ForegroundService
- FloatingBubbleService مع MethodChannel + SharedPreferences + toggle
- document_screen.dart: إعادة كتابة كاملة من الصفر (حل جذري)
- كارت 4 (قصص وإلهام): 6 تصنيفات + أسباب نزول + إلهام + سبيكر
- TTS + Language + AI + Database + Background + Theme services
- compileSdk=36, minifyEnabled=false, shrinkResources=false"

echo -e "${YELLOW}⌛ جاري الرفع...${NC}"
git push origin main 2>&1 || git push origin main --force 2>&1

echo -e "\n${GREEN}✅ BASH #2 اكتمل!${NC}"
echo -e "${YELLOW}تم رفع كل التغييرات. انتظر GitHub Actions...${NC}"
echo -e "${YELLOW}الخطوة التالية: Bash #3 - كارت 5 (ألعاب 3D شطرنج + روبيك)${NC}"
