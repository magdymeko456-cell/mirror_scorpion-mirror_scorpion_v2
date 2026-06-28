#!/bin/bash
echo "🔧 Mirror Scorpion: تهيئة بيئة الأندرويد V2..."
if [ ! -d "android" ]; then
    echo "📦 إنشاء مجلد أندرويد..."
    flutter create --project-name mirror_scorpion_v2 --org com.tetocollctionway --platforms android .
fi
# Create gradle.properties with v2 embedding enabled
mkdir -p android
cat > android/gradle.properties << 'EOF'
org.gradle.jvmargs=-Xmx4G -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
android.enableJetifier=true
android.defaults.buildfeatures.buildconfig=true
EOF
echo "✅ android configured for v2 embedding"
