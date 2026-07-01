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
