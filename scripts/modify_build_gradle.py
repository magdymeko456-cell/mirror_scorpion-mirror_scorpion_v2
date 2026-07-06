# scripts/modify_build_gradle.py
import os

# هنحدد المسار الداخلي الصح للمشروع
FILE_PATH = "android/app/build.gradle"

print("🤖 [أدهم]: بدأنا البحث الذكي عن الملف الداخلي المظبوط للتعديل...")

if not os.path.exists(FILE_PATH):
    print(f"❌ خطأ: مش لاقي الملف جوه {FILE_PATH}!")
    # فحص احتياطي لو المسار مختلف سنة
    if os.path.exists("android/build.gradle"):
        print("⚠️ أنا لقيت الملف الخارجي (30 سطر)، بس ده مش اللي فيه minSdkVersion. لازم نعدل الداخلي.")
    exit(1)

# 1. قراءة الملف الداخلي بالكامل
with open(FILE_PATH, 'r', encoding='utf-8') as file:
    lines = file.readlines()

print(f"📖 تم قراءة الملف الصح بنجاح! إجمالي السطور: {len(lines)} سطر.")

new_lines = []
modified = False
old_line_content = ""
new_line_content = ""

# 2. المرور على السطور وتعديل minSdkVersion
for line in lines:
    stripped_line = line.strip()
    
    # فحص السطر سواء مكتوبSdkVersion أو flutter.minSdkVersion
    if ("minSdkVersion" in stripped_line) and not stripped_line.startswith("//"):
        # لو السطر فيه القيمة الافتراضية ل فلاتر أو أي رقم قديم
        old_line_content = line.replace('\n', '')
        leading_spaces = line[:line.find("minSdkVersion")]
        
        # التعديل الصريح لـ 24
        line = f"{leading_spaces}minSdkVersion 24\n"
        new_line_content = line.replace('\n', '')
        modified = True
        
    new_lines.append(line)

# 3. حفظ وكتابة الملف الجديد ومسح القديم في صمت
if modified:
    print(f"\n🎯 لقيت السطر المستهدف وعدلته:")
    print(f"   ❌ القديم: {old_line_content}")
    print(f"   ✨ الجديد: {new_line_content}")
    
    with open(FILE_PATH, 'w', encoding='utf-8') as file:
        file.writelines(new_lines)
        
    print("\n💾 تم حفظ التعديلات الجديدة بنجاح في ملف التطبيق الداخلي!")
else:
    print("\n⚠️ تنبيه: ملقيتش السطر جوه الملف الداخلي برضه، قولي السطور مكتوبة إزاي عندك.")

print("\n🔍 شغل السكربت تاني دلوقتي يا تامر ووريني النتيجة!")
