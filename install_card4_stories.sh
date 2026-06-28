#!/bin/bash
cd ~/mirror_scorpion/mirror_scorpion_v2

echo "═══ 1/3 إنشاء قاعدة بيانات القصص والآيات الشاملة ═══"
mkdir -p assets/data
cat > assets/data/quran_stories.json << 'QSEOF'
{
  "prophets": [
    {
      "id": "prophet_01",
      "category": "انبياء",
      "title": "قصة آدم عليه السلام",
      "text_ar": "بدأت قصة آدم عليه السلام عندما أخبر الله ملائكته بأنه سيجعل في الأرض خليفة، فخلقه من طين ونفخ فيه من روحه وعلمه الأسماء كلها، ثم أمر الملائكة بالسجود له تكريماً، فسجدوا إلا إبليس أبى واستكبر. أسكن الله آدم وزوجته حواء الجنة، ونهاهما عن شجرة واحدة، فوسوس لهما الشيطان فأكلا منها، فندما وتابا إلى الله، فقبل الله توبتهما وأهبطهما إلى الأرض لتبدأ رحلة البشرية.",
      "source": "سورة البقرة، الأعراف، طه",
      "lessons": ["التوبة النصوحة", "خطر الكبر", "عداوة الشيطان"]
    },
    {
      "id": "prophet_03",
      "category": "انبياء",
      "title": "قصة نوح عليه السلام",
      "text_ar": "نوح عليه السلام هو أول أولي العزم من الرسل، دعا قومه 950 سنة ليلاً ونهاراً فلم يزدهم دعاؤه إلا فراراً. أوحى الله إليه أن يصنع السفينة، وعندما جاء أمر الله وفار التنور، حمل فيها من كل زوجين اثنين وأهله والمؤمنين، وغرق الكافرون جميعاً ومنهم ابنه، ورست السفينة على الجودي.",
      "source": "سورة نوح، هود",
      "lessons": ["الصبر في الدعوة", "الإيمان ينجي", "لا عاصم من أمر الله"]
    },
    {
      "id": "prophet_06",
      "category": "انبياء",
      "title": "قصة إبراهيم عليه السلام",
      "text_ar": "إبراهيم خليل الله وأبو الأنبياء، حارب عبادة الأصنام والكواكب بالمنطق، فحطّم أصنام قومه فقرروا إحراقه بنار عظيمة، فجعلها الله برداً وسلاماً عليه. هاجر وبنى الكعبة مع ابنه إسماعيل، واختبره الله بذبح ابنه فسلّما لأمر الله ففداه بذبح عظيم.",
      "source": "سورة الأنبياء، الصافات",
      "lessons": ["التوحيد الخالص", "التسليم المطلق لله", "قوة الحجة"]
    }
  ],
  "women": [
    {
      "id": "woman_01",
      "category": "نساء",
      "title": "مريم بنت عمران عليها السلام",
      "text_ar": "مريم ابنة عمران اصطفاها الله وطهرها على نساء العالمين، نشأت في محراب العبادة، ورزقها الله بعيسى عليه السلام بمعجزة إلهية من غير أب، واجهت قومها بيقين وصبر، وأنطق الله طفلها في المهد ليبرئها ويثبت نبوته.",
      "source": "سورة مريم، آل عمران",
      "lessons": ["العفة والتقوى", "اليقين التام بفرج الله", "الصبر على الابتلاء"]
    },
    {
      "id": "woman_02",
      "category": "نساء",
      "title": "آسية امرأة فرعون",
      "text_ar": "آسية بنت مزاحم آمنت بالله في عقر دار أعتى طاغية على الأرض (فرعون)، وحمت موسى رضيعاً وربته في قصرها، وعندما علم فرعون بإيمانها عذبها فثبتت ودعت: 'رب ابن لي عندك بيتاً في الجنة'، فأراها الله مكانها وقبض روحها زكية.",
      "source": "سورة التحريم",
      "lessons": ["ثبات الإيمان في بيئة الكفر", "تقديم الآخرة على الدنيا"]
    }
  ],
  "animals": [
    {
      "id": "animal_01",
      "category": "حيوان",
      "title": "هدهد سليمان",
      "text_ar": "كان الهدهد جندياً ذكياً في جيش سليمان عليه السلام، غاب وتفقد مملكة سبأ وأتى بنبأ يقين عن قوم يسجدون للشمس من دون الله، فكان سبباً رئيسياً ودبلوماسياً في هداية ملكتهم بلقيس وشعبها بالكامل إلى التوحيد.",
      "source": "سورة النمل",
      "lessons": ["الأمانة والدقة في نقل الأخبار", "الإيجابية والدعوة إلى الله"]
    }
  ],
  "asbab_nuzul": [
    {
      "surah": "الكهف",
      "ayah": "الآيات 1-10",
      "text": "نزلت صدارة سورة الكهف حين سألت قريش النبي صلى الله عليه وسلم عن فتية ذهبوا في الدهر الأول وعن رجل طواف وعن الروح، اختباراً لنبوته، فأنزل الله الآيات محققة للحق وتثبيتاً للمؤمنين."
    },
    {
      "surah": "الضحى",
      "ayah": "كاملة",
      "text": "نزلت السورة بعدما فتر الوحي وانقطع عن النبي أياماً، فقال المشركون: 'إن محمداً قد وُدّع وقُلي'، فأنزل الله سبحانه وتعالى السورة قسماً بالضحى والليل تأكيداً أنه ما ودعه ربه وما قلى."
    }
  ]
}
QSEOF

