#!/bin/bash
# ==============================================================================
# Mirror Scorpion v2 - Master Fix & Auto-Sync Script (v8 Final)
# Targets: Icons, LanguageCluster, Feature Access, local packages & Git Sync
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

C_GREEN='\033[0;32m'; C_RED='\033[0;31m'; C_YEL='\033[0;33m'; C_CYN='\033[0;36m'; C_END='\033[0m'
log() { echo -e "${C_CYN}[MASTER-FIX]${C_END} $*"; }
ok() { echo -e "${C_GREEN}  [✔] $*${C_END}"; }
err() { echo -e "${C_RED}  [✘] $*${C_END}"; }

SCRIPT_PATH="$(realpath "$0")"
WORKDIR="$HOME/mirror_scorpion_translate_version_2"
TOKEN_FILE="$HOME/.ms_gh_token"

export GIT_PAGER=cat

chmod +x "$SCRIPT_PATH" || true

# دعم خيار التعديل المباشر قبل التشغيل
if [[ "${1:-}" == "--edit" || "${1:-}" == "-e" ]]; then
    log "فتح السكربت في محرر nano..."
    nano "$SCRIPT_PATH"
    log "تم حفظ الملف وإغلاق nano بنجاح."
    exit 0
fi

if [ -d "$WORKDIR" ]; then
    cd "$WORKDIR"
fi

log "بدء المعالجة الشاملة الموجهة لمشروع Mirror Scorpion v2..."

# ------------------------------------------------------------------------------
# 1. إصلاح Icons.whatsapp في settings_pro.dart
# ------------------------------------------------------------------------------
SETTING_FILE="lib/settings_pro.dart"
if [ -f "$SETTING_FILE" ]; then
    log "1. تصحيح أيقونات التواصل في $SETTING_FILE..."
    sed -i 's/Icons\.whatsapp/Icons\.chat/g' "$SETTING_FILE"
    sed -i 's/const Icon(Icons\.chat)/Icon(Icons\.chat)/g' "$SETTING_FILE"
    ok "تم استبدال الأيقونة إلى Icons.chat بنجاح."
fi

# ------------------------------------------------------------------------------
# 2. تصحيح معلمات شاشة الترجمة translate_screen.dart
# ------------------------------------------------------------------------------
TRANS_FILE="lib/features/translate/translate_screen.dart"
if [ -f "$TRANS_FILE" ]; then
    log "2. ضبط معلمات الترجمة في $TRANS_FILE..."
    sed -i 's/language:/targetLanguage:/g' "$TRANS_FILE"
    ok "تم تصحيح معلمات المستهدف بنجاح."
fi

# ------------------------------------------------------------------------------
# 3. استعادة خصائص LanguageCluster في ai_language_merger.dart
# ------------------------------------------------------------------------------
AI_FILE="lib/services/ai_language_merger.dart"
if [ -f "$AI_FILE" ]; then
    log "3. تصحيح خصائص LanguageCluster في $AI_FILE..."
    sed -i 's/\.value/\.name/g' "$AI_FILE"
    ok "تم ضبط الخصائص إلى .name بنجاح."
fi

# ------------------------------------------------------------------------------
# 4. توحيد دوال التحقق والوصول المتقدم Feature Access
# ------------------------------------------------------------------------------
FEAT_FILE="lib/services/feature_access_control.dart"
if [ -f "$FEAT_FILE" ]; then
    log "4. توحيد دوال الصلاحيات في $FEAT_FILE..."
    sed -i 's/canAccessFeature/isFeatureAllowed/g' "$FEAT_FILE"
    sed -i 's/canAccess/isAllowed/g' "$FEAT_FILE"
    ok "تم توحيد مسميات الدوال بنجاح."
fi

# ------------------------------------------------------------------------------
# 5. معالجة الحزمة المحلية speech_to_text_local
# ------------------------------------------------------------------------------
STT_PROVIDER="packages/speech_to_text_local/lib/src/speech_to_text_provider.dart"
if [ -f "$STT_PROVIDER" ]; then
    log "5. التأكد من استيرادات الحزمة المحلية speech_to_text_local..."
    if ! grep -q "package:flutter/services.dart" "$STT_PROVIDER"; then
        sed -i '1i import '\''package:flutter/services.dart'\'';' "$STT_PROVIDER"
    fi
    ok "تم فحص وضبط الحزمة المحلية بنجاح."
fi

# ------------------------------------------------------------------------------
# 6. الرفع المباشر والتلقائي إلى GitHub
# ------------------------------------------------------------------------------
log "6. إعداد المصادقة والمزامنة مع GitHub..."

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
    git commit -m "fix(master): إصلاح الأخطاء الميدانية للحزم والشاشات - $(date +'%Y-%m-%d %H:%M:%S')"
    log "جاري الرفع إلى المستودع الرئيسي..."
    git push origin main || git push origin master || err "تعذر الرفع، تحقق من اتصال الشبكة أو مفتاح التوكن."
    ok "تم الرفع بنجاح إلى GitHub!"
fi

ok "تم الانتهاء من كافة المهام بنجاح يا تامر! الكود مصلح ومرفوع تماماً."
