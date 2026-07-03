#!/usr/bin/env python3
"""إصلاح speech_to_text build.gradle — يبحث عن الملف ويصححه سطراً بسطر"""
import subprocess, os, re

# البحث عن الملف
result = subprocess.run(
    ["find", os.path.expanduser("~/.pub-cache"), "-name", "build.gradle",
     "-path", "*/speech_to_text*/android/*", "-type", "f"],
    capture_output=True, text=True
)

files = [f.strip() for f in result.stdout.strip().split('\n') if f.strip()]
print(f"وجد {len(files)} ملفات speech_to_text build.gradle")

for filepath in files:
    if not os.path.exists(filepath):
        continue
    print(f"\n🔧 تصحيح: {filepath}")
    
    with open(filepath, 'r') as f:
        lines = f.readlines()
    
    new_lines = []
    skip_kotlin = False
    modified = False
    
    for line in lines:
        # رصد بداية kotlin block
        if re.match(r'^\s*kotlin\s*\{', line):
            skip_kotlin = True
            modified = True
            print(f"  - إزالة kotlin block (يبدأ عند السطر: {line.rstrip()})")
            continue
        
        # رصد نهاية block
        if skip_kotlin and re.match(r'^\s*\}', line):
            skip_kotlin = False
            print(f"  - انتهاء kotlin block")
            continue
        
        # تجاهل كل شيء داخل kotlin block
        if skip_kotlin:
            continue
        
        # إصلاح compileSdk
        if 'compileSdk = flutter.compileSdkVersion' in line:
            line = line.replace('compileSdk = flutter.compileSdkVersion', 'compileSdk 36')
            modified = True
            print("  - compileSdk → compileSdk 36")
        
        # إصلاح ndkVersion
        if 'ndkVersion = flutter.ndkVersion' in line:
            line = line.replace('ndkVersion = flutter.ndkVersion', 'ndkVersion "27.0.12077973"')
            modified = True
            print("  - ndkVersion → 27.0.12077973")
        
        new_lines.append(line)
    
    if modified:
        with open(filepath, 'w') as f:
            f.writelines(new_lines)
        print(f"✅ تم التصحيح: {filepath}")
        # عرض النتيجة
        print("--- الملف بعد التصحيح ---")
        with open(filepath, 'r') as f:
            print(f.read())
    else:
        print(f"⚠️ لم يتم تعديل {filepath}")

print("\n🎉 انتهى")
