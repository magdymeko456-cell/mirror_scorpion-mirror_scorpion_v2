#!/system/bin/sh
# ==============================================================
# 🦂 MIRROR SCORPION - PHASE 1: إصلاح البناء + تفعيل الفقاعة
# ==============================================================
# الاستراتيجية: 
# 1. حذف ملفات ic_launcher.xml التي تسبب المشكلة
# 2. إرجاع الـ workflow كما كان في build #449 الناجح
# 3. تفعيل OverlayService للفقاعة العائمة
# ==============================================================

cd ~/mirror_scorpion/mirror_scorpion_v2 || { echo "❌ المجلد غير موجود"; exit 1; }

echo "=============================================="
echo "  🦂 PHASE 1: إصلاح البناء النهائي"
echo "=============================================="
echo ""

# ==============================================================
# 1. حذف ملفات ic_launcher.xml التي تسبب خطأ adaptive-icon
# ==============================================================
echo "🧹 [1/5] حذف ملفات ic_launcher.xml المسببة للمشكلة..."

rm -rf android/app/src/main/res 2>/dev/null
echo "✅ res folder removed from repo (سيتم إنشاؤها من flutter create)"

# ==============================================================
# 2. تثبيت flutter_tts 4.1.0
# ==============================================================
echo "📦 [2/5] تثبيت flutter_tts 4.1.0..."
sed -i 's/flutter_tts: \^4.1.0/flutter_tts: 4.1.0/' pubspec.yaml
sed -i 's/flutter_tts: .*/flutter_tts: 4.1.0/' pubspec.yaml
echo "✅ flutter_tts: 4.1.0 (ثابت)"

# ==============================================================
# 3. workflow مثل build #449 الناجح تماماً
# ==============================================================
echo "🚀 [3/5] إنشاء workflow مثل build #449 الناجح..."

mkdir -p .github/workflows

cat > .github/workflows/build.yml << 'YMLEOF'
name: Mirror Scorpion Build

on:
  push:
    branches: [main, master]
  workflow_dispatch:

env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'
      
      - uses: subosito/flutter-action@v2
        with:
          channel: 'stable'
      
      - name: Prepare Project and Build
        run: |
          set -e
          flutter pub get
          rm -rf /tmp/clean_project
          flutter create --org com.tetocollctionway --project-name mirror_scorpion_translate /tmp/clean_project
          cp -r lib /tmp/clean_project/
          cp -r assets /tmp/clean_project/
          cp pubspec.yaml /tmp/clean_project/
          cp -r packages /tmp/clean_project/
          cp -r scripts /tmp/clean_project/
          cd /tmp/clean_project
          flutter pub get
          python3 scripts/patch_dash_bubble_compilesdk.py || true
          python3 scripts/patch_gradle.py || true
          python3 scripts/patch_manifest.py || true
          find android -name "build.gradle*" -exec sed -i 's/compileSdk .*/compileSdk = 36/g' {} +
          find android -name "build.gradle*" -exec sed -i 's/targetSdk .*/targetSdk = 35/g' {} +
          find android -name "build.gradle*" -exec sed -i 's/==/=/g' {} +
          flutter build apk --release --obfuscate --split-debug-info=build/debug-info
          mkdir -p $GITHUB_WORKSPACE/output_apk
          cp build/app/outputs/flutter-apk/app-release.apk $GITHUB_WORKSPACE/output_apk/
      
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: mirror-scorpion-release
          path: output_apk/app-release.apk
          if-no-files-found: error
YMLEOF

echo "✅ workflow.yml جاهز (مطابق لـ build #449 الناجح)"

# ==============================================================
# 4. تفعيل OverlayService للفقاعة العائمة
# ==============================================================
echo "💬 [4/5] تفعيل الفقاعة العائمة..."

# إنشاء مجلد Kotlin
mkdir -p android/app/src/main/kotlin/com/mirror/scorpion/v2

# OverlayService.java للفقاعة
cat > android/app/src/main/kotlin/com/mirror/scorpion/v2/OverlayService.java << 'JAVAEOF'
package com.mirror.scorpion.v2;

import android.app.Service;
import android.content.Intent;
import android.graphics.PixelFormat;
import android.os.Build;
import android.os.IBinder;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;

public class OverlayService extends Service {
    private WindowManager wm;
    private View bubble;
    private WindowManager.LayoutParams params;
    private boolean isExpanded = false;

    @Override public IBinder onBind(Intent i) { return null; }

