#!/bin/bash

echo "🏗️ جاري بدء عملية إعادة التوطين والدمج النهائي للملفات الذهبية..."
echo "----------------------------------------------------------------------"

# 1. إعادة نقل ملفات الـ Assets والـ JSON الذهبية إلى مكانها الأصلي
echo "📦 نقل ملفات الداتا والـ Assets..."
mkdir -p assets/data

# البحث عن ملفات الـ json في المجلدات الفرعية ونقلها للأصل
find mirror_scorpion_v2 mirror_scorpion_update -name "*.json" 2>/dev/null | while read -r file; do
    filename=$(basename "$file")
    echo "🚚 نقل $filename إلى assets/data/"
    cp "$file" "assets/data/$filename"
done

# 2. إعادة نقل ملفات الـ Lib والشاشات والخدمات الذهبية
echo "📂 نقل ملفات الـ Dart والشاشات إلى الـ lib الرئيسي..."

# مصفوفة للملفات الذهبية اللي السكربت حددها في المجلدات الفرعية ومسارها الأصلي المفترض
declare -A files_map
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/features/home_screen.dart"]="lib/features/home_screen.dart"
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/features/card3_document/document_screen.dart"]="lib/features/card3_document/document_screen.dart"
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/features/card4_stories/stories_screen.dart"]="lib/features/card4_stories/stories_screen.dart"
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/features/games/rubik_cube/rubik_cube_screen.dart"]="lib/features/games/rubik_cube/rubik_cube_screen.dart"
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/features/games/chess/chess_screen.dart"]="lib/features/games/chess/chess_screen.dart"
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/features/admin/key_generator_screen.dart"]="lib/features/admin/key_generator_screen.dart"
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/features/settings/settings_screen.dart"]="lib/features/settings/settings_screen.dart"
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/services/premium_verification_service.dart"]="lib/services/premium_verification_service.dart"
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/services/ai_service.dart"]="lib/services/ai_service.dart"
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/services/tts_service.dart"]="lib/services/tts_service.dart"
files_map["mirror_scorpion_v2/mirror_scorpion_update/lib/services/language_service.dart"]="lib/services/language_service.dart"
files_map["mirror_scorpion_v2/lib/settings_pro.dart"]="lib/settings_pro.dart"

for src in "${!files_map[@]}"; do
    dest="${files_map[$src]}"
    if [ -f "$src" ]; then
        echo "🚚 نقل الملف الذهبي: $(basename "$src") -> $dest"
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
    elif [ -f "mirror_scorpion_update/${src#*/mirror_scorpion_update/}" ]; then
        # محاولة أخرى لو كان المسار في المجلد الثاني
        echo "🚚 نقل الملف الذهبي من التحديث: $(basename "$src") -> $dest"
        mkdir -p "$(dirname "$dest")"
        cp "mirror_scorpion_update/${src#*/mirror_scorpion_update/}" "$dest"
    fi
done

# 3. استرجاع ملفات الـ Packages والـ Scripts الناقصة
echo "📦 تأمين الـ Packages والـ Scripts..."
if [ -d "mirror_scorpion_v2/mirror_scorpion_update/scripts" ]; then
    mkdir -p scripts
    cp -r mirror_scorpion_v2/mirror_scorpion_update/scripts/* scripts/ 2>/dev/null
fi

# استرجاع pubspec الخاص بالـ package لو كان طار
git checkout HEAD -- packages/dash_bubble_local/pubspec.yaml 2>/dev/null

# 4. التطهير الفعلي للمجلدات المكررة بالكامل بعد الاطمئنان على النقل
echo "🗑️ جاري حذف المجلدات الفرعية المكررة لتنظيف الـ Git..."
rm -rf mirror_scorpion_update
# فك ارتباط المجلد الداخلي المكرر لو كان submodule أو فولدر عادي
git rm -f mirror_scorpion_v2 2>/dev/null
rm -rf mirror_scorpion_v2

echo "----------------------------------------------------------------------"
echo "🎉 تم دمج كل شيء في المجلد الرئيسي بنجاح وبأعلى داتا كاملة!"
