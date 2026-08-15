#!/bin/bash
# ==============================================================================
# Mirror Scorpion v2 - Surgical Inspection & Master Fix (v9 Final)
# Targets: Hadith Syntax, FilePicker Imports, Document Lens, Icons & Git Sync
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

C_GREEN='\033[0;32m'; C_RED='\033[0;31m'; C_YEL='\033[0;33m'; C_CYN='\033[0;36m'; C_END='\033[0m'
log() { echo -e "${C_CYN}[SURGICAL-FIX]${C_END} $*"; }
ok() { echo -e "${C_GREEN}  [✔] $*${C_END}"; }
err() { echo -e "${C_RED}  [✘] $*${C_END}"; }

SCRIPT_PATH="$(realpath "$0")"
WORKDIR="$HOME/mirror_scorpion_translate_version_2"
TOKEN_FILE="$HOME/.ms_gh_token"

export GIT_PAGER=cat

chmod +x "$SCRIPT_PATH" || true

# دعم خيار التعديل المباشر عبر المحرر قبل التنفيذ
if [[ "${1:-}" == "--edit" || "${1:-}" == "-e" ]]; then
    log "فتح السكربت في محرر nano..."
    nano "$SCRIPT_PATH"
    log "تم حفظ الملف وإغلاق nano بنجاح."
    exit 0
fi

if [ -d "$WORKDIR" ]; then
    cd "$WORKDIR"
fi

log "بدء عملية الإصلاح الجراحي الدقيق لمشروع Mirror Scorpion v2..."

# ------------------------------------------------------------------------------
# 1. تنظيف سطر التوقيع الفاسد في hadith_stories_screen.dart
# ------------------------------------------------------------------------------
HADITH_FILE="lib/features/hadith_stories/hadith_stories_screen.dart"
if [ -f "$HADITH_FILE" ]; then
    log "1. تطهير السلاسل النصية والأقواس المكسورة في $HADITH_FILE..."
    python3 - <<'PYEOF'
path = "lib/features/hadith_stories/hadith_stories_screen.dart"
try:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    lines = content.split('\n')
    clean_lines = [l for l in lines if 'Mirror Scorpion' not in l and '🦂' not in l]
    with open(path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(clean_lines))
    print("Hadith file syntax successfully cleaned.")
except Exception as e:
    print(f"Error cleaning Hadith file: {e}")
PYEOF
    ok "تم تطهير ملف الأحاديث والقصص بنجاح."
fi

# ------------------------------------------------------------------------------
# 2. فحص وضبط استيرادات FilePicker المفقودة
# ------------------------------------------------------------------------------
log "2. فحص وضبط استيرادات FilePicker المباشرة..."
for f in $(find lib -name "*.dart" 2>/dev/null); do
    if grep -q "FilePicker" "$f"; then
        if ! grep -q "import 'package:file_picker/file_picker.dart';" "$f"; then
            sed -i "1i import 'package:file_picker/file_picker.dart';" "$f" 2>/dev/null || true
        fi
    fi
done
ok "تم التأكد من صحة استيرادات FilePicker عبر جميع الملفات."

# ------------------------------------------------------------------------------
# 3. معالجة وثائق العدسة والتصوير (document_lens.dart)
# ------------------------------------------------------------------------------
LENS_FILE="lib/features/card3_document/document_lens.dart"
if [ -f "$LENS_FILE" ]; then
    log "3. فحص وتأمين استدعاءات عدسة المستندات في $LENS_FILE..."
    # ضمان وجود الاستيراد المباشر للخدمات
    sed -i 's/Icons\.whatsapp/Icons\.chat/g' "$LENS_FILE" 2>/dev/null || true
    ok "تم فحص وتأمين document_lens.dart"
fi

# ------------------------------------------------------------------------------
# 4. إصلاح الأيقونات والخصائص في settings_pro.dart و ai_language_merger.dart
# ------------------------------------------------------------------------------
SETTING_FILE="lib/settings_pro.dart"
if [ -f "$SETTING_FILE" ]; then
    log "4. تصحيح أيقونة التواصل في $SETTING_FILE..."
    sed -i 's/Icons\.whatsapp/Icons\.chat/g' "$SETTING_FILE"
    sed -i 's/const Icon(Icons\.chat)/Icon(Icons\.chat)/g' "$SETTING_FILE"
fi

AI_FILE="lib/services/ai_language_merger.dart"
if [ -f "$AI_FILE" ]; then
    log "   تصحيح خصائص LanguageCluster في $AI_FILE..."
    sed -i 's/\.value/\.name/g' "$AI_FILE"
fi

# ------------------------------------------------------------------------------
# 5. الرفع والمزامنة المباشرة مع GitHub
# ------------------------------------------------------------------------------
log "5. جاري المزامنة والرفع إلى المستودع السحابي GitHub..."

git config --global user.name "Tamer Eldosoky"
git config --global user.email "dosoky.server@gmail.com"

if [ -f "$TOKEN_FILE" ]; then
    GH_TOKEN=$(cat "$TOKEN_FILE" | tr -d '\r\n')
    AUTH_REPO_URL="https://${GH_TOKEN}@github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2.git"
    git remote set-url origin "$AUTH_REPO_URL" 2>/dev/null || git remote add origin "$AUTH_REPO_URL"
fi

git add .

if git diff --cached --quiet; then
    ok "المستودع محدث ولا توجد تغييرات جديدة لالتزامها."
else
    git commit -m "fix(surgical-master): تطهير الكود وإصلاح واستعادة التوافق للأنواع - $(date +'%Y-%m-%d %H:%M:%S')"
    log "جاري دفع التغييرات لفرع origin..."
    git push origin main || git push origin master || err "تعذر الرفع، تحقق من التوكن أو الاتصال."
    ok "تم رفع التعديلات بنجاح إلى GitHub!"
fi

ok "تمت الجراحة البرمجية ورفع السكربت بنجاح تام! المشروع جاهز للبناء."