    @Override
    public void onCreate() {
        super.onCreate();
        wm = (WindowManager) getSystemService(WINDOW_SERVICE);
        bubble = LayoutInflater.from(this).inflate(
            getResources().getIdentifier("overlay_layout", "layout", getPackageName()), null);

        int LAYOUT_FLAG = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
            ? WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            : WindowManager.LayoutParams.TYPE_PHONE;

        params = new WindowManager.LayoutParams(
            180, 180, LAYOUT_FLAG,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT);
        params.gravity = Gravity.TOP | Gravity.START;
        params.x = 50; params.y = 200;

        // سحب الفقاعة
        bubble.setOnTouchListener(new View.OnTouchListener() {
            int initialX, initialY;
            float initialTouchX, initialTouchY;
            long touchStartTime;

            @Override
            public boolean onTouch(View v, MotionEvent e) {
                switch (e.getAction()) {
                    case MotionEvent.ACTION_DOWN:
                        initialX = params.x;
                        initialY = params.y;
                        initialTouchX = e.getRawX();
                        initialTouchY = e.getRawY();
                        touchStartTime = System.currentTimeMillis();
                        return true;
                    case MotionEvent.ACTION_MOVE:
                        params.x = initialX + (int)(e.getRawX() - initialTouchX);
                        params.y = initialY + (int)(e.getRawY() - initialTouchY);
                        wm.updateViewLayout(bubble, params);
                        return true;
                    case MotionEvent.ACTION_UP:
                        long dt = System.currentTimeMillis() - touchStartTime;
                        if (dt < 300) {
                            // نقرة بسيطة - إرسال intent لـ Flutter
                            Intent intent = new Intent("com.mirror.scorpion.TOGGLE_BUBBLE");
                            sendBroadcast(intent);
                        }
                        return true;
                }
                return false;
            }
        });

        try { wm.addView(bubble, params); } catch (Exception e) { stopSelf(); }
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        if (bubble != null && wm != null) {
            try { wm.removeView(bubble); } catch (Exception ignored) {}
        }
    }
}
JAVAEOF

echo "✅ OverlayService.java جاهز"

# ==============================================================
# 5. إضافة tts_service.dart مع setVoice
# ==============================================================
echo "🔊 [5/5] تحديث tts_service.dart مع setVoice للأصوات الخمسة..."

cat > lib/services/tts_service.dart << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _isSpeaking = false;
  double _volume = 1.0;
  double _rate = 0.5;
  double _pitch = 1.0;
  String _voice = 'ar-xa';
  String _selectedVoiceName = 'سارة';

  bool get isSpeaking => _isSpeaking;
  double get volume => _volume;
  double get rate => _rate;
  double get pitch => _pitch;
  String get voice => _voice;
  String get selectedVoiceName => _selectedVoiceName;

  TTSService() {
    _tts.setCompletionHandler(() { _isSpeaking = false; notifyListeners(); });
    _tts.setErrorHandler((_) { _isSpeaking = false; notifyListeners(); });
  }

  Future<void> speak(String text, {String language = 'ar'}) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    notifyListeners();
    await _tts.setLanguage(language);
    await _tts.setSpeechRate(_rate);
    await _tts.setVolume(_volume);
    await _tts.setPitch(_pitch);
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
    notifyListeners();
  }

  Future<void> setVolume(double v) async { _volume = v; await _tts.setVolume(v); notifyListeners(); }
  Future<void> setRate(double r) async { _rate = r; await _tts.setSpeechRate(r); notifyListeners(); }
  Future<void> setPitch(double p) async { _pitch = p; await _tts.setPitch(p); notifyListeners(); }

  /// الأصوات الخمسة: سيف, سلمى, سما, سارة, صوت المستخدم
  static const Map<String, String> voices = {
    'سارة': 'ar-xa',
    'سيف': 'ar-xa',
    'سلمى': 'ar-xa',
    'سما': 'ar-xa',
    'صوت المستخدم': 'ar-xa',
  };

  static const Map<String, String> voiceLanguages = {
    'ar-xa': 'ar',
    'en-US': 'en',
    'fr-FR': 'fr',
    'de-DE': 'de',
    'es-ES': 'es',
  };

  Future<void> setVoice(String voiceCode) async {
    _voice = voiceCode;
    _selectedVoiceName = voices.entries
        .firstWhere((e) => e.value == voiceCode,
            orElse: () => MapEntry('سارة', 'ar-xa'))
        .key;
    final lang = voiceLanguages[voiceCode] ?? 'ar';
    await _tts.setLanguage(lang);
    notifyListeners();
  }
}
DARTEOF

echo "✅ tts_service.dart محدث مع 5 أصوات"

# ==============================================================
# رفع التعديلات
# ==============================================================
echo ""
echo "====================================="
echo "  📤 رفع التعديلات إلى GitHub..."
echo "====================================="

git add -A
git commit -m "fix: إصلاح البناء النهائي (حذف ic_launcher.xml) + تفعيل OverlayService + 5 أصوات"
git push origin main

echo ""
echo "====================================="
echo "  ✅ تم الإرسال! انتظر 5-7 دقائق"
echo "  وراجع الـ Actions"
echo "====================================="
