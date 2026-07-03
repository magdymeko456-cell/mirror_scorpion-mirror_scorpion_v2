#!/usr/bin/env python3
import os, re

def patch_gradle():
    paths = [
        "android/app/build.gradle",
        "android/build.gradle",
        "packages/dash_bubble_local/android/build.gradle"
    ]
    for path in paths:
        if os.path.exists(path):
            with open(path, "r") as f:
                content = f.read()
            content = re.sub(r'compileSdk\s+\d+', 'compileSdk 36', content)
            content = re.sub(r'minSdk\s+\d+', 'minSdk 21', content)
            content = re.sub(r'targetSdk\s+\d+', 'targetSdk 36', content)
            with open(path, "w") as f:
                f.write(content)
            print(f"✅ {path} patched")

patch_gradle()
print("✅ All patches applied")
