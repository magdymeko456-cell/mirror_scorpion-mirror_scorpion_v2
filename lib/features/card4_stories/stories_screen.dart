import 'package:flutter/material.dart';
import 'dart:math';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  String _selectedCategory = 'الكل';
  bool _isPremium = false; // يتغير من الإعدادات

  final List<String> _categories = [
    'الكل', 'قصص القرآن', 'الأمم السابقة', 'قصص الأنبياء',
    'أسباب النزول', 'الأربعين النووية', 'أحاديث قدسية'
  ];

  // المصادر على GitHub — الروابط الحقيقية
  static const Map<String, String> _sourceBooks = {
    'تفسير الجلالين': 'https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/blob/main/assets/data/quran_stories.json',
    'تفسير ابن كثير': 'https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/blob/main/assets/data/prophet_stories_ibn_kathir.json',
    'أسباب النزول': 'https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/blob/main/assets/data/asbab_nuzul.json',
    'الأربعين النووية': 'https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/blob/main/assets/data/arbaeen_nawawi.json',
    'الأحاديث القدسية': 'https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/blob/main/assets/data/hadith_qudsi.json',
    'الأحاديث النبوية': 'https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/blob/main/assets/data/hadiths.json',
  };

  final Map<String, List<Map<String, String>>> _stories = {
    'قصص القرآن': [
      {'title': 'قصة أصحاب الكهف', 'subtitle': 'سورة الكهف - الفتية الذين آمنوا', 'ref': 'quran_stories#kahf', 'source': 'تفسير ابن كثير'},
      {'title': 'قصة موسى والخضر', 'subtitle': 'سورة الكهف - رحلة العلم', 'ref': 'quran_stories#musa_khidr', 'source': 'تفسير الجلالين'},
      {'title': 'قصة ذو القرنين', 'subtitle': 'سورة الكهف - الملك الصالح', 'ref': 'quran_stories#dhulqarnain', 'source': 'تفسير ابن كثير'},
      {'title': 'قصة سليمان والهدهد', 'subtitle': 'سورة النمل', 'ref': 'quran_stories#sulaiman', 'source': 'تفسير الجلالين'},
      {'title': 'قصة يوسف عليه السلام', 'subtitle': 'أحسن القصص', 'ref': 'quran_stories#yusuf', 'source': 'تفسير ابن كثير'},
      {'title': 'قصة مريم وعيسى', 'subtitle': 'سورة مريم', 'ref': 'quran_stories#maryam', 'source': 'تفسير الجلالين'},
    ],
    'الأمم السابقة': [
      {'title': 'قوم نوح', 'subtitle': 'الطوفان العظيم', 'ref': 'prophet_stories#nuh', 'source': 'تفسير ابن كثير'},
      {'title': 'قوم عاد', 'subtitle': 'قوم هود - ذات العماد', 'ref': 'prophet_stories#hud', 'source': 'تفسير ابن كثير'},
      {'title': 'قوم ثمود', 'subtitle': 'قوم صالح - الناقة', 'ref': 'prophet_stories#salih', 'source': 'تفسير ابن كثير'},
      {'title': 'قوم لوط', 'subtitle': 'المؤتفكات', 'ref': 'prophet_stories#lut', 'source': 'تفسير الجلالين'},
      {'title': 'قوم فرعون', 'subtitle': 'موسى وهامان', 'ref': 'prophet_stories#fir'awn', 'source': 'تفسير ابن كثير'},
      {'title': 'أصحاب الأخدود', 'subtitle': 'قصة الإيمان في النار', 'ref': 'quran_stories#ukhdud', 'source': 'تفسير الجلالين'},
    ],
    'قصص الأنبياء': [
      {'title': 'آدم عليه السلام', 'subtitle': 'أبو البشر', 'ref': 'prophet_stories#adam', 'source': 'تفسير ابن كثير'},
      {'title': 'نوح عليه السلام', 'subtitle': 'أول العزم', 'ref': 'prophet_stories#nuh_full', 'source': 'تفسير ابن كثير'},
      {'title': 'إبراهيم عليه السلام', 'subtitle': 'خليل الرحمن', 'ref': 'prophet_stories#ibrahim', 'source': 'تفسير ابن كثير'},
      {'title': 'موسى عليه السلام', 'subtitle': 'كليم الله', 'ref': 'prophet_stories#musa', 'source': 'تفسير ابن كثير'},
      {'title': 'عيسى عليه السلام', 'subtitle': 'المسيح', 'ref': 'prophet_stories#isa', 'source': 'تفسير الجلالين'},
      {'title': 'محمد ﷺ', 'subtitle': 'خاتم الأنبياء', 'ref': 'prophet_stories#muhammad', 'source': 'السيرة النبوية'},
    ],
    'أسباب النزول': [
      {'title': 'سبب نزول سورة الفاتحة', 'subtitle': 'أم الكتاب', 'ref': 'asbab#fatiha', 'source': 'أسباب النزول'},
      {'title': 'آية الكرسي', 'subtitle': 'أعظم آية', 'ref': 'asbab#kursi', 'source': 'أسباب النزول'},
      {'title': 'سورة الإخلاص', 'subtitle': 'التوحيد الخالص', 'ref': 'asbab#ikhlas', 'source': 'أسباب النزول'},
      {'title': 'سورة الكوثر', 'subtitle': 'نهر في الجنة', 'ref': 'asbab#kawthar', 'source': 'أسباب النزول'},
    ],
    'الأربعين النووية': [
      {'title': 'الحديث الأول: الأعمال بالنيات', 'subtitle': 'حديث 1', 'ref': 'arbaeen#1', 'source': 'الأربعين النووية'},
      {'title': 'الحديث التاسع: ما نهيتكم عنه', 'subtitle': 'حديث 9', 'ref': 'arbaeen#9', 'source': 'الأربعين النووية'},
      {'title': 'الحديث الثالث عشر: لا يؤمن أحدكم', 'subtitle': 'حديث 13', 'ref': 'arbaeen#13', 'source': 'الأربعين النووية'},
      {'title': 'الحديث الأربعون: كن في الدنيا', 'subtitle': 'حديث 40', 'ref': 'arbaeen#40', 'source': 'الأربعين النووية'},
    ],
    'أحاديث قدسية': [
      {'title': 'أنا عند ظن عبدي بي', 'subtitle': 'الحديث القدسي', 'ref': 'qudsi#dhann', 'source': 'الأحاديث القدسية'},
      {'title': 'يا عبادي إني حرمت الظلم', 'subtitle': 'الحديث القدسي', 'ref': 'qudsi#dhulm', 'source': 'الأحاديث القدسية'},
      {'title': 'الرحمة تغلب الغضب', 'subtitle': 'الحديث القدسي', 'ref': 'qudsi#rahma', 'source': 'الأحاديث القدسية'},
      {'title': 'سبقت رحمتي غضبي', 'subtitle': 'الحديث القدسي', 'ref': 'qudsi#sabaqat', 'source': 'الأحاديث القدسية'},
    ],
  };

  void _openStory(Map<String, String> story) {
    final ref = story['ref'] ?? '';
    final source = story['source'] ?? '';

    if (_isPremium) {
      // 💎 PRO: تحميل على الجهاز — سيتم تخزين الملف محلياً
      _downloadForOffline(story);
    } else {
      // 🔗 النسخة العادية: الرابط الخفي يفتح في المتصفح
      _showHiddenLink(story);
    }
  }

  void _showHiddenLink(Map<String, String> story) {
    final bookKey = _sourceBooks.keys.firstWhere(
      (k) => story['source']?.contains(k) ?? false,
      orElse: () => 'تفسير الجلالين',
    );
    final baseUrl = _sourceBooks[bookKey] ?? 'https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2';
    final ref = story['ref'] ?? '';
    final url = '$baseUrl#$ref';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          const Icon(Icons.link, color: Colors.cyanAccent, size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(story['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 16), overflow: TextOverflow.ellipsis)),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📖 ${story['source'] ?? ''}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('🔗 الرابط الخفي:', style: TextStyle(color: Colors.white38, fontSize: 10)),
              const SizedBox(height: 4),
              Text(url, style: const TextStyle(color: Colors.cyanAccent, fontSize: 9), maxLines: 4, overflow: TextOverflow.ellipsis),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.diamond, color: Colors.amber, size: 14),
              const SizedBox(width: 6),
              const Expanded(child: Text('💎 برو: حمِّل الكتاب كاملاً بدون إنترنت', style: TextStyle(color: Colors.amber, fontSize: 10))),
            ]),
          ),
        ]),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              // محاكاة فتح الرابط
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('📖 يتم فتح "${story['title']}"...'), duration: const Duration(seconds: 2)),
              );
            },
            icon: const Icon(Icons.open_in_browser, color: Colors.cyanAccent, size: 16),
            label: const Text('فتح في المتصفح', style: TextStyle(color: Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  void _downloadForOffline(Map<String, String> story) {
    // 💎 PRO: تحميل الكتاب كاملاً
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('💎 تحميل برو', style: TextStyle(color: Color(0xFFFFD700))),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          const LinearProgressIndicator(color: Color(0xFFFFD700), backgroundColor: Colors.white12),
          const SizedBox(height: 12),
          Text('📥 جاري تحميل "${story['title']}"...', style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          Text('${story['source'] ?? ''}', style: const TextStyle(color: Colors.orangeAccent, fontSize: 11)),
          const SizedBox(height: 12),
          const Text('سيتم حفظ الكتاب على جهازك للقراءة الأوفلاين', style: TextStyle(color: Colors.white38, fontSize: 10)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('تم', style: TextStyle(color: Color(0xFFFFD700)))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('📚 قصص وإلهام', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // Premium badge
          GestureDetector(
            onTap: () => setState(() => _isPremium = !_isPremium),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isPremium ? const Color(0xFFFFD700).withOpacity(0.2) : Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _isPremium ? const Color(0xFFFFD700) : Colors.white24),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.diamond, size: 14, color: _isPremium ? const Color(0xFFFFD700) : Colors.white38),
                const SizedBox(width: 4),
                Text(_isPremium ? 'برو' : 'عادي', style: TextStyle(fontSize: 11, color: _isPremium ? const Color(0xFFFFD700) : Colors.white38, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ],
      ),
      body: Column(children: [
        // Categories
        Container(
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _categories.map((cat) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(cat, style: TextStyle(color: _selectedCategory == cat ? Colors.black : Colors.white, fontSize: 13)),
                selected: _selectedCategory == cat,
                selectedColor: Colors.amberAccent,
                backgroundColor: Colors.white.withOpacity(0.05),
                onSelected: (v) => setState(() => _selectedCategory = cat),
              ),
            )).toList(),
          ),
        ),
        // Source books bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: _sourceBooks.entries.map((e) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => _showBookLink(e.key, e.value),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.05))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.menu_book, size: 12, color: Colors.orangeAccent),
                    const SizedBox(width: 4),
                    Text(e.key, style: const TextStyle(color: Colors.orangeAccent, fontSize: 10)),
                  ]),
                ),
              ),
            )).toList()),
          ),
        ),
        const Divider(color: Colors.white12, height: 1),
        // Stories list
        Expanded(
          child: _selectedCategory == 'الكل'
              ? ListView(
                  padding: const EdgeInsets.all(12),
                  children: _categories.where((c) => c != 'الكل').map((cat) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(children: [
                          Text(cat, style: const TextStyle(color: Colors.orangeAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                          const Spacer(),
                          Icon(Icons.link, size: 12, color: Colors.white.withOpacity(0.2)),
                        ]),
                      ),
                      ...(_stories[cat] ?? []).map((story) => _buildStoryCard(story)),
                      const SizedBox(height: 8),
                    ],
                  )).toList(),
                )
              : ListView(
                  padding: const EdgeInsets.all(12),
                  children: (_stories[_selectedCategory] ?? []).map((story) => _buildStoryCard(story)).toList(),
                ),
        ),
      ]),
    );
  }

  void _showBookLink(String bookName, String url) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('📖 $bookName', style: const TextStyle(color: Colors.orangeAccent, fontSize: 16)),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('المصدر على GitHub:', style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(url, style: const TextStyle(color: Colors.cyanAccent, fontSize: 9), maxLines: 4, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Icon(Icons.info_outline, color: _isPremium ? const Color(0xFFFFD700) : Colors.blueAccent, size: 14),
            const SizedBox(width: 6),
            Expanded(child: Text(
              _isPremium ? '💎 برو: اضغط لتحميل الكتاب كاملاً' : '🔗 العادي: افتح الرابط في المتصفح',
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            )),
          ]),
        ]),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (_isPremium) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('📥 جاري تحميل $bookName...')));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('🌐 فتح $url')));
              }
            },
            child: Text(_isPremium ? '📥 تحميل' : '🌐 فتح', style: TextStyle(color: _isPremium ? const Color(0xFFFFD700) : Colors.cyanAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard(Map<String, String> story) {
    final colors = [Colors.blueAccent, Colors.cyanAccent, Colors.tealAccent, Colors.orangeAccent, Colors.purpleAccent, Colors.greenAccent];
    final color = colors[Random().nextInt(colors.length)];
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(0.08), Colors.transparent]),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(Icons.auto_stories, color: color),
        title: Text(story['title'] ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text('${story['subtitle'] ?? ''} • ${story['source'] ?? ''}', style: const TextStyle(color: Colors.white54, fontSize: 11)),
        trailing: Icon(
          _isPremium ? Icons.download : Icons.link,
          size: 18,
          color: _isPremium ? const Color(0xFFFFD700) : Colors.white24,
        ),
        onTap: () => _openStory(story),
      ),
    );
  }
}
