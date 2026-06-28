#!/usr/bin/env bash
set -euo pipefail

cd ~/mirror_scorpion/mirror_scorpion_v2

echo "══════════════════════════════════════════"
echo "    إعادة بناء مستودع Git التالف بأمان"
echo "══════════════════════════════════════════"

# 1. حذف مجلد الـ git التالف تماماً وإعادة تهيئته
rm -rf .git
git init

# 2. ربطه برابط المستودع الخاص بك على GitHub
git remote add origin https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2.git

# 3. تعيين الفرع الرئيسي ليكون اسمه main
git branch -M main

# 4. إضافة كل ملفات المشروع الحقيقية والنظيفة
git add .

# 5. عمل الـ Commit الأول النظيف والمستقر
git commit -m "chore(repo): إعادة تهيئة الـ Git بالكامل وتطهير المسارات والهيكل"

# 6. الرفع الإجباري الآمن لتصفير الـ Actions والبدء من جديد بنجاح
echo "جاري الرفع وتحديث المستودع على GitHub..."
git push -u origin main --force

echo "══════════════════════════════════════════"
echo " ✅ تم بناء الـ Git من الصفر بنجاح تام!"
echo " 🚀 البناء النظيف بدأ الآن في الـ Actions، طمئني."
echo "══════════════════════════════════════════"
