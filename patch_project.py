#!/usr/bin/env python3
import os, re

def main():
    print("🛠️ Mirror Scorpion Patcher V7 - Android v2 Embedding Fix...")
    
    android_dir = "android"
    if not os.path.exists(android_dir):
        print("❌ No android directory found. Run setup_android.sh first.")
        return

    # 1. gradle.properties
    with open("android/gradle.properties", "w") as f:
        f.write("""org.gradle.jvmargs=-Xmx4G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
android.defaults.buildfeatures.buildconfig=true
""")
    print("   ✅ gradle.properties")
    
    # 2. Fix AndroidManifest.xml
    manifest_path = "android/app/src/main/AndroidManifest.xml"
    if os.path.exists(manifest_path):
        with open(manifest_path, "r") as f:
            c = f.read()
        
        # Fix FlutterApplication
        c = c.replace(
            'android:name="io.flutter.app.FlutterApplication"',
            'android:name="${applicationName}"'
        )
        
        # Fix MainActivity with all configChanges
        old_activity = '.MainActivity"'
        new_activity = '.MainActivity"\n            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"\n            android:hardwareAccelerated="true"\n            android:windowSoftInputMode="adjustResize"'
        if old_activity in c:
            c = c.replace(old_activity, new_activity)
        
        # Add permissions
        perms = [
            '<uses-permission android:name="android.permission.INTERNET"/>',
            '<uses-permission android:name="android.permission.CAMERA"/>',
            '<uses-permission android:name="android.permission.RECORD_AUDIO"/>',
            '<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>',
            '<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>',
            '<uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>',
            '<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>',
            '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>',
        ]
        first_perm_tag = '<uses-permission'
        for perm in perms:
            if perm not in c:
                if first_perm_tag in c:
                    c = c.replace(first_perm_tag, perm + '\n    ' + first_perm_tag, 1)
                else:
                    c = c.replace('<application', '    ' + perm + '\n    <application', 1)
        
        with open(manifest_path, "w") as f:
            f.write(c)
        print("   ✅ AndroidManifest.xml")
    
    # 3. Fix app/build.gradle or build.gradle.kts
    for gradle_file in ["android/app/build.gradle", "android/app/build.gradle.kts"]:
        if os.path.exists(gradle_file):
            with open(gradle_file, "r") as f:
                c = f.read()
            
            c = re.sub(r'compileSdk\s*=\s*\d+', 'compileSdk = 35', c)
            c = re.sub(r'compileSdkVersion\s*\d+', 'compileSdkVersion = 35', c)
            c = re.sub(r'targetSdk\s*=\s*\d+', 'targetSdk = 35', c)
            c = re.sub(r'targetSdkVersion\s*\d+', 'targetSdkVersion = 35', c)
            c = re.sub(r'minSdk\s*=\s*\d+', 'minSdk = 21', c)
            c = re.sub(r'minSdkVersion\s*\d+', 'minSdkVersion = 21', c)
            
            if 'namespace' not in c:
                c = re.sub(r'android\s*\{', 'android {\n    namespace = "com.tetocollctionway.mirror_scorpion_v2"', c)
            
            c = re.sub(r'ndkVersion.*\n', '', c)
            c = re.sub(r'(minifyEnabled|shrinkResources|isMinifyEnabled)\s*=\s*true', '', c)
            c = re.sub(r'(minifyEnabled|shrinkResources)\s+true', '', c)
            
            with open(gradle_file, "w") as f:
                f.write(c)
            print(f"   ✅ {gradle_file}")
    
    # 4. root build.gradle
    root_gradle = "android/build.gradle"
    if os.path.exists(root_gradle):
        with open(root_gradle, "r") as f:
            c = f.read()
        
        fix_block = """
subprojects {
    afterEvaluate { project ->
        if (project.hasProperty("android") && project.android.namespace == null) {
            project.android.namespace = "com.tetocollctionway." + project.name
        }
    }
}
"""
        if "afterEvaluate" not in c:
            c += fix_block
        
        with open(root_gradle, "w") as f:
            f.write(c)
        print("   ✅ root build.gradle")
    
    print("✅✅✅ Patcher V7 complete!")
    
if __name__ == "__main__":
    main()
