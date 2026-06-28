import os
import re
import sys

# Find and patch dash_bubble build.gradle files
pub_cache = os.path.expanduser("~/.pub-cache/hosted/pub.dev")

if not os.path.exists(pub_cache):
    print(f"Pub cache not found: {pub_cache}")
    sys.exit(0)

# Find all dash_bubble build.gradle files
for root, dirs, files in os.walk(pub_cache):
    if "dash_bubble" in root:
        for file in files:
            if file == "build.gradle":
                filepath = os.path.join(root, file)
                print(f"Patching compileSdk in: {filepath}")
                
                with open(filepath, 'r') as f:
                    content = f.read()
                
                # Replace compileSdk with 36
                content = re.sub(
                    r'compileSdk\s+\d+',
                    'compileSdk 36',
                    content
                )
                
                # Also handle compileSdkVersion
                content = re.sub(
                    r'compileSdkVersion\s+\d+',
                    'compileSdkVersion 36',
                    content
                )
                
                with open(filepath, 'w') as f:
                    f.write(content)
                
                print(f"✓ Updated compileSdk to 36 in {filepath}")
            
            elif file == "build.gradle.kts":
                filepath = os.path.join(root, file)
                print(f"Patching compileSdk in: {filepath}")
                
                with open(filepath, 'r') as f:
                    content = f.read()
                
                # Replace compileSdk with 36
                content = re.sub(
                    r'compileSdk\s*=\s*\d+',
                    'compileSdk = 36',
                    content
                )
                
                with open(filepath, 'w') as f:
                    f.write(content)
                
                print(f"✓ Updated compileSdk to 36 in {filepath}")

print("dash_bubble compileSdk patching complete")
