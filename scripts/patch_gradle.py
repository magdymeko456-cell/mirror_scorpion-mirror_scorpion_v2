import sys
import os
import re

filepath = sys.argv[1] if len(sys.argv) > 1 else 'android/app/build.gradle.kts'

if not os.path.exists(filepath):
    print(f"File not found: {filepath}")
    sys.exit(0)

with open(filepath, 'r') as f:
    content = f.read()

# 1. Patch minSdk
content = content.replace('minSdk = flutter.minSdkVersion', 'minSdk = 21')

# 2. Fix compileSdk and targetSdk syntax for Kotlin DSL
# Using 36 as requested by the latest plugins
content = re.sub(r'compileSdk\s+\d+', 'compileSdk = 36', content)
content = re.sub(r'targetSdk\s+\d+', 'targetSdk = 35', content)
content = re.sub(r'compileSdkVersion\s+\d+', 'compileSdkVersion = 36', content)
content = re.sub(r'targetSdkVersion\s+\d+', 'targetSdkVersion = 35', content)

# 3. Replace deprecated kotlinOptions with compilerOptions - FIX THIS FIRST
# Match the entire kotlinOptions block with all variations
old_patterns = [
    r'kotlinOptions\s*\{[^}]*jvmTarget\s*=\s*["\']?[\d.]+["\']?[^}]*\}',
    r'kotlinOptions\s*\{[^}]*\}',
]

for pattern in old_patterns:
    if re.search(pattern, content, re.DOTALL):
        content = re.sub(
            pattern,
            '''compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_1_8
    }''',
            content,
            flags=re.DOTALL
        )
        print("✓ Replaced deprecated kotlinOptions with compilerOptions")
        break

# 4. Force isMinifyEnabled to false wherever it appears
content = content.replace('isMinifyEnabled = true', 'isMinifyEnabled = false')

# 5. If no isMinifyEnabled found at all, add it
if 'isMinifyEnabled' not in content:
    content = content.replace(
        'signingConfig = signingConfigs.debug',
        'signingConfig = signingConfigs.debug\n            isMinifyEnabled = false'
    )

# 6. Add proguardFiles with ML Kit keep rules
if 'proguardFiles' not in content:
    content = content.replace(
        'isMinifyEnabled = false',
        'isMinifyEnabled = false\n            proguardFiles(\n                getDefaultProguardFile("proguard-android-optimize.txt"),\n                "proguard-rules.pro"\n            )'
    )

# 7. Add shrinkResources = false
content = content.replace('shrinkResources = true', 'shrinkResources = false')
if 'shrinkResources' not in content:
    content = content.replace(
        'isMinifyEnabled = false',
        'isMinifyEnabled = false\n            shrinkResources = false'
    )

# 8. Remove any double equals (==) and replace with single equals (=)
content = re.sub(r'(\w+)\s*==\s*(\d+|"[^"]*")', r'\1 = \2', content)

# 9. Ensure proper Kotlin syntax for assignments
content = re.sub(r'(\w+)\s+(\d+)(?!\w)', r'\1 = \2', content)

with open(filepath, 'w') as f:
    f.write(content)

print(f"✓ Patched {filepath}")

# Create comprehensive proguard rules for ML Kit and other libraries
proguard_path = os.path.join(os.path.dirname(filepath), 'proguard-rules.pro')
with open(proguard_path, 'w') as f:
    f.write('''# ML Kit rules
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# Firebase rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Google Play Services rules
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# Kotlin stdlib rules
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }
-dontwarn kotlin.**
-dontwarn kotlinx.**

# Flutter rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# General rules
-ignorewarnings
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# Keep line numbers for debugging
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile
''')

print(f"✓ Created comprehensive {proguard_path}")
