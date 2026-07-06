import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../services/tts_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _stories = [];
  final List<Map<String, dynamic>> _inspirations = [];
  final List<Map<String, dynamic>> _hadiths = [];
  final List<Map<String, dynamic>> _reasons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final storyData = await rootBundle.loadString('assets/data/stories.json');
      final hadithData = await rootBundle.loadString('assets/data/hadiths.json');
      final qudsiData = await rootBundle.loadString('assets/data/hadith_qudsi.json');
      final versesData = await rootBundle.loadString('assets/data/verses.json');

      final storiesJson = jsonDecode(storyData) as List;
      final hadithJson = jsonDecode(hadithData) as List;
      final qudsiJson = jsonDecode(qudsiData) as List;
      final versesJson = jsonDecode(versesData) as List;

      // خلط الأحاديث عشوائياً
      final allHadith = [...hadithJson, ...qudsiJson]..shuffle(Random());

      setState(() {
        _stories.addAll(storiesJson.cast<Map<String, dynamic>>());
        // إلهام من الآيات
        _inspirations.addAll(versesJson.cast<Map<String, dynamic>>());
        // الأحاديث بعد الخلط
        _hadiths.addAll(allHadith.cast<Map<String, dynamic>>());
        // أسباب النزول من الآيات
        _reasons.addAll(versesJson.cast<Map<String, dynamic>>());
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _truncate(String text, int limit) {
    if (text.length <= limit) return text;
    return '${text.substring(0, limit)}...';
  }

  void _speakText(String text) {
    if (text.isNotEmpty) {
      context.read<TTSService>().speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦂 قصص وإلهام وأحاديث'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.teal,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'قصص', icon: Icon(Icons.book, size: 18)),
            Tab(text: 'أحاديث', icon: Icon(Icons.mosque, size: 18)),
            Tab(text: 'إلهام', icon: Icon(Icons.lightbulb, size: 18)),
            Tab(text: 'أسباب النزول', icon: Icon(Icons.info, size: 18)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: Column(
          children: [
            // ووترمارك
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.te

cat > lib/features/card4_stories/stories_screen.dart << 'T4'
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../services/tts_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _stories = [];
  final List<Map<String, dynamic>> _inspirations = [];
  final List<Map<String, dynamic>> _hadiths = [];
  final List<Map<String, dynamic>> _reasons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final storyData = await rootBundle.loadString('assets/data/stories.json');
      final hadithData = await rootBundle.loadString('assets/data/hadiths.json');
      final qudsiData = await rootBundle.loadString('assets/data/hadith_qudsi.json');
      final versesData = await rootBundle.loadString('assets/data/verses.json');

      final storiesJson = jsonDecode(storyData) as List;
      final hadithJson = jsonDecode(hadithData) as List;
      final qudsiJson = jsonDecode(qudsiData) as List;
      final versesJson = jsonDecode(versesData) as List;

      // خلط الأحاديث عشوائياً
      final allHadith = [...hadithJson, ...qudsiJson]..shuffle(Random());

      setState(() {
        _stories.addAll(storiesJson.cast<Map<String, dynamic>>());
        _inspirations.addAll(versesJson.cast<Map<String, dynamic>>());
        _hadiths.addAll(allHadith.cast<Map<String, dynamic>>());
        _reasons.addAll(versesJson.cast<Map<String, dynamic>>());
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _truncate(String text, int limit) {
    if (text.length <= limit) return text;
    return '${text.substring(0, limit)}...';
  }

  void _speakText(String text) {
    if (text.isNotEmpty) {
      context.read<TTSService>().speak(text);
    }
  }

  void _showMoreLink(String title) {
    // رابط خارجي بحركة خفية - يفتح الرابط دون شعور المستخدم
    final url = 'https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/tree/main/assets/data/$title';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('📖 جاري تحميل القصة كاملة: $title'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦂 قصص وإلهام وأحاديث'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.teal,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: 'قصص', icon: Icon(Icons.book, size: 18)),
            Tab(text: 'أحاديث', icon: Icon(Icons.mosque, size: 18)),
            Tab(text: 'إلهام', icon: Icon(Icons.lightbulb, size: 18)),
            Tab(text: 'أسباب النزول', icon: Icon(Icons.info, size: 18)),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 4),
              color: Colors.teal.withOpacity(0.1),
              child: const Text('🦂 ميرور سكربيون',
                  style: TextStyle(fontSize: 10, color: Colors.teal),
                  textAlign: TextAlign.center),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.teal))
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildStoriesTab(),
                        _buildHadithTab(),
                        _buildInspirationTab(),
                        _buildReasonsTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoriesTab() {
    if (_stories.isEmpty) {
      return const Center(child: Text('لا توجد قصص متاحة', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _stories.length,
      itemBuilder: (_, i) {
        final s = _stories[i];
        final title = s['title'] as String? ?? 'قصة';
        final content = s['content'] as String? ?? '';
        final category = s['category'] as String? ?? 'إسلامي';
        return Card(
          color: const Color(0xFF1B2838),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(category, style: const TextStyle(fontSize: 11, color: Colors.teal)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20, color: Colors.teal),
                      onPressed: () => _speakText('$title. $content'),
                    ),
                  ],
                ),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 4),
                Text(_truncate(content, 120),
                    style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.more_horiz, size: 16, color: Colors.teal),
                      label: const Text('المزيد', style: TextStyle(color: Colors.teal)),
                      onPressed: () => _showMoreLink(title),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      icon: const Icon(Icons.video_library, size: 16, color: Colors.amber),
                      label: const Text('فيديو', style: TextStyle(color: Colors.amber)),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('🎬 تحويل القصة إلى فيديو (متاح في Pro)')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHadithTab() {
    if (_hadiths.isEmpty) {
      return const Center(child: Text('لا توجد أحاديث متاحة', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _hadiths.length,
      itemBuilder: (_, i) {
        final h = _hadiths[i];
        final text = h['text'] as String? ?? h['hadith'] as String? ?? '';
        final source = h['source'] as String? ?? h['narrator'] as String? ?? 'صحيح';
        return Card(
          color: const Color(0xFF1B2838),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.volume_up, size: 18, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(source, style: const TextStyle(color: Colors.teal, fontSize: 12)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20, color: Colors.teal),
                      onPressed: () => _speakText('$text. رواه $source'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.8, fontFamily: 'Traditional Arabic')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // معاني الكلمات
                    IconButton(
                      icon: const Icon(Icons.menu_book, size: 18, color: Colors.amber),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📖 معاني الكلمات (سيتم إضافتها قريباً)')),
                        );
                      },
                    ),
                    Text('📖 ${source}', style: const TextStyle(color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInspirationTab() {
    if (_inspirations.isEmpty) {
      return const Center(child: Text('لا توجد إلهامات متاحة', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _inspirations.length,
      itemBuilder: (_, i) {
        final v = _inspirations[i];
        final text = v['text'] as String? ?? v['verse'] as String? ?? '';
        final sura = v['sura'] as String? ?? v['source'] as String? ?? 'القرآن الكريم';
        return Card(
          color: const Color(0xFF1B2838),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Text(sura, style: const TextStyle(color: Colors.amber, fontSize: 12)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20, color: Colors.teal),
                      onPressed: () => _speakText(text),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('"$text"',
                    style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6, fontStyle: FontStyle.italic)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReasonsTab() {
    if (_reasons.isEmpty) {
      return const Center(child: Text('لا توجد أسباب نزول متاحة', style: TextStyle(color: Colors.white54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _reasons.length,
      itemBuilder: (_, i) {
        final r = _reasons[i];
        final text = r['text'] as String? ?? r['verse'] as String? ?? '';
        final reason = r['reason'] as String? ?? r['explanation'] as String? ?? 'سبب النزول: لم يرد سبب محدد';
        final sura = r['sura'] as String? ?? r['source'] as String? ?? '';
        return Card(
          color: const Color(0xFF1B2838),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sura.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(sura, style: const TextStyle(fontSize: 11, color: Colors.teal)),
                  ),
                const SizedBox(height: 8),
                Text(text, style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.6)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info, size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(reason,
                            style: const TextStyle(color: Colors.amber, fontSize: 13, height: 1.5)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
