import sys
import os

base_dir = sys.argv[1] if len(sys.argv) > 1 else '.'
manifest_path = os.path.join(base_dir, 'android/app/src/main/AndroidManifest.xml')

if not os.path.exists(manifest_path):
    print(f"Manifest not found: {manifest_path}")
    sys.exit(0)

with open(manifest_path, 'r') as f:
    content = f.read()

# إزالة package من manifest (AGP 8+ يتطلب namespace في build.gradle)
content = content.replace('package="com.mirror.scorpion.v2"', '')
content = content.replace('package="com.example.mirror_scorpion_translate"', '')

# التأكد من وجود كل التصاريح المطلوبة
required_permissions = [
    'android.permission.INTERNET',
    'android.permission.RECORD_AUDIO',
    'android.permission.SYSTEM_ALERT_WINDOW',
    'android.permission.FOREGROUND_SERVICE',
    'android.permission.FOREGROUND_SERVICE_DATA_SYNC',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.WRITE_EXTERNAL_STORAGE',
    'android.permission.CAMERA',
    'android.permission.POST_NOTIFICATIONS',
    'android.permission.ACCESS_NETWORK_STATE',
]

for perm in required_permissions:
    if perm not in content:
        # أضفها بعد أول <uses-permission> موجودة
        insert_point = content.find('<uses-permission')
        if insert_point > 0:
            next_tag = content.find('>', insert_point)
            content = content[:next_tag+1] + f'\n    <uses-permission android:name="{perm}"/>' + content[next_tag+1:]

# إضافة foreground service type
if 'android:foregroundServiceType="dataSync"' not in content:
    content = content.replace(
        'android:exported="false"',
        'android:exported="false"\n            android:foregroundServiceType="dataSync"'
    )

with open(manifest_path, 'w') as f:
    f.write(content)

print(f"✓ Manifest patched: {manifest_path}")
