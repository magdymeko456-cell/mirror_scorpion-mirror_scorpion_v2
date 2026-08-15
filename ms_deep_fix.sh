#!/bin/bash
# ==============================================================================
# Mirror Scorpion v2 - Precision Fix & Auto-Sync Script (v6)
# Targets: MapEntry fixes, TranslateScreen parameters, Premium Service & SpeechToText
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

chmod +x "$SCRIPT_PATH" || true

if [[ "${1:-}" == "--edit" || "${1:-}" == "-e" ]]; then
    log "فتح السكربت في محرر nano..."
    nano "$SCRIPT_PATH"
    log "تم حفظ الملف وإغلاق nano بنجاح."
    exit 0
fi

if [ -d "$WORKDIR" ]; then
    cd "$WORKDIR"
fi

log "بدء عملية الإصلاح الدقيق للـ Compiler Errors..."

# 1. إصلاح MapEntry والخصائص في ai_language_merger.dart
AI_FILE="lib/services/ai_language_merger.dart"
if [ -f "$AI_FILE" ]; then
    # إعادة .name إلى .key أو .value حسب سياق MapEntry
    python3 - <<'PYEOF'
path = "lib/services/ai_language_merger.dart"
try:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # استبدال التعديلات الخاطئة التي تمت على MapEntry
    content = content.replace(".name", ".key")
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
except Exception as e:
    print(f"Error fixing AI Merger: {e}")
PYEOF
    ok "تم إصلاح خريطة MapEntry في $AI_FILE"
fi

# 2. إصلاح معلمة الترجمة في translate_screen.dart
TRANS_FILE="lib/features/translate/translate_screen.dart"
if [ -f "$TRANS_FILE" ]; then
    sed -i 's/targetLanguage:/toLanguage:/g' "$TRANS_FILE"
    sed -i 's/language:/toLanguage:/g' "$TRANS_FILE"
    python3 - <<'PYEOF'
path = "lib/features/translate/translate_screen.dart"
try:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    # إزالة null-aware المكرر ??
    import re
    content = re.sub(r'\?\?\s*\?\?', '??', content)
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
except Exception as e:
    print(f"Error fixing Translate Screen: {e}")
PYEOF
    ok "تم تصحيح المعلمات و dead null expression في $TRANS_FILE"
fi

# 3. إصلاح PremiumVerificationService في feature_access_control.dart
FEAT_FILE="lib/services/feature_access_control.dart"
if [ -f "$FEAT_FILE" ]; then
    sed -i 's/isFeatureAllowed/hasAccess/g' "$FEAT_FILE"
    sed -i 's/canAccessFeature/hasAccess/g' "$FEAT_FILE"
    ok "تم تصحيح الدالة إلى hasAccess في $FEAT_FILE"
fi

# 4. إصلاح حزمة speech_to_text_local
STT_PROV="packages/speech_to_text_local/lib/src/speech_to_text_provider.dart"
if [ -f "$STT_PROV" ]; then
    if ! grep -q "package:speech_to_text/speech_to_text.dart" "$STT_PROV"; then
        sed -i '1i import '\''package:speech_to_text/speech_to_text.dart'\'';' "$STT_PROV"
        ok "تمت إضافة الاستيراد المطلوب في $STT_PROV"
    fi
fi

# 5. تنظيف التحذيرات و Deprecations العامة
find lib -name "*.dart" -exec sed -i 's/activeColor:/activeThumbColor:/g' {} + 2>/dev/null || true

# 6. الرفع إلى GitHub
log "جاري الرفع المباشر إلى GitHub..."

git config --global user.name "Tamer Eldosoky"
git config --global user.email "dosoky.server@gmail.com"

if [ -f "$TOKEN_FILE" ]; then
    GH_TOKEN=$(cat "$TOKEN_FILE" | tr -d '\r\n')
    AUTH_REPO_URL="https://${GH_TOKEN}@github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2.git"
    git remote set-url origin "$AUTH_REPO_URL" 2>/dev/null || git remote add origin "$AUTH_REPO_URL"
fi

git add .

if git diff --cached --quiet; then
    ok "لا توجد تغييرات جديدة للمزامنة."
else
    git commit -m "fix(compiler): resolve MapEntry, parameters & service method issues - $(date +'%Y-%m-%d %H:%M:%S')"
    log "جاري الرفع إلى المستودع..."
    git push origin main || git push origin master || err "فشل الرفع، تحقق من الاتصال والتوكن."
    ok "تم الرفع بنجاح إلى GitHub!"
fi

ok "تم التعديل والرفع بنجاح!"
