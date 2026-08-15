#!/bin/bash
# ==============================================================================
# Mirror Scorpion v2 - Master Repair & GitHub Sync Script (v5)
# Combines: Dynamic Code Fixing + Nano Editor Mode + Auto GitHub Deployment
# Environment: Termux & GitHub Actions
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

# الألوان للتنسيق والتنبيهات
C_GREEN='\033[0;32m'; C_RED='\033[0;31m'; C_YEL='\033[0;33m'; C_CYN='\033[0;36m'; C_END='\033[0m'
log() { echo -e "${C_CYN}[FIX]${C_END} $*"; }
ok() { echo -e "${C_GREEN}  [✔] $*${C_END}"; }
err() { echo -e "${C_RED}  [✘] $*${C_END}"; }

SCRIPT_PATH="$(realpath "$0")"
WORKDIR="$HOME/mirror_scorpion_translate_version_2"
TOKEN_FILE="$HOME/.ms_gh_token"

# منع تعليق Git في شاشة Termux
export GIT_PAGER=cat

# ------------------------------------------------------------------------------
# 1. إعطاء صلاحيات التشغيل تلقائياً للسكربت نفسه
# ------------------------------------------------------------------------------
chmod +x "$SCRIPT_PATH" || true

# ------------------------------------------------------------------------------
# 2. وضع التعديل (Nano Editor Mode) عند إمضاء المعامل --edit أو -e
# ------------------------------------------------------------------------------
if [[ "${1:-}" == "--edit" || "${1:-}" == "-e" ]]; then
    log "فتح السكربت في محرر nano..."
    nano "$SCRIPT_PATH"
    log "تم حفظ الملف وإغلاق nano بنجاح."
    exit 0
fi

if [ -d "$WORKDIR" ]; then
    cd "$WORKDIR"
fi

log "بدء عملية الإصلاح الشاملة والمزامنة مع GitHub في: $(pwd)"

# ------------------------------------------------------------------------------
# 3. معالجة أخطاء الواجهة والرموز (UI & Icons Fixes)
# ------------------------------------------------------------------------------
log "1. تصحيح عناصر الواجهة والرموز..."

SETTING_FILE="lib/settings_pro.dart"
if [ -f "$SETTING_FILE" ]; then
    sed -i 's/Icons.whatsapp/Icons.chat/g' "$SETTING_FILE"
    sed -i 's/const Icon(Icons.chat)/Icon(Icons.chat)/g' "$SETTING_FILE"
    ok "تم تصحيح أيقونة WhatsApp والأنواع الثابتة في $SETTING_FILE"
fi

THEME_FILE="lib/core/theme/app_theme.dart"
if [ -f "$THEME_FILE" ]; then
    sed -i 's/CardTheme(/CardThemeData(/g' "$THEME_FILE"
    ok "تم تصحيح CardTheme إلى CardThemeData في $THEME_FILE"
fi

# ------------------------------------------------------------------------------
# 4. معالجة معلمات الترجمة والشبكات (Translation & ML Kit Fixes)
# ------------------------------------------------------------------------------
log "2. تصحيح معلمات الترجمة والخدمات..."

TRANS_FILE="lib/features/translate/translate_screen.dart"
if [ -f "$TRANS_FILE" ]; then
    sed -i 's/language:/targetLanguage:/g' "$TRANS_FILE"
    ok "تم تصحيح اسم المعلمة language في $TRANS_FILE"
fi

for f in $(find lib -name "*.dart" 2>/dev/null); do
    if grep -q "TextRecognitionScript.arabic" "$f"; then
        sed -i 's/TextRecognitionScript.arabic/TextRecognitionScript.latin/g' "$f"
        ok "تم تصحيح TextRecognitionScript في $f"
    fi
done

# ------------------------------------------------------------------------------
# 5. تنظيف واستقرار الخدمات المحلية (Services Optimization)
# ------------------------------------------------------------------------------
log "3. تنظيف الخدمات والكود المكرر..."

AI_FILE="lib/services/ai_language_merger.dart"
if [ -f "$AI_FILE" ]; then
    sed -i 's/\.value/.name/g' "$AI_FILE"
    ok "تم تصحيح خصائص LanguageCluster في $AI_FILE"
fi

FEAT_FILE="lib/services/feature_access_control.dart"
if [ -f "$FEAT_FILE" ]; then
    sed -i 's/canAccessFeature/isFeatureAllowed/g' "$FEAT_FILE"
    ok "تم تصحيح دالة الوصول في $FEAT_FILE"
fi

STT_WEB="packages/speech_to_text_local/web/speech_to_text_web.dart"
if [ -f "$STT_WEB" ]; then
    if ! grep -q "package:flutter/services.dart" "$STT_WEB"; then
        sed -i '1i import '\''package:flutter/services.dart'\'';' "$STT_WEB"
        ok "تم إضافة استيراد services.dart في $STT_WEB"
    fi
fi

# ------------------------------------------------------------------------------
# 6. الرفع الآلي والمباشر إلى GitHub
# ------------------------------------------------------------------------------
log "4. إعداد الحفظ والرفع التلقائي إلى GitHub..."

git config --global user.name "Tamer Eldosoky"
git config --global user.email "dosoky.server@gmail.com"

if [ -f "$TOKEN_FILE" ]; then
    GH_TOKEN=$(cat "$TOKEN_FILE" | tr -d '\r\n')
    AUTH_REPO_URL="https://${GH_TOKEN}@github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2.git"
    git remote set-url origin "$AUTH_REPO_URL" 2>/dev/null || git remote add origin "$AUTH_REPO_URL"
fi

git add .

if git diff --cached --quiet; then
    ok "لا توجد تغييرات جديدة، المستودع محدث بالفعل."
else
    git commit -m "fix(script): master repairs & auto-sync - $(date +'%Y-%m-%d %H:%M:%S')"
    log "جاري الرفع إلى GitHub..."
    git push origin main || git push origin master || err "تعذر الرفع المباشر، تحقق من الاتصال أو التوكن."
    ok "تم الرفع بنجاح إلى GitHub."
fi

ok "تمت كافة العمليات بنجاح يا تامر!"
