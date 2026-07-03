import sys
import os
import re
import glob

# ابحث عن android/app/build.gradle
base_dir = sys.argv[1] if len(sys.argv) > 1 else '.'
patterns = [
    os.path.join(base_dir, 'android/app/build.gradle*'),
    os.path.join(base_dir, 'android/app/build.gradle.kts'),
]
files = []
for p in patterns:
    files.extend(glob.glob(p))

if not files:
    print("No build.gradle files found, creating one...")
    # إنشاء build.gradle إذا لم يكن موجوداً
    os.makedirs(os.path.join(base_dir, 'android/app'), exist_ok=True)
    files = [os.path.join(base_dir, 'android/app/build.gradle.kts')]

for filepath in files:
    if not os.path.exists(filepath):
        continue
    
    print(f"Patching: {filepath}")
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    # 1. إصلاح compileSdk → 36
    content = re.sub(r'compileSdk\s*=\s*\d+', 'compileSdk = 36', content)
    content = re.sub(r'compileSdk\s+\d+', 'compileSdk = 36', content)
    
    # 2. إصلاح targetSdk → 36
    content = re.sub(r'targetSdk\s*=\s*\d+', 'targetSdk = 36', content)
    content = re.sub(r'targetSdk\s+\d+', 'targetSdk = 36', content)
    
    # 3. إصلاح minSdk → 21
    content = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 21', content)
    content = re.sub(r'minSdk\s*=\s*\d+', 'minSdk = 21', content)
    content = re.sub(r'minSdk\s+\d+', 'minSdk = 21', content)
    
    # 4. NDK
    if 'ndkVersion' not in content:
        content = content.replace('android {', 'android {\n    ndkVersion = "27.0.12077973"')
    else:
        content = re.sub(r'ndkVersion\s*=\s*"[^"]*"', 'ndkVersion = "27.0.12077973"', content)
        content = re.sub(r'ndkVersion\s+"[^"]*"', 'ndkVersion "27.0.12077973"', content)
    
    # 5. namespace (مطلوب لـ AGP 8+)
    if 'namespace' not in content:
        content = content.replace(
            'android {',
            'android {\n    namespace = "com.mirror.scorpion.v2"'
        )
    
    # 6. استبدال kotlinOptions → jvmTarget
    if 'kotlinOptions' in content:
        content = re.sub(
            r'kotlinOptions\s*\{[^}]*\}',
            'kotlinOptions {\n        jvmTarget = "17"\n    }',
            content
        )
    
    # 7. إزالة ==
    content = re.sub(r'(\w+)\s*==\s*(\d+)', r'\1 = \2', content)
    
    with open(filepath, 'w') as f:
        f.write(content)
    
    print(f"✓ Patched: {filepath}")
    print("  - compileSdk: 36")
    print("  - targetSdk: 36")
    print("  - minSdk: 21")
    print("  - ndkVersion: 27.0.12077973")
    print("  - namespace: com.mirror.scorpion.v2")

# إنشاء proguard-rules.pro
proguard_path = os.path.join(base_dir, 'android/app/proguard-rules.pro')
with open(proguard_path, 'w') as f:
    f.write('''# ML Kit rules
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**
-keep class kotlin.** { *; }
-dontwarn kotlin.**
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-ignorewarnings
-optimizationpasses 5
-dontusemixedcaseclassnames
''')
print(f"✓ Created proguard-rules.pro")
