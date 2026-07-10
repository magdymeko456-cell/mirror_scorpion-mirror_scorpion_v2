import os

def patch_android_gradle():
    gradle_path = os.path.join('android', 'build.gradle')
    
    if not os.path.exists(gradle_path):
        print(f"[-] Error: {gradle_path} not found!")
        return

    clean_gradle_content = """// Top-level build file where you can add configuration options common to all sub-projects/modules.

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
"""

    try:
        with open(gradle_path, 'w', encoding='utf-8') as file:
            file.write(clean_gradle_content)
        print("[+] android/build.gradle has been successfully overwritten with Kotlin 1.8.20!")
    except Exception as e:
        print(f"[-] Failed to write to build.gradle: {e}")

if __name__ == "__main__":
    patch_android_gradle()
