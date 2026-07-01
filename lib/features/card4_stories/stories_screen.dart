import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/database_service.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> with TickerProviderStateMixin {
  String _selectedTab = 'hadith';
  String? _currentInspiration;
  bool _isInspirationEnabled = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _loadInspiration();
  }

  void _loadInspiration() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        _currentInspiration = '﴿ إِنَّ مَعَ الْعُسْرِ يُسْرًا ﴾\nالشرح: 6';
      });
      _fadeController.forward();
    }
  }

  void _refreshInspiration() async {
    _fadeController.reverse();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _currentInspiration = AIService.getDailyInspiration() as String?;
      });
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<DatabaseService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('أحاديث وقصص وإلهام', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.purpleAccent),
      ),
      body: Column(
        children: [
          // --- Tabs: أحاديث | قصص | إلهام | أسباب نزول ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _buildTab('hadith', 'أحاديث', Icons.book),
                const SizedBox(width: 8),
                _buildTab('stories', 'قصص', Icons.auto_stories),
                const SizedBox(width: 8),
                _buildTab('asbab', 'أسباب نزول', Icons.download),
                const SizedBox(width: 8),
                _buildTab('inspire', 'إلهام', Icons.auto_awesome),
              ],
            ),
          ),

          // --- محتوى حسب التبويب ---
          Expanded(
            child: _selectedTab == 'hadith' ? _buildHadithView(db)
                : _selectedTab == 'stories' ? _buildStoriesView(db)
                : _selectedTab == 'asbab' ? _buildAsbabView(db)
                : _buildInspirationView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String id, String label, IconData icon) {
    bool isActive = _selectedTab == id;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = id),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? Colors.purpleAccent.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.purpleAccent : Colors.white12,
              width: isActive ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? Colors.purpleAccent : Colors.white38, size: 20),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(
                color: isActive ? Colors.purpleAccent : Colors.white54,
                fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHadithView(DatabaseService db) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // حديث عشوائي
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.withOpacity(0.2), Colors.indigo.withOpacity(0.1)],
              begin: Alignment.topRight, end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Text('🕌 حديث شريف', style: TextStyle(color: Colors.purpleAccent, fontSize: 14)),
              const SizedBox(height: 16),
              Text(
                'عن عمر بن الخطاب رضي الله عنه قال: سمعت رسول الله ﷺ يقول: "إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى"',
                style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.8),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text('رواه البخاري ومسلم',
                style: TextStyle(color: Colors.white38, fontSize: 12)),
              const SizedBox(height: 16),
              // سبيكر
              Consumer<TTSService>(
                builder: (_, tts, __) => IconButton(
                  icon: Icon(Icons.volume_up,
                    color: tts.isSpeaking ? Colors.purpleAccent : Colors.white54, size: 28),
                  onPressed: () => tts.speak(
                    'عن عمر بن الخطاب رضي الله عنه قال: سمعت رسول الله صلى الله عليه وسلم يقول: إنما الأعمال بالنيات، وإنما لكل امرئ ما نوى'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // قائمة الأحاديث
        if (db.isLoaded && db.hadiths.isNotEmpty)
          ...db.hadiths.take(10).map((hadith) => Card(
            color: const Color(0xFF1B2838),
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(hadith['text'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text(hadith['source'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 11)),
              leading: const Icon(Icons.format_quote, color: Colors.purpleAccent),
            ),
          )),
      ],
    );
  }

  Widget _buildStoriesView(DatabaseService db) {
    return DefaultTabController(
      length: 6,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            indicatorColor: Colors.purpleAccent,
            labelColor: Colors.purpleAccent,
            unselectedLabelColor: Colors.white38,
            tabs: [
              Tab(text: 'قرآن'),
              Tab(text: 'أنبياء'),
              Tab(text: 'نساء'),
              Tab(text: 'حيوان'),
              Tab(text: 'إنسان'),
              Tab(text: 'أقوام'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _storyList(db.quranStories, 'قصة قرآنية'),
                _storyList(db.prophetStories, 'قصة نبي'),
                _storyList(db.womenStories, 'قصة امرأة'),
                _storyList(db.animalStories, 'قصة حيوان'),
                _storyList(db.humanStories, 'قصة إنسان'),
                _storyList(db.nationsStories, 'قصة أمة'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _storyList(List stories, String type) {
    if (stories.isEmpty) {
      return const Center(
        child: Text('📖 جارٍ تحميل القصص...', style: TextStyle(color: Colors.white54)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: stories.length,
      itemBuilder: (_, i) {
        final story = stories[i];
        return Card(
          color: const Color(0xFF1B2838),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(story['title']?.toString() ?? story['name']?.toString() ?? 'قصة',
              style: const TextStyle(color: Colors.white, fontSize: 14)),
            subtitle: Text('${story['text']?.toString().substring(0, (story['text']?.toString().length ?? 50).clamp(10, 80))}...',
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
            leading: const Icon(Icons.auto_stories, color: Colors.purpleAccent),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white54, size: 18),
                  onPressed: () => Provider.of<TTSService>(context, listen: false)
                      .speak(story['text']?.toString() ?? ''),
                ),
                IconButton(
                  icon: const Icon(Icons.play_circle_outline, color: Colors.white38, size: 18),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('🎬 تحويل القصة إلى فيديو (قريباً في النسخة القادمة)')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAsbabView(DatabaseService db) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // أسباب نزول عشوائية
        ...List.generate(5, (i) {
          final asbab = db.getRandomAsbab();
          return Card(
            color: const Color(0xFF1B2838),
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('سورة ${asbab['surah'] ?? ''} - آية ${asbab['ayah'] ?? ''}',
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(asbab['reason']?.toString() ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
                  const SizedBox(height: 6),
                  Text('"${asbab['text'] ?? ''}"',
                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 14, height: 1.6)),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildInspirationView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // زر تشغيل/إيقاف الإلهام
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 16),
                const Icon(Icons.auto_awesome, color: Colors.purpleAccent, size: 20),
                const SizedBox(width: 8),
                const Text('الإلهام الذكي', style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(width: 8),
                Switch(
                  value: _isInspirationEnabled,
                  onChanged: (v) => setState(() => _isInspirationEnabled = v),
                  activeColor: Colors.purpleAccent,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // بطاقة الإلهام
          if (_currentInspiration != null)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.withOpacity(0.3), Colors.indigo.withOpacity(0.2)],
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.purpleAccent.withOpacity(0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text('💫 رسالة إلهام', style: TextStyle(color: Colors.purpleAccent, fontSize: 16)),
                    const SizedBox(height: 16),
                    Text(_currentInspiration!,
                      style: const TextStyle(color: Colors.white, fontSize: 20, height: 1.8),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.purpleAccent, size: 28),
                          onPressed: _refreshInspiration,
                          tooltip: 'رسالة جديدة',
                        ),
                        const SizedBox(width: 16),
                        Consumer<TTSService>(
                          builder: (_, tts, __) => IconButton(
                            icon: Icon(Icons.volume_up,
                              color: tts.isSpeaking ? Colors.purpleAccent : Colors.white54, size: 26),
                            onPressed: () => tts.speak(_currentInspiration!),
                            tooltip: 'استماع',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
