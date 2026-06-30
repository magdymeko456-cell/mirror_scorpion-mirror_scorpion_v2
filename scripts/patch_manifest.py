import sys, os
mp = sys.argv[1] if len(sys.argv) > 1 else 'android/app/src/main/AndroidManifest.xml'
if not os.path.exists(mp):
    print(f"Error: {mp} not found"); sys.exit(1)
with open(mp, 'r') as f:
    c = f.read()
perms = [
    '<uses-permission android:name="android.permission.INTERNET"/>',
    '<uses-permission android:name="android.permission.RECORD_AUDIO"/>',
    '<uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW"/>',
    '<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>',
    '<uses-permission android:name="android.permission.CAMERA"/>',
    '<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>',
    '<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>',
    '<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>',
]
for p in perms:
    if p not in c:
        c = c.replace('<application', f'{p}\n<application')
with open(mp, 'w') as f:
    f.write(c)
print(f"✓ Patched {mp}")
