#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🎯 أداة تهيئة وهيكلة داتا مشروع Mirror Scorpion v2
الدستور الجديد: ملخصات 10 أسطر + روابط سحابية خفيفة + معاني الكلمات لضعاف البصر
"""

import os
import json

def initialize_database():
    data_dir = os.path.expanduser("~/mirror_scorpion/mirror_scorpion_v2/assets/data")
    os.makedirs(data_dir, exist_ok=True)
    
    # 1. هيكل ملف أسباب النزول المطوّر (قبل، أثناء، بعد، وفيمن نزلت)
    asbab_data = [
        {
            "id": 1,
            "surah": "البقرة",
            "verse_range": "115",
            "title": "أينما تولوا فثم وجه الله",
            "context_before": "خروج سرية من الصحابة في ليلة مظلمة وغياب رؤية القبلة.",
            "context_during": "صلاة كل صحابي لجهة حسب اجتهاده بعد تحيرهم الشديد.",
            "context_after": "عند شروق الشمس تبينوا أنهم صلوا لغير القبلة، فخافوا ونزلت الآية تطميناً لقلوبهم.",
            "revealed_for": "في جماعة من الصحابة تحيروا في القبلة في ليلة مظلمة (منهم عامر بن ربيعة).",
            "summary_10_lines": "الآية نزلت لترسيخ عظمة الله ورحمته بعباده عند غياب اليقين والاضطرار. تخبرنا أن الله لا يضيع سعي المجتهد المشتاق لرضاه حتى لو أخطأ الاتجاه، فالأرض كلها مسجده، والوجهة الحقيقية هي النية المستقرة في القلب لا مجرد زوايا الأرض. تمنح العبد الطمأنينة الكاملة في أوقات الحيرة والظلام.",
            "github_raw_path": "https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/main/assets/database/full_asbab/surah_2_115.txt"
        }
    ]
    
    # 2. هيكل ملف قصص الأنبياء (ابن كثير مع ميزة التتبع والذكاء الاصطناعي للفيديو)
    prophets_data = [
        {
            "id": 1,
            "category": "prophets",
            "title": "قصة نبي الله يوسف عليه السلام",
            "summary_10_lines": "تبدأ القصة برؤيا صبي وتتحول سريعاً إلى مؤامرة بئر من أقرب الناس إليه. ينتقل يوسف إلى مصر ليباع مملوكاً، ثم يتعرض لابتلاء الفتنة في قصر العزيز فيختار السجن حماية لدينه. من عتمة السجن وبسبب موهبة تأويل الرؤى، يصعد ليصبح عزيز مصر ومنقذها من القحط. قصة تجسد كيف يتحول الانكسار والتدبير البشري المؤذي إلى تمكين إلهي عظيم ورفعة للعبد الصابر.",
            "moral_lesson": "كل انكسار مررت به لم يكن إلا تمهيداً لانطلاقة أعظم؛ فالماضي ليس للمحو، بل للتعلّم، والمستقبل هو ما يستحق انتباهك الآن.",
            "ai_video_ready": True,
            "github_raw_path": "https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/main/assets/database/full_stories/youssef.txt"
        }
    ]
    
    # 3. هيكل ملف الأحاديث القدسية (مناسب لضعاف البصر مع معاني الكلمات)
    hadith_qudsi_data = [
        {
            "id": 1,
            "title": "حديث يا عبادي إني حرمت الظلم على نفسي",
            "text": "قال الله تعالى: يا عبادي إني حرمت الظلم على نفسي وجعلته بينكم محرماً فلا تظالموا...",
            "word_meanings": "حرمت الظلم: نزهت نفسي عنه سبحانه وتفصلاً واستحقاقاً. فلا تظالموا: لا يظلم بعضكم بعضاً.",
            "font_size_recommended": "Large",
            "github_raw_path": "https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/main/assets/database/hadiths/qudsi_1.txt"
        }
    ]

    # 4. هيكل ملف الأربعين النووية
    arbaeen_data = [
        {
            "id": 1,
            "hadith_number": "1",
            "title": "إنما الأعمال بالنيات",
            "text": "عن أمير المؤمنين أبي حفص عمر بن الخطاب رضي الله عنه قال: سمعت رسول الله صلى الله عليه وسلم يقول: إنما الأعمال بالنيات...",
            "word_meanings": "بالنيات: مقاصد القلوب، ومفردها نية وهي القصد.",
            "github_raw_path": "https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/main/assets/database/hadiths/arbaeen_1.txt"
        }
    ]

    # كتابة وحفظ كل الملفات بالهيكل الجديد الموحد
    files_map = {
        "asbab_nuzul.json": asbab_data,
        "prophet_stories_ibn_kathir.json": prophets_data,
        "hadith_qudsi.json": hadith_qudsi_data,
        "arbaeen_nawawi.json": arbaeen_data,
        "hadiths.json": hadith_qudsi_data, # للدمج وضمان التوافق
        "quran_stories.json": prophets_data,
        "stories.json": prophets_data,
        "hadith.json": hadith_qudsi_data,
        "verses.json": [{"id": 1, "text": "إنا نحن نزلنا الذكر وإنا له لحافظون"}]
    }

    print("🏗️ البدء في إعادة هيكلة وتصفير ملفات الداتا حسب الدستور الجديد...")
    for filename, content in files_map.items():
        file_path = os.path.join(data_dir, filename)
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(content, f, ensure_ascii=False, indent=2)
        print(f"✅ تم إنشاء وهيكلة: {filename} بنجاح.")

    print("\n🎉 تم تحديث بنية الـ Assets بالكامل وجعلها جاهزة للربط مع محرك الإلهام والذكاء الاصطناعي!")

if __name__ == "__main__":
    initialize_database()
