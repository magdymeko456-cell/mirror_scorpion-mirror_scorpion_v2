import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/premium_verification_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Map<String, dynamic>> _stories = [];
  final List<Map<String, dynamic>> _inspirations = [];
  final List<Map<String, dynamic>> _hadiths = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
      final inspData = await rootBundle.loadString('assets/data/inspiring.json');
      final hadithData = await rootBundle.loadString('assets/data/hadith.json');
      final storiesJson = jsonDecode(storyData) as List;
      final inspJson = jsonDecode(inspData) as List;
      final hadithJson = jsonDecode(hadithData) as List;
      setState(() {
        _stories.addAll(storiesJson.cast<Map<String, dynamic>>());
        _inspirations.addAll(inspJson.cast<Map<String, dynamic>>());
        _hadiths.addAll(hadithJson.cast<Map<String, dynamic>>());
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

  Widget _buildWatermarkBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      color: Colors.teal.withOpacity(0.08),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.copyright, size: 14, color: Colors.teal),
          const SizedBox(width: 6),
          Text('🦂 ميرور اسكربيون', style: TextStyle(fontSize: 12, color: Colors.teal.shade700, fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Widget _buildStoryCard(Map<String, dynamic> story) {
    final title = story['title'] as String? ?? 'قصة';
    final content = story['content'] as String? ?? '';
    final category = story['category'] as String? ?? 'إسلامي';
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => _showStoryDialog(title, content),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12)),
                    child: Text(category, style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20, color: Colors.teal),
                    onPressed: () => _speakStory(title, content),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(_truncate(content, 100), style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.more_horiz, size: 16),
                    label: const Text('اقرأ المزيد'),
                    onPressed: () => _showStoryDialog(title, content),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    icon: const Icon(Icons.video_library, size: 16),
                    label: const Text('تحويل لفيديو'),
                    onPressed: () => _showStoryDialog(title, content),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showStoryDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.teal.shade50,
                width: double.infinity,
                child: Row(
                  children: [
                    Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                    IconButton(
                      icon: const Icon(Icons.volume_up, size: 20),
                      onPressed: () => _speakStory(title, content),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(content, style: const TextStyle(fontSize: 14, height: 1.8)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            const Icon(Icons.copyright, size: 14, color: Colors.teal),
                            const SizedBox(width: 6),
                            Text('🦂 ميرور اسكربيون', style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _speakStory(String title, String content) {
    final tts = context.read<TTSService>();
    tts.setVoice('voice_sama');
    tts.speak('$title. $content');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 قصص + إلهام + أحاديث'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'قصص', icon: Icon(Icons.book, size: 18)),
            Tab(text: 'إلهام', icon: Icon(Icons.lightbulb, size: 18)),
            Tab(text: 'أحاديث', icon: Icon(Icons.mosque, size: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildWatermarkBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _stories.isEmpty
                          ? const Center(child: Text('لا توجد قصص متاحة'))
                          : ListView.builder(itemCount: _stories.length, padding: const EdgeInsets.only(top: 8), itemBuilder: (_, i) => _buildStoryCard(_stories[i])),
                      _inspirations.isEmpty
                          ? const Center(child: Text('لا توجد إلهامات متاحة'))
                          : ListView.builder(itemCount: _inspirations.length, padding: const EdgeInsets.only(top: 8), itemBuilder: (_, i) => Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Padding(padding: const EdgeInsets.all(16), child: Text('"${_inspirations[i]['quote']}"\n\n— ${_inspirations[i]['author']}', style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic))))),
                      _hadiths.isEmpty
                          ? const Center(child: Text('لا توجد أحاديث متاحة'))
                          : ListView.builder(itemCount: _hadiths.length, padding: const EdgeInsets.only(top: 8), itemBuilder: (_, i) => Card(margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), child: Padding(padding: const EdgeInsets.all(16), child: Text('${_hadiths[i]['text']}\n\n📖 ${_hadiths[i]['source']}', style: const TextStyle(fontSize: 15, height: 1.6))))),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
