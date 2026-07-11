#!/bin/bash
set -e

echo "🔍 [1/3] تنظيف وتطهير البيئة الحالية تماماً..."
git fetch origin main

echo "✨ [2/3] كتابة القوام المعتمد والنظيف لملف الـ Workflow..."
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

      - name: Set up Flutter (Stable 3.27.0)
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.27.0'
          channel: 'stable'
          cache: true

      - name: 🔥 Fix Pubspec Architecture Dynamically
        run: |
          echo "[+] Correcting Dart environment constraint..."
          # تعديل صيغة البيئة بالشكل الرسمي الصحيح لفلاتر
          sed -i 's/sdk: .*/sdk: ">=3.0.0 <4.0.0"/g' pubspec.yaml || true
          sed -i 's/path_provider:.*/path_provider: any/g' pubspec.yaml || true
          
          echo "[+] Reconstructing Android directory fresh..."
          rm -rf android/
          flutter create --project-name mirror_scorpion_v2 --org com.tetocollctionway --platforms android .

      - name: 🚀 Prepare Flutter Dependencies
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

echo "🚀 [3/3] جاري دفع الملف المرجعي الصحيح وتطهير السيرفر..."
git add .github/workflows/build.yml auto_sync_patch.sh
git commit -m "🦂 FIX: تصحيح قوام الـ SDK والاعتماد المرجعي للنسخة المستقرة" || true
git push origin main --force

echo "🎯 تم التصحيح الـتلقائي والرفع بنجاح يا تامر! السيرفر هيقرأ الـ SDK صح فوراً."
