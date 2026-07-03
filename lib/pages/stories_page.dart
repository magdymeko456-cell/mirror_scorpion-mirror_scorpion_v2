import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StoriesPage extends StatefulWidget {
  const StoriesPage({super.key});

  @override
  State<StoriesPage> createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late TabController _tabController;
  
  // الأحاديث القدسية
  final List<Map<String, String>> _hadiths = [
    {'text': 'قال الله تعالى: يا عبادي إني حرمت الظلم على نفسي وجعلته بينكم محرماً فلا تظالموا...', 'source': 'صحيح مسلم'},
    {'text': 'قال الله تعالى: أنا عند ظن عبدي بي، وأنا معه إذا ذكرني...', 'source': 'صحيح البخاري'},
    {'text': 'قال الله تعالى: وعزتي وجلالي لا تؤيس عبدي من رحمتي...', 'source': 'حديث قدسي'},
    {'text': 'قال الله تعالى: يا ابن آدم، لو بلغت ذنوبك عنان السماء ثم استغفرتني غفرت لك...', 'source': 'صحيح الترمذي'},
    {'text': 'قال الله تعالى: ما ترددت عن شيء أنا فاعله ترددي عن نفس المؤمن، يكره الموت وأكره مساءته...', 'source': 'صحيح البخاري'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage('ar');
    await _flutterTts.speak(text);
  }

  Widget _buildHadithCard(Map<String, String> hadith, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // الحديث
            Text(
              hadith['text']!,
              style: const TextStyle(
                fontSize: 18,
                height: 1.8,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            // المصدر وأزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hadith['source']!,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      onPressed: () => _speak(hadith['text']!),
                      tooltip: 'استماع',
                    ),
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {},
                      tooltip: 'مشاركة',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(String title, String summary, String source) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text(
              summary,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
              textAlign: TextAlign.right,
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'المصدر: $source',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            // أزرار الاستماع والمشاهدة والمزيد
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.volume_up, size: 16),
                  label: const Text('استماع'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_circle_outline, size: 16),
                  label: const Text('مشاهدة'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // فتح رابط القصة بشكل خفي
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('جاري فتح القصة الكاملة...'),
                        duration: const Duration(milliseconds: 500),
                      ),
                    );
                  },
                  child: const Text('المزيد...'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildStoryList(List<Map<String, String>> stories) {
    return stories.map((s) => _buildStoryCard(s['title']!, s['summary']!, s['source']!)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أحاديث وقصص وإلهام'),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'أحاديث قدسية'),
            Tab(text: 'قصص الأنبياء'),
            Tab(text: 'قصص النساء'),
            Tab(text: 'قصص الأقوام'),
            Tab(text: 'إلهام'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // الأحاديث القدسية
          ListView.builder(
            itemCount: _hadiths.length * 3, // تكرار لعرض أكثر
            itemBuilder: (context, index) {
              final hadith = _hadiths[index % _hadiths.length];
              return _buildHadithCard(hadith, index);
            },
          ),
          // قصص الأنبياء
          ListView(
            children: _buildStoryList([
              {'title': 'قصة سيدنا نوح عليه السلام', 'summary': 'أرسل الله نوحاً إلى قومه يدعوهم إلى عبادة الله وحده...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة سيدنا إبراهيم عليه السلام', 'summary': 'كان إبراهيم نبياً عظيماً دعا قومه إلى التوحيد...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة سيدنا موسى عليه السلام', 'summary': 'أرسل الله موسى إلى فرعون وقومه...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة سيدنا عيسى عليه السلام', 'summary': 'ولد عيسى بأمر الله من مريم العذراء...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة سيدنا محمد ﷺ', 'summary': 'خاتم الأنبياء والمرسلين، ولد بمكة...', 'source': 'تفسير ابن كثير'},
            ]),
          ),
          // قصص النساء
          ListView(
            children: _buildStoryList([
              {'title': 'قصة السيدة مريم بنت عمران', 'summary': 'اصطفاها الله على نساء العالمين...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة السيدة هاجر أم إسماعيل', 'summary': 'أم النبي إسماعيل وزوجة الخليل إبراهيم...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة امرأة فرعون آسية', 'summary': 'آمنت بالله رغم أن زوجها فرعون...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة بلقيس ملكة سبأ', 'summary': 'ملكة حكيمة آمنت مع سليمان...', 'source': 'تفسير ابن كثير'},
            ]),
          ),
          // قصص الأقوام
          ListView(
            children: _buildStoryList([
              {'title': 'قصة قوم عاد', 'summary': 'قوم هود عليه السلام الذين أهلكوا بالريح العقيم...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة قوم ثمود', 'summary': 'قوم صالح عليه السلام الذين عقروا الناقة...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة قوم لوط', 'summary': 'قوم لوط عليه السلام الذين أهلكوا بالخسف...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة أصحاب الفيل', 'summary': 'قصة أبرهة وجيشه الذين أرادوا هدم الكعبة...', 'source': 'تفسير ابن كثير'},
              {'title': 'قصة أصحاب السبت', 'summary': 'قوم اعتدوا في السبت فمسخوا قردة...', 'source': 'تفسير ابن كثير'},
            ]),
          ),
          // الإلهام
          ListView(
            children: [
              _buildInspirationCard('لا تحزن، إن الله معنا', 'إذا ضاقت بك الدنيا، تذكر أن مع العسر يسراً.'),
              _buildInspirationCard('واصبر لحكم ربك', 'الصبر مفتاح الفرج، وبعده يأتي النصر.'),
              _buildInspirationCard('فإن مع العسر يسراً', 'لكل ضيق مخرج، ولكل مشكلة حل.'),
              _buildInspirationCard('إن رحمة الله قريب من المحسنين', 'مهما طال الظلام، الفجر آتٍ بإذن الله.'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInspirationCard(String title, String text) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.auto_awesome,
              color: Theme.of(context).colorScheme.primary,
              size: 36,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.6,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
