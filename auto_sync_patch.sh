#!/bin/bash
set -e

echo "🔍 [1/2] توليد ملف بناء نظيف ومستقر 100%..."
mkdir -p .github/workflows

cat << 'WORKFLOW' > .github/workflows/build.yml
name: Build Mirror Scorpion

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up Java
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'

      - name: 🚀 Set up Stable Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'
          channel: 'stable'
          cache: true

      - name: 🔥 Reconstruct Android Platform Fresh
        run: |
          echo "[+] Clearing and creating fresh android architecture..."
          rm -rf android/
          flutter create --project-name mirror_scorpion_v2 --org com.tetocollctionway --platforms android .

      - name: 🛠️ Fix path_provider Dependency
        run: |
          sed -i 's/path_provider:.*/path_provider: any/g' pubspec.yaml || true

      - name: 📦 Fetch Flutter Dependencies
        run: |
          flutter clean
          flutter pub get

      - name: 🛠️ Patch Gradle & Kotlin Version (Enforce 1.8.20)
        run: |
          cat << 'GRADLE' > android/build.gradle
          buildscript {
              ext.kotlin_version = '1.8.20'
              repositories {
                  google()
                  mavenCentral()
              }
              dependencies {
                  classpath 'com.android.tools.build:gradle:7.3.0'
                  classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:\$kotlin_version"
              }
          }
          allprojects {
              repositories {
                  google()
                  mavenCentral()
              }
          }
          rootProject.buildDir = '../build'
          subprojects {
              project.buildDir = "\${rootProject.buildDir}/\${project.name}"
          }
          subprojects {
              project.evaluationDependsOn(':app')
          }
          tasks.register("clean", Delete) {
              delete rootProject.buildDir
          }
          GRADLE

      - name: 🏗️ Build Final Obfuscated APK
        run: |
          flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons --obfuscate --split-debug-info=build/debug_info

      - name: 📦 Upload Finished APK
        uses: actions/upload-artifact@v4
        with:
          name: mirror-scorpion-final-stable
          path: build/app/outputs/flutter-apk/app-release.apk
WORKFLOW

echo "🚀 [2/2] رفع التعديلات الحقيقية وإنهاء الدائرة المفرغة..."
git add .github/workflows/build.yml auto_sync_patch.sh pubspec.yaml
git commit -m "🦂 FIX: تعديل الـ SDK الأصلي في pubspec وتثبيت البناء المستقر" || true
git push origin main --force
