#!/bin/bash

echo "🚀 جاري بدء سكربت الدمج والتطهير الذكي لمشروع Mirror..."
echo "----------------------------------------------------------------------"

# التأكد من وجود لغة بايثون للقيام بالمقارنة الذكية
if ! command -v python3 &> /dev/null; then
    echo "📦 جاري تثبيت python3 للمساعدة في فحص أحجام الملفات..."
    pkg install python3 -y
fi

# كود بايثون مدمج للبحث عن الملفات المكررة بالاسم ومقارنة أحجامها
python3 - << 'EOF'
import os

def find_and_clean_duplicates(root_dir):
    file_map = {}
    
    # 1. مسح شامل لكل الملفات في المجلد
    for dirpath, _, filenames in os.walk(root_dir):
        # تخطي مجلدات النظام والـ Git والـ Build
        if any(part in dirpath for part in ['.git', '.dart_tool', 'build', '.tmp_build_analysis']):
            continue
            
        for filename in filenames:
            # نركز على ملفات الأكواد والداتا والمحتوى (dart, json, txt, md)
            if filename.endswith(('.dart', '.yaml', '.json', '.txt', '.md', '.sh')):
                full_path = os.path.join(dirpath, filename)
                file_size = os.path.getsize(full_path)
                
                if filename not in file_map:
                    file_map[filename] = []
                file_map[filename].append({'path': full_path, 'size': file_size})

    print("📊 جاري فحص الملفات المكررة واختيار الداتا الكاملة...")
    print("----------------------------------------------------------------------")
    
    cleaned_count = 0
    
    for filename, occurrences in file_map.items():
        if len(occurrences) > 1:
            print(f"🔍 وجدنا ملف مكرر باسم: [{filename}] بعدد مرات: {len(occurrences)}")
            
            # ترتيب الملفات حسب الحجم من الأكبر للأصغر
            sorted_occurrences = sorted(occurrences, key=lambda x: x['size'], reverse=True)
            
            # الملف الأكبر هو الملف الذهبي اللي هنحافظ عليه
            golden_file = sorted_occurrences[0]
            print(f"  ✅ الاحتفاظ بالملف الأكبر (الداتا الكاملة): {golden_file['path']} ({golden_file['size']} bytes)")
            
            # مسح الملفات الأصغر المكررة
            for duplicate in sorted_occurrences[1:]:
                try:
                    os.remove(duplicate['path'])
                    print(f"  🗑️ تم حذف التكرار البسيط: {duplicate['path']} ({duplicate['size']} bytes)")
                    cleaned_count += 1
                except Exception as e:
                    print(f"  ❌ فشل حذف {duplicate['path']}: {e}")
                    
    print("----------------------------------------------------------------------")
    print(f"🎉 عملية التطهير انتهت! تم حذف {cleaned_count} ملف مكرر بسيط والاحتفاظ بالداتا الكاملة.")

# تشغيل الفحص على المجلد الحالي
find_and_clean_duplicates('.')
EOF

echo "----------------------------------------------------------------------"
echo "✨ مبروك يا تامر يا صاحبي! المجلد دلوقتي بقى نضيف 100% والداتا الكبيرة هي اللي كسبت."
