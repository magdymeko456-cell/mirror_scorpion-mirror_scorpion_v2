#!/bin/bash
# ==============================================================================
# Mirror Scorpion v2 - Deep Repository & Code Structure Inspector
# ==============================================================================

WORKDIR="$HOME/mirror_scorpion_translate_version_2"
if [ -d "$WORKDIR" ]; then cd "$WORKDIR"; fi

echo "=================================================="
echo "          Mirror Scorpion Code Inspection         "
echo "=================================================="

echo -e "\n[1] المزايا والمكتبات المستوردة (Packages & Imports):"
grep -r "^import " lib/ | cut -d: -f2 | sort -u

echo -e "\n[2] الهياكل والكلاسات الرئيسية (Classes Defined):"
grep -r "class " lib/ | awk -F: '{print $1, "->", $2}' | head -n 30

echo -e "\n[3] حالة الملفات التي تحتوي على أخطاء تركيبية معروفة:"
for file in "lib/features/hadith_stories/hadith_stories_screen.dart" "lib/services/ai_language_merger.dart"; do
    if [ -f "$file" ]; then
        echo "--- $file ---"
        head -n 25 "$file"
    fi
done

echo "=================================================="
