import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../services/database_service.dart';
import '../../services/ai_service.dart';
import '../../services/tts_service.dart';
import '../../services/language_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedCategory = 'quran';
  bool _showAsbab = false;

  final List<Map<String, dynamic>> _categories = [
    {'key': 'quran', 'label': 'قصص القرآن', 'icon': Icons.menu_book},
    {'key': 'prophets', 'label': 'الأنبياء', 'icon': Icons.person},
    {'key': 'women', 'label': 'النساء', 'icon': Icons.woman},
    {'key': 'animals', 'label': 'الحيوان', 'icon': Icons.pets},
    {'key': 'nations', 'label': 'الأقوام', 'icon': Icons.groups},
    {'key': 'humans', 'label': 'الإنسان', 'icon': Icons.people},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DatabaseService>();
    final ai = context.watch<AIService>();
    final tts = context.watch<TTSService>();
    final lang = context.watch<LanguageService>();
    final deviceLang = lang.getDeviceLanguage();
    final isArabic = deviceLang == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('📖 قصص وإلهام', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF1B2838),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.orangeAccent,
          labelColor: Colors.orangeAccent,
          unselectedLabelColor: Colors.white54,
          tabs: const [
            Tab(icon: Icon(Icons.auto_stories), text: 'قصص وأسباب نزول'),
            Tab(icon: Icon(Icons.psychology), text: 'إلهام'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ====== التبويب 1: قصص + أسباب نزول ======
          _buildStoriesTab(db, tts, isArabic),

          // ====== التبويب 2: إلهام ======
          _buildInspirationTab(ai, tts, isArabic),
        ],
      ),
    );
  }

  Widget _buildStoriesTab(DatabaseService db, TTSService tts, bool isArabic) {
    return Column(
      children: [
        // تصنيفات القصص
        Container(
          height: 80,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (_, i) {
              final cat = _categories[i];
              final active = _selectedCategory == cat['key'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCategory = cat['key'] as String),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? Colors.orangeAccent.withOpacity(0.2) : Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: active ? Colors.orangeAccent : Colors.white12),
                  ),
                  child: Row(
                    children: [
                      Icon(cat['icon'] as IconData, color: active ? Colors.orangeAccent : Colors.white38, size: 20),
                      const SizedBox(width: 8),
                      Text(cat['label'] as String,
                        style: TextStyle(color: active ? Colors.orangeAccent : Colors.white54, fontWeight: active ? FontWeight.bold : FontWeight.normal)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // زر أسباب النزول
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => setState(() => _showAsbab = !_showAsbab),
                  icon: Icon(_showAsbab ? Icons.book : Icons.info_outline, color: Colors.tealAccent, size: 18),
                  label: Text(
                    _showAsbab ? '🔽 إخفاء أسباب النزول' : '📖 أسباب النزول',
                    style: const TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.tealAccent.withOpacity(0.05),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.tealAccent.withOpacity(0.2))),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // زر الإلهام السريع
              Consumer<AIService>(
                builder: (_, aiSvc, __) => CircleAvatar(
                  backgroundColor: Colors.amberAccent.withOpacity(0.15),
                  radius: 22,
                  child: IconButton(
                    icon: const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 20),
                    onPressed: () async {
                      final msg = await aiSvc.generateInspiration(context: 'story_page');
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('💡 $msg', style: const TextStyle(color: Colors.white)),
                            backgroundColor: const Color(0xFF1B2838),
                            duration: const Duration(seconds: 5),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        // محتوى أسباب النزول أو القصص
        Expanded(
          child: _showAsbab ? _buildAsbabList(db) : _buildStoriesList(db, tts),
        ),
      ],
    );
  }

  Widget _buildAsbabList(DatabaseService db) {
    final reasons = db.revelationReasons;
    if (reasons.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.info_outline, size: 50, color: Colors.tealAccent.withOpacity(0.3)),
          const SizedBox(height: 10),
          const Text('📖 أسباب النزول قادمة في التحديث', style: TextStyle(color: Colors.white38)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reasons.length,
      itemBuilder: (_, i) {
        final r = reasons[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.tealAccent.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.tealAccent.withOpacity(0.15)),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Text('${r['surah'] ?? ''} : ${r['ayah'] ?? ''}',
                  style: const TextStyle(color: Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold))),
              const Spacer(),
              Icon(Icons.info_outline, color: Colors.tealAccent.withOpacity(0.5), size: 16),
            ]),
            const SizedBox(height: 8),
            Text(r['reason'] ?? r['text'] ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.6)),
          ]),
        );
      },
    );
  }

  Widget _buildStoriesList(DatabaseService db, TTSService tts) {
    final stories = db.getStoriesByCategory(_selectedCategory);
    if (stories.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.auto_stories, size: 60, color: Colors.orangeAccent.withOpacity(0.2)),
          const SizedBox(height: 10),
          const Text('📚 قصص هذه الفئة قادمة قريباً', style: TextStyle(color: Colors.white38)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stories.length,
      itemBuilder: (_, i) {
        final s = stories[i];
        final title = s['title'] ?? 'قصة';
        final text = s['text'] ?? '';
        final summary = text.length > 200 ? '${text.substring(0, 200)}...' : text;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: const Color(0xFF1B2838),
            borderRadius: BorderRadius.circular(20),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _showStoryDetail(context, title, text, tts),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.orangeAccent.withOpacity(0.15)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Colors.orangeAccent.withOpacity(0.05), Colors.transparent],
                  ),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(width: 4, height: 24, decoration: BoxDecoration(
                      color: Colors.orangeAccent, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 12),
                    Expanded(child: Text(title, style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold))),
                    // سبيكر
                    GestureDetector(onTap: () => tts.speak(text, language: 'ar'),
                      child: Icon(Icons.volume_up, color: tts.isSpeaking ? Colors.cyanAccent : Colors.white38, size: 20)),
                  ]),
                  const SizedBox(height: 12),
                  Text(summary, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.7)),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('المزيد ←', style: TextStyle(color: Colors.orangeAccent.withOpacity(0.7), fontSize: 12, fontWeight: FontWeight.bold)),
                  ]),
                ]),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStoryDetail(BuildContext context, String title, String text, TTSService tts) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Text(title, style: const TextStyle(color: Colors.orangeAccent, fontSize: 18, fontWeight: FontWeight.bold))),
              GestureDetector(onTap: () => tts.speak(text, language: 'ar'),
                child: CircleAvatar(backgroundColor: Colors.cyanAccent.withOpacity(0.15), radius: 18,
                  child: Icon(Icons.volume_up, color: Colors.cyanAccent, size: 20))),
              const SizedBox(width: 8),
            ]),
            const Divider(color: Colors.white12),
            Expanded(child: SingleChildScrollView(
              controller: scrollController,
              child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.8)),
            )),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: () { /* المزيد - فتح رابط خفي */ },
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('📖 المزيد من القصة'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent.withOpacity(0.1),
                foregroundColor: Colors.orangeAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.orangeAccent.withOpacity(0.3)))))),
          ]),
        ),
      ),
    );
  }

  // ====== تبويب الإلهام ======
  Widget _buildInspirationTab(AIService ai, TTSService tts, bool isArabic) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        // صندوق الإلهام اليومي
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Colors.amberAccent.withOpacity(0.1), Colors.orangeAccent.withOpacity(0.05)]),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.amberAccent.withOpacity(0.2)),
          ),
          child: Column(children: [
            const Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 40),
            const SizedBox(height: 12),
            Text(
              ai.lastInspiration.isNotEmpty ? ai.lastInspiration : '💡 اضغط على الزر للحصول على رسالة ملهمة',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, height: 1.5),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton.icon(
                onPressed: () async {
                  await ai.generateInspiration(context: 'inspiration_tab');
                  setState(() {});
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('رسالة جديدة'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent.withOpacity(0.15),
                  foregroundColor: Colors.amberAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                backgroundColor: Colors.cyanAccent.withOpacity(0.15), radius: 20,
                child: IconButton(
                  icon: Icon(Icons.volume_up, color: tts.isSpeaking ? Colors.cyanAccent : Colors.white60, size: 20),
                  onPressed: () {
                    if (ai.lastInspiration.isNotEmpty) {
                      tts.speak(ai.lastInspiration, language: 'ar');
                    }
                  },
                ),
              ),
            ]),
          ]),
        ),

        const SizedBox(height: 24),

        // اقتباسات ملهمة
        const Text('🌟 رسائل ملهمة', style: TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ...List.generate(5, (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amberAccent.withOpacity(0.08)),
          ),
          child: Row(children: [
            Container(width: 3, height: 40, decoration: BoxDecoration(
              color: Colors.amberAccent.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 12),
            Expanded(child: Text(
              ['لا تحزن إن الله معنا', 'بعد العسر يسراً', 'فإن مع العسر يسراً', 'واستعينوا بالصبر والصلاة', 'إن الله لا يضيع أجر المحسنين'][i],
              style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5))),
          ]),
        )),

        const SizedBox(height: 20),
        const Opacity(opacity: 0.2, child: Text('🦂 Mirror Scorpion', style: TextStyle(color: Colors.white, fontSize: 12))),
      ]),
    );
  }
}
