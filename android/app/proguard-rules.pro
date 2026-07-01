# Mirror Scorpion - ProGuard Rules
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep class com.tetocollctionway.mirror_scorpion_translate.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**
-keep class com.google.firebase.** { *; }

# Encryption
-keep class javax.crypto.** { *; }
-keep class android.security.** { *; }
