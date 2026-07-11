#!/bin/bash
set -e

echo "[+] Starting Global Mirror Scorpion Build Correction..."

# 1. ضبط ملف pubspec.yaml ديناميكياً ليتوافق مع Dart 3.6.0
echo "[+] Overwriting SDK constraints and dependencies in pubspec.yaml..."
sed -i 's/sdk: .*/sdk: ">=3.6.0 <4.0.0"/g' pubspec.yaml || true
sed -i 's/path_provider:.*/path_provider: any/g' pubspec.yaml || true

# 2. تنظيف وإعادة بناء مجلد أندرويد بالكامل لضمان قوام سليم
echo "[+] Reconstructing Android Project Fresh..."
rm -rf android/
flutter create --project-name mirror_scorpion_v2 --org com.tetocollctionway --platforms android .

# 3. حقن قوام ملف android/build.gradle الصحيح (Kotlin 1.8.20 + Gradle 7.3.0)
echo "[+] Injecting official top-level build.gradle..."
cat << 'GRADLE' > android/build.gradle
buildscript {
    ext.kotlin_version = '1.8.20'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
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
    project.buildDir = "${rootProject.buildDir}/${project.name}"
}
subprojects {
    project.evaluationDependsOn(':app')
}
tasks.register("clean", Delete) {
    delete rootProject.buildDir
}
GRADLE

echo "[+] Execution of patch completed successfully!"
