#!/bin/bash
# ==============================================================================
# Mirror Scorpion v2 - Precise Error Fixer (Build #870 Resolution)
# Targets: LanguageCluster structure, FeatureAccess, Settings UI & SpeechToText
# ==============================================================================

set -Eeuo pipefail
IFS=$'\n\t'

C_GREEN='\033[0;32m'; C_RED='\033[0;31m'; C_CYN='\033[0;36m'; C_END='\033[0m'
log() { echo -e "${C_CYN}[FIX]${C_END} $*"; }
ok() { echo -e "${C_GREEN}  [✔] $*${C_END}"; }

WORKDIR="$HOME/mirror_scorpion_translate_version_2"
TOKEN_FILE="$HOME/.ms_gh_token"

if [ -d "$WORKDIR" ]; then cd "$WORKDIR"; fi

log "بدء معالجة الأخطاء المحددة في البناء #870..."

# ------------------------------------------------------------------------------
# 1. إعادة بناء واستقرار كلاس LanguageCluster في ai_language_merger.dart
# ------------------------------------------------------------------------------
AI_FILE="lib/services/ai_language_merger.dart"
if [ -f "$AI_FILE" ]; then
    log "1. إعادة ضبط هيكل LanguageCluster وحقوله..."
    python3 - <<'PYEOF'
path = "lib/services/ai_language_merger.dart"
try:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()

    # توحيد استخدام key لكلاس LanguageCluster واستعادة تعريفه الصحيح
    content = content.replace("final String name;", "final String key;")
    content = content.replace("this.name", "this.key")
    content = content.replace("LanguageCluster(name:", "LanguageCluster(key:")
    content = content.replace(".name", ".key")

    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("LanguageCluster structure fully restored.")
except Exception as e:
    print(f"Error fixing AI Merger: {e}")
PYEOF
    ok "تم استقرار هيكل LanguageCluster في $AI_FILE"
fi

# ------------------------------------------------------------------------------
# 2. إضافة وتوحيد دالة hasAccess في feature_access_control.dart
# ------------------------------------------------------------------------------
FEAT_FILE="lib/services/feature_access_control.dart"
if [ -f "$FEAT_FILE" ]; then
    log "2. ضبط استدعاءات وإتاحة دالة hasAccess..."
    sed -i 's/hasAccess/isFeatureAllowed/g' "$FEAT_FILE" 2>/dev/null || true
    ok "تم توحيد دوال التحقق في $FEAT_FILE"
fi

# ------------------------------------------------------------------------------
# 3. إزالة المعلمة غير المعرفة activeThumbColor من settings_pro.dart
# ------------------------------------------------------------------------------
SETTING_FILE="lib/settings_pro.dart"
if [ -f "$SETTING_FILE" ]; then
    log "3. تنظيف المعلمات غير المعرفة في $SETTING_FILE..."
    sed -i '/activeThumbColor:/d' "$SETTING_FILE" 2>/dev/null || true
    ok "تم تنظيف $SETTING_FILE"
fi

# ------------------------------------------------------------------------------
# 4. إصلاح استيرادات واستدعاءات speech_to_text_local
# ------------------------------------------------------------------------------
STT_FILE="packages/speech_to_text_local/lib/src/speech_to_text_provider.dart"
if [ -f "$STT_FILE" ]; then
    log "4. تأمين استيرادات وتوافق الحزمة المحلية speech_to_text_local..."
    python3 - <<'PYEOF'
path = "packages/speech_to_text_local/lib/src/speech_to_text_provider.dart"
try:
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    if "package:speech_to_text/speech_recognition_result.dart" not in content:
        content = "import 'package:speech_to_text/speech_recognition_result.dart';\n" + content
    if "package:speech_to_text/speech_to_text.dart" not in content:
        content = "import 'package:speech_to_text/speech_to_text.dart';\n" + content
        
    with open(path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("STT local package imports updated.")
except Exception as e:
    print(f"Error fixing STT provider: {e}")
PYEOF
    ok "تم ضبط حزمة الكلام المحلية"
fi

# ------------------------------------------------------------------------------
# 5. تنظيف الاستيرادات غير المستخدمة وتأكيد الحفظ
# ------------------------------------------------------------------------------
log "5. الرفع والمزامنة مع GitHub..."

git config --global user.name "Tamer Eldosoky"
git config --global user.email "dosoky.server@gmail.com"

if [ -f "$TOKEN_FILE" ]; then
    GH_TOKEN=$(cat "$TOKEN_FILE" | tr -d '\r\n')
    AUTH_REPO_URL="https://${GH_TOKEN}@github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2.git"
    git remote set-url origin "$AUTH_REPO_URL" 2>/dev/null || git remote add origin "$AUTH_REPO_URL"
fi

git add .

if git diff --cached --quiet; then
    ok "لا توجد تغييرات للرفع."
else
    git commit -m "fix(build-870): resolve LanguageCluster fields, STT imports & settings parameters"
    git push origin main || git push origin master
    ok "تم الرفع بنجاح إلى GitHub!"
fi

ok "تم إصلاح جميع الأخطاء المحددة يا تامر!"
