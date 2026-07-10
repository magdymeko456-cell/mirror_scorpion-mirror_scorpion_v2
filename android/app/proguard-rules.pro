# حماية كود مكتبة التعرف على النصوص وجوجل ML Kit من الحذف أو الفحص الصارم
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.**
-dontwarn com.google.mlkit.feature.shared.**
