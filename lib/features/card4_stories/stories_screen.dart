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

      final storiesJson = jsonDecode(storyData) as List<dynamic>;
      final hadithJson = jsonDecode(hadithData) as List<dynamic>;
      final qudsiJson = jsonDecode(qudsiData) as List<dynamic>;
      final versesJson = jsonDecode(versesData) as List<dynamic>;

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

  String _truncate(String text, int max) {
    if (text.length <= max) return text;
    return '${text.substring(0, max)}...';
  }

  void _speakText(String text) {
    context.read<TTSService>().speak(text);
  }

  void _showMoreLink(String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔗 روابط إضافية',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _linkItem('📖', 'قراءة القصة كاملة على القصة الإسلامية',
                'https://www.islamstory.com'),
            _linkItem('📺', 'مشاهدة فيديو يوتيوب', 'https://www.youtube.com'),
            _linkItem('📚', 'تفسير ابن كثير', 'https://www.quran.com'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _linkItem(String emoji, String label, String url) {
    return ListTile(
      leading: Text(emoji, style: const TextStyle(fontSize: 24)),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      subtitle: Text(url, style: const TextStyle(color: Colors.white38, fontSize: 11)),
      onTap: () => Navigator.pop(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦂 قصص وحكم'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.teal,
          labelColor: Colors.teal,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(text: '📖 قصص', icon: Icon(Icons.book, size: 18)),
            Tab(text: '📜 أحاديث', icon: Icon(Icons.menu_book, size: 18)),
            Tab(text: '💡 إلهام', icon: Icon(Icons.lightbulb, size: 18)),
            Tab(text: '📥 أسباب', icon: Icon(Icons.download, size: 18)),
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
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 16),
                    Text('جاري تحميل القصص والأحاديث...',
                        style: TextStyle(color: Colors.white54)),
                  ],
                ),
              )
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
    );
  }

  Widget _buildStoriesTab() {
    if (_stories.isEmpty) {
      return const Center(
        child: Text('لا توجد قصص متاحة', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _stories.length,
      itemBuilder: (_, i) {
        final s = _stories[i];
        final title = s['title'] as String? ?? 'قصة إسلامية';
        final content = s['content'] as String? ?? s['story'] as String? ?? '';
        final source = s['source'] as String? ?? 'رواه البخاري';
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(source,
                          style: const TextStyle(fontSize: 11, color: Colors.teal)),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20, color: Colors.teal),
                      onPressed: () => _speakText('$title. $content'),
                    ),
                  ],
                ),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  _truncate(content, 120),
                  style: const TextStyle(color: Colors.white60, fontSize: 13, height: 1.5),
                ),
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
                          const SnackBar(
                              content: Text('🎬 تحويل القصة إلى فيديو (متاح في Pro)')),
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
      return const Center(
        child: Text('لا توجد أحاديث متاحة', style: TextStyle(color: Colors.white54)),
      );
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
                    Text(source,
                        style: const TextStyle(color: Colors.teal, fontSize: 12)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20, color: Colors.teal),
                      onPressed: () => _speakText('$text. رواه $source'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(text,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.8,
                        fontFamily: 'Traditional Arabic')),
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.menu_book, size: 18, color: Colors.amber),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('📖 معاني الكلمات (سيتم إضافتها قريباً)')),
                        );
                      },
                    ),
                    Text('📖 $source',
                        style: const TextStyle(color: Colors.white38, fontSize: 11)),
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
      return const Center(
        child: Text('لا توجد إلهامات متاحة', style: TextStyle(color: Colors.white54)),
      );
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
                    Text(sura,
                        style: const TextStyle(color: Colors.amber, fontSize: 12)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20, color: Colors.teal),
                      onPressed: () => _speakText(text),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '"$text"',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.6,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReasonsTab() {
    if (_reasons.isEmpty) {
      return const Center(
        child: Text('لا توجد أسباب نزول متاحة',
            style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: _reasons.length,
      itemBuilder: (_, i) {
        final r = _reasons[i];
        final text = r['text'] as String? ?? r['verse'] as String? ?? '';
        final reason =
            r['reason'] as String? ?? r['explanation'] as String? ?? 'سبب النزول: لم يرد سبب محدد';
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
                    child: Text(sura,
                        style: const TextStyle(fontSize: 11, color: Colors.teal)),
                  ),
                const SizedBox(height: 8),
                Text(text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, height: 1.6)),
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
                            style: const TextStyle(
                                color: Colors.amber, fontSize: 13, height: 1.5)),
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
