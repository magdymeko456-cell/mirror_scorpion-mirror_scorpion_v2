#!/bin/bash
# سكربت مستقل لتصحيح تعليق الـ Gradle في مشروع Mirror Scorpion
FILE="android/app/build.gradle"

if [ -f "$FILE" ]; then
    # حذف السطر الذي يحتوي على التعليق المكسور تماماً
    sed -i '/# تعطيل التشفير والتقليص تماماً كما طلب المستخدم/d' "$FILE"
    echo "✅ تم حذف السطر المسبب للمشكلة بنجاح من ملف build.gradle"
else
    echo "❌ خطأ: الملف غير موجود في هذا المسار!"
fi
