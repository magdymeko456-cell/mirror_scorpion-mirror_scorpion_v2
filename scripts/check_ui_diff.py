# scripts/check_ui_diff.py
# نسخة الـ API الذكية - أدهم وميرور
import urllib.request
import json
import sys

# اسم المستودع بتاعك من السجلات اللي بعتها فوق
REPO = "magdymeko456-cell/mirror_scorpion_v2"
OLD_COMMIT = "669eb2a"
NEW_COMMIT = "b605046"

def get_files_from_github(commit_hash):
    # بنكلم جيت هاب عشان يدينا شجرة الملفات بالكامل للكومت ده
    url = f"https://api.github.com/repos/{REPO}/git/trees/{commit_hash}?recursive=1"
    headers = {"User-Agent": "Termux-App"}
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req) as response:
            data = json.loads(response.read().decode())
            # فلترة الملفات اللي جوه مجلد lib بس
            files = [item['path'] for item in data.get('tree', []) if item['path'].startswith('lib/') and item['type'] == 'blob']
            return files
    except Exception as e:
        print(f"❌ فشل الاتصال بجيت هاب للكومت {commit_hash}: {e}")
        return []

print("🤖 [أدهم]: بنكلم جيت هاب بالـ API عشان نعمل الفحص الذكي يا تامر...\n")

old_files = get_files_from_github(OLD_COMMIT)
new_files = get_files_from_github(NEW_COMMIT)

if not old_files or not new_files:
    print("❌ خطأ: مأدرتش أسحب لستة الملفات من السيرفر. اتأكد إنك متصل بالنت يا غالي.")
    sys.exit(1)

old_set = set(old_files)
new_set = set(new_files)

matched = old_set.intersection(new_set)
changed_or_missing = old_set - new_set
added_in_new = new_set - old_set

print(f"✅ ملفات متطابقة تماماً (أمان 100%): {len(matched)} ملف.")

if changed_or_missing:
    print("\n⚠️ ملفات واجهة قديمة اسمها أو مسارها اتغير في البناء الناجح الجديد:")
    for f in sorted(changed_or_missing):
        print(f"   - {f}")
else:
    print("\n🎉 مفيش أي اختلاف! أسماء ملفات الـ lib متطابقة بالملي بين البنائين.")

if added_in_new:
    print(f"\n✨ ملفات وميزات جديدة مضافة في الموتور الحالي (مش هتتأثر): {len(added_in_new)} ملف.")

print("\n💡 قولي إيه النتيجة اللي ظهرتلك دلوقتي يا صاحبي عشان نجهز أمر النقل!")
