#!/usr/bin/env bash
# ============================================================
# mirror_mega_repair.sh — Mirror Scorpion v2
# إصلاح شامل + رفع تلقائي + مراقبة CI — بيئة Termux (وسيط تحرير)
#
# الاستخدام:
#   ./mirror_mega_repair.sh preview   # قراءة فقط: تشخيص + خطة (بدون تعديل)
#   ./mirror_mega_repair.sh full      # تشخيص → إصلاح → رفع → مراقبة حتى النتيجة
#
# المتطلبات: git, curl, jq, python3 (يُثبّت jq تلقائياً لو غائب)
# التوكن: يُقرأ من $HOME/.mirror_token (خارج الريبو — لا يُرفع أبداً)
# ============================================================
set -uo pipefail

# ---------- الإعدادات ----------
OWNER="magdymeko456-cell"
REPO="mirror_scorpion-mirror_scorpion_v2"
BRANCH="main"
GOLDEN="ce10b41aad091f58bf5bd9c42ead8bde9d2e2315"        # آخر نجاح على السطر الحالي
LEGACY_GOLDEN="669eb2a03e8dc441142be786bbe8bfb8bf74c2b6"  # المرجع الذهبي للشكل (تاريخ قديم)
TOKEN_FILE="${MIRROR_TOKEN_FILE:-$HOME/.mirror_token}"
WORKDIR="${MIRROR_WORKDIR:-$HOME/mirror_scorpion_translate_version_2}"
SNAP_DIR="$HOME/.mirror_snapshots"
REPORT="REPAIR_REPORT.md"
MAX_WAIT=1200   # 20 دقيقة
POLL=30         # ثانية
API="https://api.github.com/repos/$OWNER/$REPO"

C_GREEN='\033[0;32m'; C_RED='\033[0;31m'; C_YEL='\033[0;33m'; C_CYN='\033[0;36m'; C_END='\033[0m'
say(){ echo -e "${C_CYN}[MS]${C_END} $*"; }
ok(){  echo -e "${C_GREEN}  ✔ $*${C_END}"; }
warn(){ echo -e "${C_YEL}  ⚠ $*${C_END}"; }
fail(){ echo -e "${C_RED}  ✘ $*${C_END}"; }

MODE="${1:-preview}"

# ---------- فحص البيئة ----------
need_tools(){
  for t in git curl python3; do command -v "$t" >/dev/null || { fail "الأداة $t غير مثبتة"; exit 1; }; done
  command -v jq >/dev/null 2>&1 || { say "تثبيت jq..."; pkg install -y jq >/dev/null 2>&1 || { fail "ثبّت jq يدوياً: pkg install jq"; exit 1; }; }
}

