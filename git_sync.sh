#!/bin/bash
echo "🦂 رفع تحديثات Mirror Scorpion إلى GitHub..."
git add .
git commit -m "🦂 PHASE 1: إصلاح الأساس - مسارات + خدمات + pubspec محدث - $(date)"
git push origin main
echo "✅ تم الرفع بنجاح!"
