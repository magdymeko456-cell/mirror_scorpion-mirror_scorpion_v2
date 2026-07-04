#!/bin/bash
# 🦂 تصحيح speech_to_text في pub cache
# يبحث عن build.gradle في أي مكان يحتوي على speech_to_text

set -e
echo "=== 🔍 البحث عن speech_to_text build.gradle ==="

# البحث المباشر — أي ملف build.gradle في مسار يحتوي speech_to_text
find ~/.pub-cache -type f -name "build.gradle" 2>/dev/null | while read f; do
  # التحقق من أن المسار يحتوي على speech_to_text
  if echo "$f" | grep -q "speech_to_text"; then
    echo "🔧 وجد: $f"
    
    # قراءة الملف الحالي
    cp "$f" "${f}.bak"
    
    # إزالة kotlin block — هذه هي الطريقة الأضمن
    # نقرأ الملف كاملاً ونعدله
    python3 -c "
import re
with open('$f', 'r') as fh:
    content = fh.read()

# 1. إزالة kotlin { compilerOptions { ... } } — بأي تنسيق
content = re.sub(
    r'kotlin\s*\{[^}]*compilerOptions[^}]*\}',
    '',
    content,
    flags=re.DOTALL
)

# 2. استبدال compileSdk
content = content.replace(
    'compileSdk = flutter.compileSdkVersion',
    'compileSdk 36'
)

# 3. استبدال ndkVersion
content = content.replace(
    'ndkVersion = flutter.ndkVersion',
    'ndkVersion \"27.0.12077973\"'
)

with open('$f', 'w') as fh:
    fh.write(content)

print('✅ تم التصحيح!')
print()
print('--- الملف الناتج ---')
print(content[:600])
"
  fi
done

echo "=== ✅ انتهى تصحيح speech_to_text ==="
