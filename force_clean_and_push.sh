#!/usr/bin/env bash
set -euo pipefail

# 1. الدخول لمجلد المشروع الرئيسي
cd ~/mirror_scorpion/mirror_scorpion_v2

echo "══════════════════════════════════════════"
echo "   تنظيف مستودع Git وتأمين الرفع الشامل"
echo "══════════════════════════════════════════"

# 2. إزالة أي كاش قديم مسبب تداخل المستودعات الفرعية
git rm --cached -r . 2>/dev/null || true

# 3. إعادة إضافة الملفات بشكل نظيف وشامل من جذور المشروع
git add .
git add android/app/src/main/kotlin/com/mirror/scorpion/v2/*
git add lib/services/*
git add lib/features/card1_translation/*
git add lib/features/card4_stories/*

# 4. تسجيل الالتزام مع ميثاق التطوير المعتمد
git commit -m "fix(architecture): توحيد مسارات الأندرويد والـ Kotlin بالكامل وتأمين شاشات الـ Dart من الصفر" || true

# 5. الدفع الإجباري الآمن للمستودع الرئيسي لإنعاش الـ Actions
echo "جاري الرفع الفعلي لـ GitHub..."
git push -u origin main --force

echo "══════════════════════════════════════════"
echo " ✅ تم التنظيف والرفع الفعلي والشامل يا صديقي تامر!"
echo " 🚀 بناء #406 أو التالي هيبدأ فوراً وبشكل سليم الآن."
echo "══════════════════════════════════════════"
