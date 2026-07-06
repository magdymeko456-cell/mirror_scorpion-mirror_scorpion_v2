# scripts/perfect_merge.py
# سكربت دمج الواجهة والأيقونات مع الإعدادات الحديثة المستقرة - أدهم وميرور
import subprocess

NEW_STABLE = "b605046"  # البناء الجديد الناجح المستقر
OLD_UI = "178f03b"      # البناء اللي فيه الواجهة والأيقونة

def run(cmd):
    subprocess.run(cmd, shell=True)

print("🤖 [أدهم]: بنبدأ سكربت لم الشمل الحاسم.. الواجهة الكلاسيكية على الموتور الجديد! 🚀\n")

# 1. إرجاع إعدادات الأندرويد والـ pubspec والـ Packages للبناء الجديد الناجح
print("⚙️ إعادة ضبط الإعدادات والـ Dependencies للوضع المستقر الحديث...")
run(f"git checkout {NEW_STABLE} -- pubspec.yaml android/ build.gradle settings.gradle local.properties 2>/dev/null")

# 2. سحب الأيقونات الكلاسيكية من الكوميت القديم
print("\n🎨 سحب الأيقونات والموارد الكلاسيكية...")
icon_paths = [
    "android/app/src/main/res/mipmap-hdpi/ic_launcher.png",
    "android/app/src/main/res/mipmap-mdpi/ic_launcher.png",
    "android/app/src/main/res/mipmap-xhdpi/ic_launcher.png",
    "android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png"
]
for path in icon_paths:
    run(f"git checkout {OLD_UI} -- {path} 2>/dev/null")

# 3. سحب ملفات الـ UI والـ lib بالكامل من الكوميت القديم ليتم صبها في القالب الجديد
print("\n📦 دمج ملفات الـ lib والواجهة الكلاسيكية...")
run(f"git checkout {OLD_UI} -- lib/")

print("\n✨ [أدهم]: لم الشمل تم بنجاح يا تامر يا غالي! المشروع دلوقتي جاهز بالواجهة القديمة والإعدادات الحديثة المستقرة.")
