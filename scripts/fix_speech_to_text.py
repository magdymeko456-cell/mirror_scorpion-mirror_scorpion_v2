#!/usr/bin/env python3
"""
Fix speech_to_text build.gradle for AGP 8.9+ compatibility.
Problem: compileSdk = flutter.compileSdkVersion (flutter property not available)
         + kotlin { compilerOptions {} } (Kotlin DSL in Groovy file)
Fix: Replace with hardcoded compileSdk 36 and remove kotlin block
"""
import os
import re
import glob

# Search paths for pub cache
pub_cache_paths = [
    os.path.expanduser("~/.pub-cache"),
    "/home/runner/.pub-cache",
    "/opt/hostedtoolcache",
]

found_files = []

for base in pub_cache_paths:
    if os.path.exists(base):
        pattern = os.path.join(base, "**", "speech_to_text*", "android", "build.gradle")
        matches = glob.glob(pattern, recursive=True)
        found_files.extend(matches)

# Also search entire home
home = os.path.expanduser("~")
pattern = os.path.join(home, ".pub-cache", "**", "speech_to_text*", "android", "build.gradle")
matches = glob.glob(pattern, recursive=True)
found_files.extend(matches)

if not found_files:
    print("ERROR: speech_to_text build.gradle not found!")
    print("Searching entire filesystem...")
    import subprocess
    result = subprocess.run(
        ["find", "/", "-path", "*/speech_to_text*/android/build.gradle", "-type f"],
        capture_output=True, text=True, timeout=10
    )
    found_files = result.stdout.strip().split("\n")

print(f"Found {len(found_files)} speech_to_text build.gradle files")

for filepath in found_files:
    if not filepath or not os.path.exists(filepath):
        continue
    
    print(f"\n=== Patching: {filepath} ===")
    with open(filepath, 'r') as f:
        content = f.read()
    
    print("BEFORE:")
    print(content[:500])
    
    # Fix 1: compileSdk = flutter.compileSdkVersion -> compileSdk 36
    content = content.replace(
        "compileSdk = flutter.compileSdkVersion",
        "compileSdk 36"
    )
    
    # Fix 2: ndkVersion = flutter.ndkVersion -> fixed version
    content = content.replace(
        "ndkVersion = flutter.ndkVersion",
        'ndkVersion "27.0.12077973"'
    )
    
    # Fix 3: Remove kotlin { compilerOptions { ... } } block completely
    content = re.sub(
        r'\s*kotlin\s*\{[^}]*compilerOptions[^}]*\}',
        '',
        content,
        flags=re.DOTALL
    )
    
    with open(filepath, 'w') as f:
        f.write(content)
    
    print("AFTER:")
    print(content[:500])
    print(f"✓ Patched {filepath}")

print("\n=== Done patching speech_to_text ===")
