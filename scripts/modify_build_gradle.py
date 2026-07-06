# scripts/modify_build_gradle.py
import os

FILE_PATH = "android/app/build.gradle"

print("🤖 [أدهم]: لقيت اللغز يا تامر! بنعدل minSdk لـ 24 فوراً...")

with open(FILE_PATH, 'r', encoding='utf-8') as file:
    content = file.read()

# استبدال الصيغة الحديثة بالملي
new_content = content.replace("minSdk = 21", "minSdk = 24")

with open(FILE_PATH, 'w', encoding='utf-8') as file:
    file.write(new_content)

print("✅ تم حذف الإعداد القديم وحفظ الملف الجديد بـ minSdk = 24!")