# ---------- التوكن ----------
load_token(){
  if [ ! -f "$TOKEN_FILE" ]; then
    fail "ملف التوكن غير موجود: $TOKEN_FILE"
    echo "  أنشئه:  echo 'ghp_XXXX' > $TOKEN_FILE && chmod 600 $TOKEN_FILE"
    echo "  ⚠ لا تضع التوكن داخل الريبو (الريبو عام)."
    exit 1
  fi
  TOKEN="$(cat "$TOKEN_FILE" | tr -d '[:space:]')"
  [ ${#TOKEN} -lt 20 ] && { fail "توكن غير صالح"; exit 1; }
}

gh(){ # gh METHOD PATH [DATA]
  curl -sS -X "${1:-GET}" -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" \
    "$API${2}" ${3:+-d "$3"}
}

# ---------- P1: التشخيص ----------
fetch_last_failure_log(){
  say "سحب سجل آخر تشغيل فاشل..."
  local run_id
  run_id=$(gh GET "/actions/runs?branch=$BRANCH&status=failure&per_page=1" | jq -r '.workflow_runs[0].id // empty')
  [ -z "$run_id" ] && { warn "لا يوجد تشغيل فاشل سابق"; return; }
  local head_sha
  head_sha=$(gh GET "/actions/runs/$run_id" | jq -r '.head_sha')
  say "آخر فشل: run #$(gh GET "/actions/runs/$run_id" | jq -r '.run_number') على $head_sha"
  mkdir -p /tmp/ms_logs
  curl -sSL -H "Authorization: token $TOKEN" "$API/actions/runs/$run_id/logs" -o /tmp/ms_logs/logs.zip
  if file /tmp/ms_logs/logs.zip | grep -qi zip; then
    (cd /tmp/ms_logs && unzip -oq logs.zip 2>/dev/null)
    local ana
    ana=$(ls /tmp/ms_logs/*Dart* 2>/dev/null | head -1)
    if [ -n "$ana" ]; then
      echo "── أخطاء flutter analyze (آخر فشل) ──"
      grep -E "error •|Error:|Error \(" "$ana" | head -60 || true
      echo "──────────────────────────────────"
    fi
  else
    warn "تعذر تنزيل السجل (يحتاج صلاحيات admin على الريبو — وأنت المالك، تأكد من التوكن)"
  fi
}

diff_vs_golden(){
  say "مقارنة الملفات المتغيرة منذ آخر نجاح $GOLDEN ..."
  git fetch -q origin "$BRANCH" 2>/dev/null || true
  if git cat-file -e "$GOLDEN^{commit}" 2>/dev/null; then
    echo "── ملفات تغيرت منذ آخر نجاح ──"
    git diff --stat "$GOLDEN" HEAD -- lib pubspec.yaml | tail -40
    echo "── كوميتات منذ آخر نجاح ──"
    git log --oneline "$GOLDEN"..HEAD | head -20
  else
    warn "الكوميت الذهبي $GOLDEN غير موجود محلياً — جارٍ المحاولة بالجلب المباشر"
    git fetch -q origin "$GOLDEN" 2>/dev/null && ok "تم جلب الكوميت الذهبي" || warn "غير متاح (تاريخ أُعيدت تهيئته) — نعتمد على سجل الفشل"
  fi
}

# ---------- P2: تحديث الإصدارات (ديناميكياً من pub.dev) ----------
update_pubspec(){
  say "تحديث pubspec.yaml إلى أحدث الإصدارات المستقرة (pub.dev)..."
  python3 - "$WORKDIR/pubspec.yaml" <<'PY'
import json, re, sys, urllib.request
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
# نطاق الحزم بين dependencies و dev_dependencies
m = re.search(r'^dependencies:\s*\n(.*?)^dev_dependencies:', s, re.M | re.S)
if not m: print("لا يمكن تحديد قسم dependencies"); sys.exit(0)
block = m.group(1)
SKIP = {"flutter", "flutter_localizations", "dash_bubble_local"}
changes = []
for line in block.splitlines():
    mm = re.match(r'^  ([a-z0-9_]+):\s*([^\s#]+)', line)
    if not mm: continue
    name, cur = mm.group(1), mm.group(2)
    if name in SKIP or cur.startswith('path:'): continue
    try:
        req = urllib.request.Request(f"https://pub.dev/api/packages/{name}",
                                     headers={"User-Agent": "mirror-repair"})
        data = json.load(urllib.request.urlopen(req, timeout=15))
        latest = data.get("latest", {}).get("version", "")
        sdk = data.get("latest", {}).get("pubspec", {}).get("environment", {}).get("sdk", "")
        if not latest: continue
        new = f"^{latest}"
        # استثناء معروف: speech_to_text — الأحدث المستقر 7.4.0 (بيتا 7.5.0 تتطلب Dart ^3.12.0)
        if name == "speech_to_text":
            new = "^7.4.0"
        if cur != new:
            s = s.replace(f"  {name}: {cur}", f"  {name}: {new}")
            changes.append(f"  {name}: {cur} -> {new}   [sdk: {sdk}]")
    except Exception as e:
        print(f"  (تعذر الوصول لـ {name}: {e})")
open(p, 'w', encoding='utf-8').write(s)
if changes:
    print("── تحديثات الإصدارات المقترحة/المطبقة ──")
    print("\n".join(changes))
else:
    print("  لا تغييرات — جميع الإصدارات محدثة.")
PY
}

# ---------- P3: إصلاحات الكود الجراحية (fix-map) ----------
known_fixes(){
  say "تطبيق إصلاحات Dart المعروفة (فقط على الملفات المتغيرة)..."
  local changed
  changed=$(git diff --name-only "$GOLDEN" HEAD -- lib 2>/dev/null || find lib -name '*.dart')
  [ -z "$changed" ] && changed=$(find lib -name '*.dart')
  local fixed=0

  # 1) TextStyle مع shade داخل const — خطأ MaterialColor ليست const
  while read -r f; do
    if grep -q 'const TextStyle(' "$f" 2>/dev/null && grep -q 'shade' "$f"; then
      sed -i 's/const TextStyle(/TextStyle(/g' "$f"
      warn "أزلت const من TextStyle في $f (سبب فشل معروف)"
      fixed=$((fixed+1))
    fi
  done <<< "$changed"

  # 2) downloadedLanguages.map → .keys.map (كانت خريطة وليست قائمة)
  while read -r f; do
    if grep -q 'downloadedLanguages' "$f" 2>/dev/null; then
      sed -i 's/downloadedLanguages\.map(/downloadedLanguages.keys.map(/g' "$f"
      fixed=$((fixed+1))
    fi
  done <<< "$changed"

  # 3) pickBackground() بدون معاملات (توقيع الخدمة الحالي)
  while read -r f; do
    grep -q 'pickBackground(' "$f" 2>/dev/null || continue
    python3 - "$f" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s2 = re.sub(r'pickBackground\(\s*[^)]*\)', 'pickBackground()', s)
if s2 != s: open(p,'w',encoding='utf-8').write(s2); print(f"  أصلحت pickBackground() في {p}")
PY
  done <<< "$changed"

  # 4) speech_to_text: حذف معاملات listenFor/pauseFor المحذوفة من API الحديث
  while read -r f; do
    grep -q 'listenFor:\|pauseFor:' "$f" 2>/dev/null || continue
    python3 - "$f" <<'PY'
import re, sys
p = sys.argv[1]
s = open(p, encoding='utf-8').read()
s2 = re.sub(r',\s*(?:listenFor|pauseFor):\s*Duration\([^)]*\)', '', s)
s2 = re.sub(r',\s*(?:listenFor|pauseFor):\s*[^,)]+', '', s2)
if s2 != s: open(p,'w',encoding='utf-8').write(s2); print(f"  حذفت معاملات listenFor/pauseFor من {p}")
PY
  done <<< "$changed"

  # 5) كشف WebView القديم (widget) — يتطلب تحويلاً يدوياً إلى WebViewController
  local old_webview
  old_webview=$(grep -rln 'WebView(' "$WORKDIR/lib" --include='*.dart' 2>/dev/null || true)
  if [ -n "$old_webview" ]; then
    warn "وجدت WebView() القديم في: $old_webview"
    warn "  webview_flutter 4.x أزال الـ Widget — يجب التحويل إلى WebViewController (إصلاح يدوي موثق في التقرير)"
  fi

  say "إجمالي الإصلاحات الآلية المطبقة: $fixed"
}

# ---------- فحص أسرار مكشوفة ----------
check_secrets(){
  say "فحص أسرار مكشوفة في الكود (الريبو عام)..."
  grep -rEn "AIza[0-9A-Za-z_-]{30,}|ghp_[0-9A-Za-z]{30,}|sk-[A-Za-z0-9]{20,}" "$WORKDIR/lib" "$WORKDIR/assets" 2>/dev/null | head -10 || true
}

# ---------- لقطة استعادة ----------
snapshot(){
  local d="$SNAP_DIR/$(date +%Y%m%d_%H%M%S)"
  mkdir -p "$d"
  cp -r "$WORKDIR/lib" "$d/lib" 2>/dev/null
  cp "$WORKDIR/pubspec.yaml" "$d/pubspec.yaml" 2>/dev/null
  echo "$d" > /tmp/ms_last_snapshot
  ok "لقطة قبل التعديل: $d"
}
restore_last(){
  local d; d=$(cat /tmp/ms_last_snapshot 2>/dev/null || true)
  [ -z "$d" ] && { fail "لا توجد لقطة"; exit 1; }
  cp -r "$d/lib/." "$WORKDIR/lib/" && cp "$d/pubspec.yaml" "$WORKDIR/pubspec.yaml"
  ok "استُعيدت الحالة من $d"
}

# ---------- P4: الرفع + المراقبة ----------
push_and_watch(){
  say "الرفع إلى GitHub..."
  cd "$WORKDIR"
  git add -A
  if git diff --cached --quiet; then
    warn "لا تغييرات للرفع"
  else
    git commit -q -m "🦂 mega-repair $(date +%Y-%m-%d_%H%M): إصلاح شامل + تحديث إصدارات + تقرير" || true
    git push -q origin "$BRANCH" || { fail "فشل الرفع — تحقق من التوكن"; exit 1; }
    ok "تم الرفع"
  fi
  local head_sha run_id st concl tries=0
  head_sha=$(git rev-parse HEAD)
  sleep 5
  run_id=$(gh GET "/actions/runs?branch=$BRANCH&per_page=1" | jq -r '.workflow_runs[0].id // empty')
  [ -z "$run_id" ] && { fail "لم أجد التشغيل — افتح Actions يدوياً"; exit 1; }
  say "مراقبة التشغيل #$(gh GET "/actions/runs/$run_id" | jq -r '.run_number') ..."
  while [ $tries -lt $((MAX_WAIT/POLL)) ]; do
    sleep "$POLL"; tries=$((tries+1))
    st=$(gh GET "/actions/runs/$run_id" | jq -r '.status')
    concl=$(gh GET "/actions/runs/$run_id" | jq -r '.conclusion')
    say "[$((tries*POLL))s] status=$st conclusion=${concl:-...}"
    [ "$st" = "completed" ] && break
  done
  if [ "$concl" = "success" ]; then
    ok "البناء نجح ✅  — APK: https://github.com/$OWNER/$REPO/actions/runs/$run_id"
  else
    fail "البناء فشل ❌ — جارٍ سحب السجل..."
    curl -sSL -H "Authorization: token $TOKEN" "$API/actions/runs/$run_id/logs" -o /tmp/ms_logs/fail_logs.zip
    (cd /tmp/ms_logs && rm -rf fl && mkdir fl && cd fl && unzip -oq ../fail_logs.zip 2>/dev/null)
    grep -hE "error •|Error:" /tmp/ms_logs/fl/*Dart* 2>/dev/null | head -80 || true
    echo "── السجل الكامل: /tmp/ms_logs/fl ──"
    exit 1
  fi
}

# ---------- التقرير ----------
write_report(){
  local r="$WORKDIR/$REPORT"
  {
    echo "# تقرير الإصلاح الشامل — $(date '+%Y-%m-%d %H:%M')"
    echo ""
    echo "## الحالة"
    echo "- آخر نجاح على السطر الحالي: \`$GOLDEN\` (run #855)"
    echo "- المرجع الذهبي للشكل: \`$LEGACY_GOLDEN\` (38.6MB — تاريخ قديم، بدون سلف مشترك)"
    echo "- HEAD: \`$(git -C "$WORKDIR" rev-parse --short HEAD 2>/dev/null)\`"
    echo ""
    echo "## الإصدارات"
    grep -E '^  [a-z_]+:' "$WORKDIR/pubspec.yaml" | grep -v 'sdk:' || true
    echo ""
    echo "## ملاحظات"
    echo "- لا تُمس android/ ولا workflow (أساس النجاح)."
    echo "- فجوات ميزات موثقة: فقاعة عائمة بلا أداة، 4 أصوات ناقصة، نسخ بلا توقيع، قصص ناقصة، محرر حوار صغير."
  } > "$r"
  ok "التقرير: $r"
}

# ============================== التنفيذ ==============================
main(){
  need_tools
  load_token
  cd "$WORKDIR" || { fail "المجلد غير موجود: $WORKDIR"; exit 1; }
  git status --porcelain | head -5 | grep -q . && { warn "يوجد تغييرات غير ملتزمة — يُنصح بالالتزام أو الاستعادة أولاً"; }

  echo ""
  say "══════════ المرحلة 1: التشخيص ══════════"
  fetch_last_failure_log
  diff_vs_golden
  check_secrets

  if [ "$MODE" = "preview" ]; then
    say "══════════ وضع المعاينة — لا تعديلات ══════════"
    say "خطة الإصلاح المقترحة: تحديث إصدارات pubspec + fix-map على lib/"
    say "للتطبيق الكامل:  ./mirror_mega_repair.sh full"
    exit 0
  fi

  echo ""
  say "══════════ المرحلة 2: لقطة استعادة ══════════"
  snapshot

  echo ""
  say "══════════ المرحلة 3: تحديث الإصدارات ══════════"
  update_pubspec

  echo ""
  say "══════════ المرحلة 4: إصلاحات الكود ══════════"
  known_fixes

  echo ""
  say "══════════ المرحلة 5: التقرير ══════════"
  write_report

  echo ""
  say "══════════ المرحلة 6: الرفع والمراقبة ══════════"
  push_and_watch
}

main "$@"
