# حماية جميع مكونات Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.tetocollctionway.** { *; }

# حماية ML Kit
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }

# حماية جميع الـ Services
-keep class * extends androidx.lifecycle.ViewModel { *; }
-keep class * extends androidx.lifecycle.AndroidViewModel { *; }

# عدم إزالة أي R class
-keep class **.R$* { *; }

# حماية مكتبات الصوت
-keep class android.speech.** { *; }
-keep class android.speech.tts.** { *; }

# حماية webview
-keep class android.webkit.** { *; }
