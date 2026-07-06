# scripts/fix_properties.py
import os

FILE_PATH = "android/local.properties"

print("🤖 [أدهم]: بنعدل ملف الخصائص عشان نرفع الـ SDK لـ 24 على نضافة...")

if not os.path.exists(FILE_PATH):
    lines = []
else:
    with open(FILE_PATH, 'r', encoding='utf-8') as file:
        lines = file.readlines()

new_lines = []
found = False

for line in lines:
    if line.startswith("flutter.minSdkVersion"):
        line = "flutter.minSdkVersion=24\n"
        found = True
    new_lines.append(line)

if not found:
    new_lines.append("flutter.minSdkVersion=24\n")

with open(FILE_PATH, 'w', encoding='utf-8') as file:
    file.writelines(new_lines)

print("✅ تم تعديل وحفظ local.properties بنجاح!")
