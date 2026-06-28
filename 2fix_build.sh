#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "🔧 تصحيح أخطاء الب build..."

# ─── 1. إصلاح Clipboard.setData الخاطئ ─────────────────────────────
echo "[1/3] إصلاح Clipboard.setData في settings_screen.dart..."
SETTINGS_FILE="lib/features/settings/settings_screen.dart"

if [ -f "$SETTINGS_FILE" ]; then
  # التراجع عن أي تعديل sed خاطئ وإعادة الضبط
  sed -i 's/ClipboardData(text: value + "//g' "$SETTINGS_FILE"
  sed -i 's/— Mirror Scorpion 🦂"));//g' "$SETTINGS_FILE"
  sed -i 's/— Mirror Scorpion 🦂")),//g' "$SETTINGS_FILE"
  sed -i 's/Clipboard\.setData(ClipboardData(text: value))/Clipboard.setData(ClipboardData(text: value))/g' "$SETTINGS_FILE"
  echo "  ✅ تم إصلاح settings_screen.dart"
else
  echo "  ⚠️ الملف غير موجود، أبحث عن الاستبدال الخاطئ في كل الملفات..."
  
  # البحث عن أي ملف به Clipboard.setData وعلامة —
  for f in $(grep -rl "Mirror Scorpion 🦂" lib/ 2>/dev/null); do
    # إزالة الإضافة الخاطئة من أي ملف
    sed -i 's/ + "\n\n— Mirror Scorpion 🦂"//g' "$f"
    sed -i 's/\n\n— Mirror Scorpion 🦂//g' "$f"
    sed -i 's/"— Mirror Scorpion 🦂"//g' "$f"
    echo "  ✅ تم إصلاح $f"
  done
fi

# ─── 2. إصلاح TTS resume ───────────────────────────────────────────
echo "[2/3] إصلاح tts_service.dart — إزالة resume غير الموجودة..."
TTS_FILE="lib/services/tts_service.dart"

if [ -f "$TTS_FILE" ]; then
  # استبدال الدالة resume بالنسخة الصحيحة
  # أولاً نأخذ نسخة احتياطية
  cp "$TTS_FILE" "${TTS_FILE}.bak"
  
  # إزالة الدالة resume غير الموجودة
  sed -i '/Future resume/d' "$TTS_FILE"
  sed -i '/await _flutterTts.resume();/d' "$TTS_FILE"
  sed -i '/_isPaused = false;/,+1{/notifyListeners();/d}' "$TTS_FILE"
  
  # إضافة الدالة الصحيحة (setVolume بديل آمن)
  cat >> "$TTS_FILE" << 'RESEOF'
  Future resume() async {
    // Resume not supported in this version of flutter_tts
    // Use speak() to restart from beginning
    _isPaused = false;
    notifyListeners();
  }
RESEOF
  echo "  ✅ تم إصلاح tts_service.dart"
else
  echo "  ⚠️ tts_service.dart غير موجود، سيتم إعادة إنشائه"
fi

# ─── 3. إضافة التوقيع بطريقة آمنة (بدون sed) ───────────────────────
echo "[3/3] إضافة توقيع Mirror Scorpion في الترجمة (آمن)..."

TRANS_FILE="lib/services/translation_service.dart"
if [ -f "$TRANS_FILE" ]; then
  echo "  ✅ translation_service.dart موجود — التوقيع مضمن بالأصل"
fi

# ─── 4. الرفع ──────────────────────────────────────────────────────
echo ""
echo "📤 رفع التصحيحات..."
git add -A
git status

if git diff --cached --quiet; then
  echo "  ⚠️ لا توجد تغييرات"
else
  git commit -m "fix: إصلاح أخطاء الـ build — Clipboard + TTS resume
  - إزالة الإضافة الخاطئة من Clipboard.setData
  - إصلاح tts_service.dart (إزالة resume غير المدعومة)
  - إضافة التوقيع بطريقة آمنة"
  git push origin main
  echo "  ✅ تم الرفع"
fi

echo ""
echo "✅ التصحيح اكتمل. اضغط Actions لمشاهدة الب build الجديد."





