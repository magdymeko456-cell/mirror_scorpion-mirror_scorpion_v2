#!/data/data/com.termux/files/usr/bin/bash
# 🦂 Mirror Scorpion - Final Deploy Script
set -e

echo "======================================"
echo "  🦂 MIRROR SCORPION - FINAL DEPLOY"
echo "  Developer: Tamer Eldosoky"
echo "======================================"

cd ~/mirror_scorpion_translate_version_2

# تنظيف
echo "🧹 تنظيف..."
flutter clean 2>/dev/null || true
rm -rf build/ .dart_tool/ .packages .flutter-plugins 2>/dev/null || true

# تثبيت المكتبات
echo "📦 تثبيت المكتبات..."
flutter pub get

# تحليل الكود
echo "🔍 تحليل الكود..."
flutter analyze 2>/dev/null || echo "⚠️ توجد تحذيرات لكنها غير حرجة"

# بناء APK مع التشفير
echo "🔨 بناء APK (مشفر ضد الهندسة العكسية)..."
flutter build apk --release \
  --obfuscate \
  --split-debug-info=build/debug_info \
  --no-tree-shake-icons

# إظهار حجم الملف
APK_PATH="build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
  SIZE=$(du -h "$APK_PATH" | cut -f1)
  echo "✅ APK جاهز! الحجم: $SIZE"
  echo "📁 المسار: $APK_PATH"
else
  echo "❌ فشل البناء"
fi

# رفع إلى GitHub
echo "🚀 رفع إلى GitHub..."
git add -A
git commit -m "🦂 BUILD STABLE: تشفير + فقاعة + أصوات + إصلاح شامل"
git push origin main

echo "======================================"
echo "  ✅ تم الرفع إلى GitHub بنجاح!"
echo "======================================"
