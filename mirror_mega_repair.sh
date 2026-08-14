#!/usr/bin/env bash
set -uo pipefail
OWNER="magdymeko456-cell"
REPO="mirror_scorpion-mirror_scorpion_v2"
BRANCH="main"
GOLDEN="ce10b41aad091f58bf5bd9c42ead8bde9d2e2315"
TOKEN_FILE="${MIRROR_TOKEN_FILE:-$HOME/.mirror_token}"
WORKDIR="${MIRROR_WORKDIR:-$HOME/mirror_scorpion_translate_version_2}"
LOG_DIR="$HOME/.ms_logs"
SNAP_DIR="$HOME/.mirror_snapshots"
REPORT="REPAIR_REPORT.md"
MAX_WAIT=1500
POLL=30
API="https://api.github.com/repos/$OWNER/$REPO"
C_GREEN='\033[0;32m'; C_RED='\033[0;31m'; C_YEL='\033[0;33m'; C_CYN='\033[0;36m'; C_END='\033[0m'
say(){ echo -e "${C_CYN}[MS]${C_END} $*"; }
ok(){  echo -e "${C_GREEN}  OK $*${C_END}"; }
warn(){ echo -e "${C_YEL}  WARN $*${C_END}"; }
fail(){ echo -e "${C_RED}  FAIL $*${C_END}"; }
MODE="${1:-preview}"
need_tools(){
  for t in git curl python3; do command -v "$t" >/dev/null || { fail "$t غير مثبت"; exit 1; }; done
  command -v jq >/dev/null 2>&1 || { say "تثبيت jq..."; pkg install -y jq >/dev/null 2>&1 || { fail "ثبّت jq: pkg install jq"; exit 1; }; }
  command -v unzip >/dev/null 2>&1 || { say "تثبيت unzip..."; pkg install -y unzip >/dev/null 2>&1 || { fail "ثبّت unzip: pkg install unzip"; exit 1; }; }
  mkdir -p "$LOG_DIR" "$SNAP_DIR"
}
load_token(){
  [ -f "$TOKEN_FILE" ] || { fail "لا يوجد توكن في $TOKEN_FILE"; echo "  echo 'ghp_XXX' > ~/.mirror_token && chmod 600 ~/.mirror_token"; exit 1; }
  TOKEN="$(tr -d '[:space:]' < "$TOKEN_FILE")"
  [ ${#TOKEN} -ge 20 ] || { fail "توكن غير صالح (أقصر من 20 حرفاً)"; exit 1; }
}
gh(){ curl -sS -X "${1:-GET}" -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" "$API${2}" ${3:+-d "$3"}; }
fetch_last_failure(){
  say "سحب أخطاء آخر تشغيل فاشل من الـ artifacts..."
  local run_id run_num
  run_id=$(gh GET "/actions/runs?branch=$BRANCH&status=failure&per_page=1" | jq -r '.workflow_runs[0].id // empty')
  [ -z "$run_id" ] && { warn "لا يوجد تشغيل فاشل"; return; }
  run_num=$(gh GET "/actions/runs/$run_id" | jq -r '.run_number')
  say "آخر فشل: run #$run_num"
  local aid
  aid=$(gh GET "/actions/runs/$run_id/artifacts" | jq -r '.artifacts[0].id // empty')
  if [ -n "$aid" ] && [ "$aid" != "null" ]; then
    rm -rf "$LOG_DIR/art"; mkdir -p "$LOG_DIR/art"
    curl -sSL -H "Authorization: token $TOKEN" "$API/actions/runs/$run_id/artifacts/$aid/zip" -o "$LOG_DIR/art/art.zip"
    (cd "$LOG_DIR/art" && unzip -oq art.zip 2>/dev/null)
    echo "── أخطاء dart analyze ──"
    grep -hE "error •|Error:" "$LOG_DIR/art"/*.log 2>/dev/null | head -60 || echo "  (لا أخطاء مطبوعة)"
    echo "────────────────────────"
    local af; af=$(ls "$LOG_DIR/art"/dart-analyze.log 2>/dev/null | head -1)
    [ -n "$af" ] && { echo "── ذيل dart-analyze.log ──"; tail -15 "$af"; }
  else
    warn "لا artifact — محاولة السجل الخام"
    curl -sSL -H "Authorization: token $TOKEN" "$API/actions/runs/$run_id/logs" -o "$LOG_DIR/raw_logs.zip"
    (cd "$LOG_DIR" && unzip -oq raw_logs.zip 2>/dev/null || true)
    grep -hE "error •|Error:" "$LOG_DIR"/* 2>/dev/null | head -60 || true
  fi
}
diff_vs_golden(){
  say "الملفات المتغيرة منذ آخر نجاح $GOLDEN:"
  git fetch -q origin "$BRANCH" 2>/dev/null || true
  if git cat-file -e "$GOLDEN^{commit}" 2>/dev/null; then
    git diff --stat "$GOLDEN" HEAD -- lib pubspec.yaml | tail -30
    echo "── كوميتات منذ النجاح ──"
    git log --oneline "$GOLDEN"..HEAD | head -15
  else
    warn "الكوميت الذهبي غير موجود محلياً"
  fi
}
scan_risky(){
  say "فحص أنماط خطرة في document_screen.dart:"
  local doc="$WORKDIR/lib/features/card1_translation/document_screen.dart"
  [ -f "$doc" ] || { warn "الملف غير موجود"; return; }
  echo "── WebView( (widget محذوف من webview_flutter >= 4.9) ──"
  grep -n "WebView(" "$doc" | head -10 || echo "  (لا يوجد — جيد)"
  echo "── FilePicker ──"
  grep -n "FilePicker" "$doc" | head -10 || echo "  (لا يوجد)"
  echo "── TextRecognizer/InputImage ──"
  grep -nE "TextRecognizer\(|InputImage\." "$doc" | head -10 || echo "  (لا يوجد)"
  echo "── إعلان tts ──"
  grep -nE "tts\s*=|TTSService" "$doc" | head -5 || echo "  (لا يوجد إعلان — خطأ محتمل)"
}
check_secrets(){
  say "فحص أسرار مكشوفة:"
  grep -rEn "AIza[0-9A-Za-z_-]{30,}|ghp_[0-9A-Za-z]{30,}" "$WORKDIR/lib" "$WORKDIR/assets" 2>/dev/null | head -5 || true
}
pin_golden_deps(){
  say "تثبيت إصدارات الأساس الذهبي (النجاح ce10b41a + حزم stage1) بلا bump عشوائي..."
  python3 - "$WORKDIR/pubspec.yaml" <<'PY'
import re, sys
p = sys.argv[1]
PIN = {
  'cupertino_icons': '^1.0.8',
  'provider': '^6.1.5+1',
  'http': '^1.6.0',
  'shared_preferences': '^2.5.5',
  'path_provider': '^2.1.6',
  'flutter_tts': '^4.2.5',
  'sqflite': '^2.4.3',
  'intl': '^0.20.2',
  'permission_handler': '^13.0.0',
  'speech_to_text': '^7.5.0-beta.1',
  'image_picker': '^1.2.3',
  'webview_flutter': '^4.10.0',
  'google_mlkit_text_recognition': '^0.13.0',
  'file_picker': '^11.0.3',
}
s = open(p, encoding='utf-8').read()
changed = []
for name, ver in PIN.items():
    m = re.search(r'^  %s:\s*([^\s#]+)' % re.escape(name), s, re.M)
    if m and m.group(1) != ver:
        s = s.replace(m.group(0), '  %s: %s' % (name, ver))
        changed.append('%s: %s -> %s' % (name, m.group(1), ver))
open(p, 'w', encoding='utf-8').write(s)
if changed:
    print('  مطبقة:')
    for c in changed: print('    ' + c)
else:
    print('  لا تغييرات — كل الإصدارات مطابقة للأساس الذهبي')
PY
}
apply_code_fixes(){
  say "تطبيق إصلاحات Dart الجراحية (ملفات متغيرة فقط)..."
  local changed fixed=0 f
  changed=$(git diff --name-only "$GOLDEN" HEAD -- lib 2>/dev/null || true)
  [ -z "$changed" ] && changed=$(find lib -name '*.dart')
  for f in $changed; do
    [ -f "$f" ] || continue
    if grep -q 'const TextStyle(' "$f" 2>/dev/null; then
      sed -i 's/const TextStyle(/TextStyle(/g' "$f"
      warn "أزلت const من TextStyle في $f"; fixed=$((fixed+1))
    fi
    if grep -q 'downloadedLanguages' "$f" 2>/dev/null; then
      sed -i 's/downloadedLanguages\.map(/downloadedLanguages.keys.map(/g' "$f"
      fixed=$((fixed+1))
    fi
    if grep -q 'pickBackground(' "$f" 2>/dev/null; then
      python3 - "$f" <<'PY'
import re, sys
p=sys.argv[1]; s=open(p,encoding='utf-8').read()
s2=re.sub(r'pickBackground\(\s*[^)]*\)','pickBackground()',s)
if s2!=s: open(p,'w',encoding='utf-8').write(s2)
PY
      fixed=$((fixed+1))
    fi
    if grep -q 'listenFor:\|pauseFor:' "$f" 2>/dev/null; then
      python3 - "$f" <<'PY'
import re, sys
p=sys.argv[1]; s=open(p,encoding='utf-8').read()
s2=re.sub(r',\s*(?:listenFor|pauseFor):\s*Duration\([^)]*\)','',s)
s2=re.sub(r',\s*(?:listenFor|pauseFor):\s*[^,)]+','',s2)
if s2!=s: open(p,'w',encoding='utf-8').write(s2)
PY
      fixed=$((fixed+1))
    fi
  done
  say "إجمالي الإصلاحات الآلية: $fixed"
}
snapshot(){
  local d="$SNAP_DIR/$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$d"
  cp -r "$WORKDIR/lib" "$d/lib" 2>/dev/null
  cp "$WORKDIR/pubspec.yaml" "$d/pubspec.yaml" 2>/dev/null
  echo "$d" > "$LOG_DIR/last_snapshot"
  ok "لقطة: $d"
}
restore_last(){
  local d; d=$(cat "$LOG_DIR/last_snapshot" 2>/dev/null || true)
  [ -z "$d" ] && { fail "لا لقطة"; exit 1; }
  cp -r "$d/lib/." "$WORKDIR/lib/" && cp "$d/pubspec.yaml" "$WORKDIR/pubspec.yaml"
  ok "استعادة من $d"
}
write_report(){
  local r="$WORKDIR/$REPORT"
  {
    echo "# تقرير الإصلاح — $(date '+%Y-%m-%d %H:%M')"
    echo "- آخر نجاح: \`$GOLDEN\` (run #855)"
    echo "- HEAD: \`$(git -C "$WORKDIR" rev-parse --short HEAD 2>/dev/null)\`"
    echo "## الإصدارات"
    grep -E '^  [a-z_]+:' "$WORKDIR/pubspec.yaml" | grep -v 'sdk:' || true
  } > "$r"
  ok "التقرير: $r"
}
push_and_watch(){
  say "الرفع إلى GitHub..."
  cd "$WORKDIR"
  git add -A
  if git diff --cached --quiet; then
    warn "لا تغييرات للرفع"
  else
    git commit -q -m "🦂 mega-repair v2 $(date +%Y-%m-%d_%H%M): تثبيت إصدارات ذهبية + إصلاحات جراحية" || true
    git push -q origin "$BRANCH" || { fail "فشل الرفع"; exit 1; }
    ok "تم الرفع"
  fi
  local want got run_id tries=0 st concl
  want=$(git rev-parse HEAD)
  while [ $tries -lt 8 ]; do
    sleep 5; tries=$((tries+1))
    run_id=$(gh GET "/actions/runs?branch=$BRANCH&per_page=1" | jq -r '.workflow_runs[0].id // empty')
    [ -z "$run_id" ] && continue
    got=$(gh GET "/actions/runs/$run_id" | jq -r '.head_sha')
    [ "$got" = "$want" ] && break
  done
  [ "$got" != "$want" ] && { warn "لم أجد تشغيلاً لهذا الرفع — افتح Actions"; exit 1; }
  say "مراقبة التشغيل #$(gh GET "/actions/runs/$run_id" | jq -r '.run_number') ..."
  tries=0
  while [ $tries -lt $((MAX_WAIT/POLL)) ]; do
    sleep "$POLL"; tries=$((tries+1))
    st=$(gh GET "/actions/runs/$run_id" | jq -r '.status')
    concl=$(gh GET "/actions/runs/$run_id" | jq -r '.conclusion')
    say "[$((tries*POLL))s] status=$st conclusion=${concl:-...}"
    [ "$st" = "completed" ] && break
  done
  if [ "$concl" = "success" ]; then
    ok "البناء نجح — https://github.com/$OWNER/$REPO/actions/runs/$run_id"
    return 0
  fi
  fail "البناء فشل — سحب الأخطاء..."
  local aid
  aid=$(gh GET "/actions/runs/$run_id/artifacts" | jq -r '.artifacts[0].id // empty')
  if [ -n "$aid" ] && [ "$aid" != "null" ]; then
    rm -rf "$LOG_DIR/art"; mkdir -p "$LOG_DIR/art"
    curl -sSL -H "Authorization: token $TOKEN" "$API/actions/runs/$run_id/artifacts/$aid/zip" -o "$LOG_DIR/art/art.zip"
    (cd "$LOG_DIR/art" && unzip -oq art.zip 2>/dev/null)
    echo "── أخطاء التحليل ──"
    grep -hE "error •|Error:" "$LOG_DIR/art"/*.log 2>/dev/null | head -80 || echo "  لا أخطاء في السجلات المرفوعة"
    local af; af=$(ls "$LOG_DIR/art"/dart-analyze.log 2>/dev/null | head -1)
    [ -n "$af" ] && tail -25 "$af"
  fi
  exit 1
}
main(){
  need_tools; load_token
  cd "$WORKDIR" || { fail "المجلد غير موجود: $WORKDIR"; exit 1; }
  git status --porcelain | head -3 | grep -q . && warn "تغييرات غير ملتزمة — ستُضمّن في الرفع"
  say "═══ 1) التشخيص ═══"
  fetch_last_failure; diff_vs_golden; scan_risky; check_secrets
  if [ "$MODE" = "preview" ]; then
    say "وضع المعاينة — انتهى بلا تعديلات. للتنفيذ: ./mirror_mega_repair.sh full"
    exit 0
  fi
  say "═══ 2) لقطة ═══"; snapshot
  say "═══ 3) تثبيت إصدارات الأساس الذهبي ═══"; pin_golden_deps
  say "═══ 4) إصلاحات الكود ═══"; apply_code_fixes
  say "═══ 5) التقرير ═══"; write_report
  say "═══ 6) الرفع والمراقبة ═══"; push_and_watch
}
main "$@"
