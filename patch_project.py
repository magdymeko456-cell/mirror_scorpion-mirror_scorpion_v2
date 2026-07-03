#!/usr/bin/env python3
import os
import re
import subprocess

def patch_gradle():
    android_dir = "android"
    if not os.path.exists(android_dir):
        print("⚠️ android directory not found")
        return
    
    # Patch app/build.gradle
    app_build = os.path.join(android_dir, "app", "build.gradle")
    if os.path.exists(app_build):
        with open(app_build, "r") as f:
            content = f.read()
        
        # Ensure compileSdk 34
        content = re.sub(r'compileSdk\s+\d+', 'compileSdk 34', content)
        content = re.sub(r'minSdk\s+\d+', 'minSdk 21', content)
        content = re.sub(r'targetSdk\s+\d+', 'targetSdk 34', content)
        
        with open(app_build, "w") as f:
            f.write(content)
        print("✅ app/build.gradle patched")
    
    # Patch android/build.gradle
    root_build = os.path.join(android_dir, "build.gradle")
    if os.path.exists(root_build):
        with open(root_build, "r") as f:
            content = f.read()
        
        if "agp" in content or "android.gradle" in content:
            content = re.sub(
                r'com\.android\.tools\.build:gradle:[\d\.]+',
                'com.android.tools.build:gradle:8.1.4',
                content
            )
        else:
            content = content.replace(
                'dependencies {',
                'dependencies {\n        classpath "com.android.tools.build:gradle:8.1.4"'
            )
        
        with open(root_build, "w") as f:
            f.write(content)
        print("✅ android/build.gradle patched")

def patch_manifest():
    manifest_path = "android/app/src/main/AndroidManifest.xml"
    if not os.path.exists(manifest_path):
        print("⚠️ AndroidManifest not found")
        return
    
    with open(manifest_path, "r") as f:
        content = f.read()
    
    # Add required permissions
    perms = [
        '<uses-permission android:name="android.permission.INTERNET"/>',
        '<uses-permission android:name="android.permission.RECORD_AUDIO"/>',
        '<uses-permission android:name="android.permission.CAMERA"/>',
        '<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>',
        '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>',
        '<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>',
        '<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>',
        '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>',
    ]
    
    for perm in perms:
        if perm not in content:
            content = content.replace(
                '<uses-permission android:name="android.permission.INTERNET"/>',
                perm + '\n    ' + '<uses-permission android:name="android.permission.INTERNET"/>'
            )
            break
    
    with open(manifest_path, "w") as f:
        f.write(content)
    print("✅ AndroidManifest.xml patched")

def patch_dash_bubble():
    bubble_dir = "packages/dash_bubble_local/android"
    if not os.path.exists(bubble_dir):
        print("⚠️ dash_bubble_local android dir not found")
        return
    
    for root, dirs, files in os.walk(bubble_dir):
        for f in files:
            if f == "build.gradle":
                path = os.path.join(root, f)
                with open(path, "r") as fh:
                    content = fh.read()
                
                content = re.sub(r'compileSdk\s+\d+', 'compileSdk 34', content)
                
                # Add kotlin if missing
                if "kotlin" not in content and "ext.kotlin_version" not in content:
                    content = content.replace(
                        'buildscript {',
                        'buildscript {\n    ext.kotlin_version = "1.9.22"'
                    )
                    content = content.replace(
                        "classpath 'com.android.tools.build",
                        "classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version'\n        classpath 'com.android.tools.build",
                        content
                    )
                
                with open(path, "w") as fh:
                    fh.write(content)
                print(f"✅ patched {path}")

if __name__ == "__main__":
    print("=== Mirror Scorpion Build Patcher ===")
    patch_gradle()
    patch_manifest()
    patch_dash_bubble()
    print("=== All patches applied ===")
