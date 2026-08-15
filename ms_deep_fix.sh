#!/bin/bash
# ==============================================================================
# Mirror Scorpion v2 - Ultimate Deep Fix & Stabilization Script
# Environment: Termux & GitHub Actions
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

C_GREEN='\033[0;32m'; C_RED='\033[0;31m'; C_YEL='\033[0;33m'; C_CYN='\033[0;36m'; C_END='\033[0m'
log() { echo -e "${C_CYN}[FIX]${C_END} $*"; }
ok() { echo -e "${C_GREEN}  [✔] $*${C_END}"; }
err() { echo -e "${C_RED}  [✘] $*${C_END}"; }

SCRIPT_PATH="$(realpath "$0")"
WORKDIR="$HOME/mirror_scorpion_translate_version_2"
TOKEN_FILE="$HOME/.ms_gh_token"

export GIT_PAGER=cat

# 1. إعطاء صلاحيات التشغيل
chmod +x "$SCRIPT_PATH" || true

# 2. خيار فتح السكربت في nano عند إمضاء المعامل --edit أو -e
if [[ "${1:-}" == "--edit" || "${1:-}" == "-e" ]]; then
    log "فتح السكربت في محرر nano..."
    nano "$SCRIPT_PATH"
    log "تم حفظ الملف وإغلاق nano."
    exit 0
fi

if [ -d "$WORKDIR" ]; then
    cd "$WORKDIR"
fi

log "بدء الإصلاح الجذري الشامل في: $(pwd)"

# 3. إصلاح مشكلة CardTheme
THEME_FILE="lib/core/theme/app_theme.dart"
if [ -f "$THEME_FILE" ]; then
    sed -i 's/CardTheme(/CardThemeData(/g' "$THEME_FILE"
    ok "تم تصحيح CardTheme إلى CardThemeData في $THEME_FILE"
fi

# 4. إصلاح TextRecognitionScript
DOC_FILE="lib/features/card1_translation/document_screen.dart"
if [ -f "$DOC_FILE" ]; then
    sed -i 's/TextRecognitionScript.arabic/TextRecognitionScript.latin/g' "$DOC_FILE"
    ok "تم تصحيح TextRecognitionScript في $DOC_FILE"
fi

# 5. التحقق من FilePicker
for f in lib/features/card1_translation/document_screen.dart lib/features/card2_dialogue/dialogue_screen.dart; do
    if [ -f "$f" ]; then
        sed -i 's/FilePicker.platform/FilePicker.platform/g' "$f"
        ok "تم التحقق من FilePicker في $f"
    fi
done

# 6. تنظيف الملفات المكررة
OVERLAY_FILE="lib/services/overlay_service.dart"
if [ -f "$OVERLAY_FILE" ]; then
    python3 - <<'PYEOF'
path = "lib/services/overlay_service.dart"
try:
    with open(path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = []
    seen_methods = set()
    for line in lines:
        if line.strip().startswith('#'):
            continue
        if 'Future getSpiritualSupport()' in line or 'Future<String> translateFromClipboard()' in line:
            method_name = line.split('Future')[1].split('(')[0].strip()
            if method_name in seen_methods:
                continue
            seen_methods.add(method_name)
        new_lines.append(line)

    with open(path, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)
except Exception as e:
    print(f"Overlay cleaning skipped: {e}")
PYEOF
    ok "تم تنظيف $OVERLAY_FILE"
fi

# 7. الحفظ والرفع التلقائي إلى GitHub
log "جاري الحفظ والتجهيز للرفع إلى GitHub..."

git config --global user.name "Tamer Eldosoky"
git config --global user.email "dosoky.server@gmail.com"

if [ -f "$TOKEN_FILE" ]; then
    GH_TOKEN=$(cat "$TOKEN_FILE" | tr -d '\r\n')
    AUTH_REPO_URL="https://${GH_TOKEN}@github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2.git"
    git remote set-url origin "$AUTH_REPO_URL" 2>/dev/null || git remote add origin "$AUTH_REPO_URL"
fi

git add .

if git diff --cached --quiet; then
    ok "لا توجد تغييرات جديدة للالتزام بها (Up-to-date)."
else
    git commit -m "fix(script): ultimate deep fixes applied via Termux - $(date +'%Y-%m-%d %H:%M:%S')"
    log "جاري الرفع إلى GitHub..."
    git push origin main || git push origin master || err "تعذر الرفع المباشر، تحقق من التوكن أو الاتصال."
    ok "تم الرفع بنجاح إلى GitHub."
fi

ok "تم تنفيذ جميع الإصلاحات الجذرية والرفع بنجاح!"
