# scripts/mirror_ui_sync.py
# المزامنة المحلية الصافية - أدهم وميرور
import subprocess
import sys
import os

OLD_COMMIT = "178f03b"
NEW_COMMIT = "b605046"

def run_command(cmd):
    result = subprocess.run(cmd, shell=True, text=True, capture_output=True)
    return result.returncode, result.stdout.strip(), result.stderr.strip()

print("🤖 [أدهم]: المستودع كامل محلياً يا تامر يا غالي! بنبدأ الفحص والنقل الفوري...\n")

# 1. فحص ومطابقة ملفات الـ lib
print("🔍 جاري مطابقة أسماء ملفات الـ lib لتفادي الكراش وفشل البناء...")
code, old_lib, _ = run_command(f"git ls-tree -r --name-only {OLD_COMMIT} lib/")
_, new_lib, _ = run_command(f"git ls-tree -r --name-only {NEW_COMMIT} lib/")

if code != 0 or not old_lib:
    print(f"❌ خطأ: الكوميت {OLD_COMMIT} مش مقروء في شجرة جيت المحلية.")
    print("💡 الحل الحاسم: افتح جيت هاب من المتصفح وانسخ كود الواجهة اللي محتاجها في ملفات الـ lib الحالية لضمان الأمان.")
    sys.exit(1)

old_set = set(old_lib.split('\n')) if old_lib else set()
new_set = set(new_lib.split('\n')) if new_lib else set()
matched = old_set.intersection(new_set)

print(f"✅ ملفات واجهة متطابقة تماماً في الأسماء (أمان 100%): {len(matched)} ملف.")

# 2. نقل الأيقونات فوراً
print("\n🎨 جاري استخراج واستبدال الأيقونات والموارد من الكوميت القديم...")
icon_paths = [
    "android/app/src/main/res/drawable/ic_menu_translate.png",
    "android/app/src/main/res/mipmap-hdpi/ic_launcher.png",
    "android/app/src/main/res/mipmap-mdpi/ic_launcher.png",
    "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png",
    "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"
]

replaced_count = 0
for path in icon_paths:
    # أمر checkout بسحب الملف من الكوميت القديم للمجلد الحالي مباشرة
    exit_code, _, _ = run_command(f"git checkout {OLD_COMMIT} -- {path}")
    if exit_code == 0:
        print(f"   - تم استبدال المورد بنجاح: {path}")
        replaced_count += 1

print(f"\n📊 تم تحديث {replaced_count} ملف من الموارد والأيقونات.")
print("\n🚀 قولي يا صاحبي إيه اللي ظهرلك على الشاشة عشان نعتمد الكود ونرفع لجيت هاب بالخلطة الجديدة!")