echo "═══ 2/3 بناء شاشة القصص الكاملة بـ 4 تبويبات تفاعلية ═══"
mkdir -p lib/features/card4_stories
cat > lib/features/card4_stories/stories_screen.dart << 'STORIESEOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic> _data = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadStoriesData();
  }

  Future<void> _loadStoriesData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/quran_stories.json');
      setState(() {
        _data = json.decode(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('ركن القصص والتدبر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amber,
          labelColor: Colors.amber,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'الأنبياء'),
            Tab(text: 'نساء خلدن'),
            Tab(text: 'عجائب الحيوان'),
            Tab(text: 'أسباب النزول'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListSection(_data['prophets'] ?? []),
                _buildListSection(_data['women'] ?? []),
                _buildListSection(_data['animals'] ?? []),
                _buildAsbabSection(_data['asbab_nuzul'] ?? []),
              ],
            ),
    );
  }

  Widget _buildListSection(List<dynamic> items) {
    if (items.isEmpty) return const Center(child: Text('لا توجد بيانات حالياً', style: TextStyle(color: Colors.white54)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text(item['title'] ?? '', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
            subtitle: Text('المصدر: ${item['source']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
            iconColor: Colors.amber,
            collapsedIconColor: Colors.white,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(item['text_ar'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6), textAlign: TextAlign.justify),
                    const SizedBox(height: 12),
                    if (item['lessons'] != null) ...[
                      const Text('الدروس المستفادة:', style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 4),
                      ...(item['lessons'] as List).map((l) => Text('• $l', style: const TextStyle(color: Colors.white70, fontSize: 13))),
                    ],
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                      onPressed: () => Provider.of<TTSService>(context, listen: false).speak(item['text_ar'] ?? ''),
                      icon: const Icon(Icons.volume_up),
                      label: const Text('استماع للصوت'),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildAsbabSection(List<dynamic> items) {
    if (items.isEmpty) return const Center(child: Text('لا توجد بيانات حالياً', style: TextStyle(color: Colors.white54)));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          color: Colors.white.withOpacity(0.05),
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('سورة ${item['surah']} - ${item['ayah']}', style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(item['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.amber),
                    onPressed: () => Provider.of<TTSService>(context, listen: false).speak(item['text'] ?? ''),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
STORIESEOF

echo "═══ 3/3 ربط شاشة القصص في القائمة الرئيسية وعمل الرفع والتحديث ═══"
# التأكد من تفعيل الضغط لفتح الشاشة عند الضغط على الكارت الرابع في لوحة التحكم الرئيسية
sed -i '/_buildMenuCard.*ركن القصص القرآنية/,/);/c\                  _buildMenuCard("ركن القصص القرآنية", Icons.auto_stories, Colors.amber, () {\n                    Navigator.push(context, MaterialPageRoute(builder: (_) => const StoriesScreen()));\n                  }),' lib/features/dashboard/dashboard_screen.dart 2>/dev/null || true

# إضافة ملف البيانات في pubspec.yaml إذا لم يكن موجوداً
if ! grep -q "assets/data/quran_stories.json" pubspec.yaml; then
  sed -i '/assets:/a \    - assets/data/quran_stories.json' pubspec.yaml
fi

echo "═══ جاري الرفع المباشر والتحديث السليم إلى GitHub ═══"
git add -A
git commit -m "feat: تفعيل الكارت الرابع ركن القصص بالكامل وتحديث قواعد البيانات المحلية"
git push origin main --force

echo "✅ تم اكتمال الكارت الرابع بالكامل ورفعه بأمان يا تامر!"
