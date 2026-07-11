#!/bin/bash
set -e

echo "🔍 [1/2] توليد ملف الـ Workflow وتثبيت البناء المستقر..."
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

      - name: 🔥 Overwrite Pubspec Environment Cleanly
        run: |
          cat << 'PUB' > pubspec.yaml
          name: mirror_scorpion_v2
          description: "Mirror Scorpion Application - Heart is Adham"
          publish_to: 'none'
          version: 1.0.0+1

          environment:
            sdk: '>=3.0.0 <4.0.0'

          dependencies:
            flutter:
              sdk: flutter
            path_provider: any

          dev_dependencies:
            flutter_test:
              sdk: flutter
            flutter_lints: ^3.0.0

          flutter:
            uses-material-design: true
          PUB

          echo "[+] Reconstructing Android directory fresh..."
          rm -rf android/
          flutter create --project-name mirror_scorpion_v2 --org com.tetocollctionway --platforms android .

      - name: 📦 Fetch Flutter Dependencies
        run: |
          flutter clean
          flutter pub get

      - name: 🛠️ Patch Gradle (Hardcoded Safe Kotlin Version)
        run: |
          echo "[+] Injecting hardcoded production-ready build.gradle..."
          cat << 'GRADLE' > android/build.gradle
          buildscript {
              ext.kotlin_version = '1.8.20'
              repositories {
                  google()
                  mavenCentral()
                  maven { url "https://plugins.gradle.org/m2/" }
              }
              dependencies {
                  classpath 'com.android.tools.build:gradle:7.3.0'
                  classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:1.8.20"
              }
          }
          allprojects {
              repositories {
                  google()
                  mavenCentral()
                  maven { url "https://plugins.gradle.org/m2/" }
              }
          }
          rootProject.buildDir = '../build'
          subprojects {
              project.buildDir = "${rootProject.buildDir}/${project.name}"
          }
          subprojects {
              project.evaluationDependsOn(':app')
          }
          tasks.register("clean", Delete) {
              delete rootProject.buildDir
          }
          GRADLE
          echo "[+] Safe build.gradle injected!"

      - name: 🏗️ Build Final Obfuscated APK
        run: |
          flutter build apk --release --target-platform android-arm64 --no-tree-shake-icons --obfuscate --split-debug-info=build/debug_info

      - name: 📦 Upload Finished APK
        uses: actions/upload-artifact@v4
        with:
          name: mirror-scorpion-final-stable
          path: build/app/outputs/flutter-apk/app-release.apk
WORKFLOW

echo "🚀 [2/2] رفع التحديث النهائي لتصحيح إصدار كوتلن..."
git add .github/workflows/build.yml auto_sync_patch.sh
git commit -m "🦂 FIX: تثبيت نصي مباشر لإصدار kotlin-gradle-plugin بدون رموز هروب" || true
git push origin main --force
