import sys, os

manifest_path = sys.argv[1] if len(sys.argv) > 1 else 'android/app/src/main/AndroidManifest.xml'

if not os.path.exists(manifest_path):
    print(f"Skipping: {manifest_path} not found")
    sys.exit(0)

with open(manifest_path, 'r') as f:
    content = f.read()

# Add required permissions before <application
needed_perms = [
    '<uses-permission android:name="android.permission.INTERNET"/>',
    '<uses-permission android:name="android.permission.RECORD_AUDIO"/>',
    '<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>',
    '<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>',
    '<uses-permission android:name="android.permission.CAMERA"/>',
    '<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>',
    '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>',
    '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>',
]

for p in needed_perms:
    if p not in content:
        content = content.replace('<application', f'    {p}\n    <application')

# ADD ic_launcher resource references directly in manifest
# Replace @mipmap/ic_launcher with @android:color/white (safe fallback)
if '@mipmap/ic_launcher' in content:
    content = content.replace('android:icon="@mipmap/ic_launcher"', 'android:icon="@android:color/white"')

if '@style/LaunchTheme' in content:
    content = content.replace('android:theme="@style/LaunchTheme"', '')

if '@style/NormalTheme' in content:
    content = content.replace('android:resource="@style/NormalTheme"', '')

# Remove NormalTheme meta-data if the whole line remains
import re
content = re.sub(r'<meta-data\s+android:name="io.flutter.embedding.android.NormalTheme"[^>]*/>', '', content)

with open(manifest_path, 'w') as f:
    f.write(content)

print(f"✓ Patched {manifest_path} - removed ic_launcher and theme refs")
