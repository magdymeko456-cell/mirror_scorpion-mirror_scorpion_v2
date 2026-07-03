#!/usr/bin/env python3
import os, re

def patch_gradle():
    gradle_files = []
    for root, dirs, files in os.walk("."):
        for f in files:
            if f == "build.gradle" and (root.endswith("android") or "dash_bubble_local" in root):
                gradle_files.append(os.path.join(root, f))
    for path in gradle_files:
        with open(path, "r") as f:
            content = f.read()
        content = re.sub(r'compileSdk\s+\d+', 'compileSdk 36', content)
        content = re.sub(r'minSdk\s+\d+', 'minSdk 21', content)
        content = re.sub(r'targetSdk\s+\d+', 'targetSdk 36', content)
        with open(path, "w") as f:
            f.write(content)
        print(f"✅ {path} -> compileSdk=36")

if __name__ == "__main__":
    patch_gradle()
