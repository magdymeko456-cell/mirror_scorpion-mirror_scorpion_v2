import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/tts_service.dart';

/// عنصر قراءة واحد (حديث / قصة / سبب نزول)
class _StoryItem {
  final String title;
  final String body;
  final String subtitle;
  const _StoryItem({
    required this.title,
    required this.body,
    this.subtitle = '',
  });
}

/// تعريف فئة قراءة: ملف JSON + تسمية + أيقونة + وصف
class _StoryCategory {
  final String asset;
  final String label;
  final IconData icon;
  final String description;
  const _StoryCategory({
    required this.asset,
    required this.label,
    required this.icon,
    required this.description,
  });
}

const List<_StoryCategory> _categories = [
  _StoryCategory(
    asset: 'assets/data/quran_stories.json',
    label: 'قصص قرآنية',
    icon: Icons.menu_book,
    description: 'قصص الأنبياء والأمم كما وردت في القرآن',
  ),
  _StoryCategory(
    asset: 'assets/data/prophet_stories_ibn_kathir.json',
    label: 'قصص الأنبياء — ابن كثير',
    icon: Icons.history_edu,
    description: 'سير الأنبياء برواية ابن كثير',
  ),
  _StoryCategory(
    asset: 'assets/data/stories.json',
    label: 'قصص ملهمة',
    icon: Icons.emoji_objects,
    description: 'حكايات ملهمة وعبر من الحياة',
  ),
  _StoryCategory(
    asset: 'assets/data/arbaeen_nawawi.json',
    label: 'الأربعون النووية',
    icon: Icons.format_list_numbered,
    description: 'أربعون حديثاً من جوامع الكلم',
  ),
  _StoryCategory(
    asset: 'assets/data/hadith_qudsi.json',
    label: 'الأحاديث القدسية',
    icon: Icons.star,
    description: 'أقوال الله تعالى على لسان نبيه ﷺ',
  ),
  _StoryCategory(
    asset: 'assets/data/hadiths.json',
    label: 'أحاديث نبوية',
    icon: Icons.auto_stories,
    description: 'من جوامع الكلم مع شرح معانيها',
  ),
  _StoryCategory(
    asset: 'assets/data/asbab_nuzul.json',
    label: 'أسباب النزول',
    icon: Icons.explore,
    description: 'لماذا نزلت آيات القرآن الكريم',
  ),
];

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  _StoryCategory? _activeCategory;
  List<_StoryItem> _items = const [];
  bool _loading = false;
  String? _loadError;

  // القصص الأساسية الأصلية — تُعرض تلقائياً لو فشل تحميل أي مكتبة
  List<_StoryItem> _legacyItems() => const [
    _StoryItem(
      title: 'الإصرار والنجاح',
      body: 'المحاولة المستمرة هي سر النجاح. لا يهم كم مرة سقطت، بل المهم كم مرة نهضت لتكمل طريقك نحو القمة والتحدي.',
    ),
    _StoryItem(
      title: 'قيمة الوقت',
      body: 'الوقت هو العملة الأغلى في حياتنا. من يملك زمام وقته وتنظيمه، يملك مفاتيح المستقبل وبناء الإمبراطوريات الشخصية.',
    ),
    _StoryItem(
      title: 'الهدوء الداخلي',
      body: 'في وسط عواصف الحياة الصاخبة، ابحث عن سلامك الداخلي، وثق تماماً أن ما كُتب لك سيأتيك رغماً عن كل الظروف والمصاعب.',
    ),
  ];

  Future<List<_StoryItem>> _loadItems(String asset) async {
    final raw = await rootBundle.loadString(asset);
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return _parseItems(asset, decoded);
  }

  String _pick(dynamic item, List<String> keys) {
    if (item is! Map) return '';
    for (final k in keys) {
      final v = item[k];
      if (v is String && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  List<_StoryItem> _parseItems(String asset, List<dynamic> list) {
    return list.map((raw) {
      if (raw is! Map) return null;
      final title = _pick(raw, ['title']);
      if (title.isEmpty) return null;
      String body;
      String subtitle = '';
      if (asset.contains('asbab')) {
        final surah = _pick(raw, ['surah']);
        final verse = _pick(raw, ['verse_range']);
        if (surah.isNotEmpty) {
          subtitle = 'سورة $surah${verse.isEmpty ? '' : ' • الآية $verse'}';
        }
        final parts = <String>[
          _pick(raw, ['context_before']),
          _pick(raw, ['context_during']),
          _pick(raw, ['context_after']),
          _pick(raw, ['revealed_for']),
          _pick(raw, ['summary_10_lines']),
        ];
        body = parts.where((p) => p.isNotEmpty).join('\n\n');
      } else if (asset.contains('arbaeen')) {
        final num = _pick(raw, ['hadith_number']);
        if (num.isNotEmpty) subtitle = 'الحديث رقم $num';
        body = _pick(raw, ['text']);
        final meanings = _pick(raw, ['word_meanings']);
        if (meanings.isNotEmpty) body += '\n\nشرح الكلمات:\n$meanings';
      } else if (asset.contains('hadith')) {
        body = _pick(raw, ['text']);
        final meanings = _pick(raw, ['word_meanings']);
        if (meanings.isNotEmpty) body += '\n\nشرح الكلمات:\n$meanings';
      } else {
        body = _pick(raw, ['summary_10_lines']);
        final moral = _pick(raw, ['moral_lesson']);
        if (moral.isNotEmpty) body += '\n\nالعبرة:\n$moral';
      }
      if (body.trim().isEmpty) return null;
      return _StoryItem(title: title, body: body.trim(), subtitle: subtitle);
    }).whereType<_StoryItem>().toList();
  }

  Future<void> _openCategory(_StoryCategory cat) async {
    setState(() {
      _activeCategory = cat;
      _loading = true;
      _loadError = null;
      _items = const [];
    });
    try {
      final items = await _loadItems(cat.asset);
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _items = _legacyItems();
        _loading = false;
        _loadError = 'تعذر تحميل مكتبة «${cat.label}» — يتم عرض القصص الأساسية.';
      });
    }
  }

  void _closeCategory() {
    setState(() {
      _activeCategory = null;
      _items = const [];
      _loading = false;
      _loadError = null;
    });
  }

  void _openItem(_StoryItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _StoryDetailScreen(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          _activeCategory?.label ?? 'قصص وإلهام ميرور',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        leading: _activeCategory == null
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.orangeAccent),
                onPressed: _closeCategory,
              ),
      ),
      body: _activeCategory == null
          ? _buildCategories()
          : _loading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orangeAccent))
              : _buildItems(),
    );
  }

  Widget _buildCategories() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.0,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final c = _categories[index];
        return InkWell(
          onTap: () => _openCategory(c),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(c.icon, color: Colors.orangeAccent, size: 34),
                const SizedBox(height: 10),
                Text(
                  c.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  c.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildItems() {
    return Column(
      children: [
        if (_loadError != null)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF2A1B1B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _loadError!,
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
              textDirection: TextDirection.rtl,
            ),
          ),
        Expanded(
          child: _items.isEmpty
              ? const Center(
                  child: Text('لا توجد عناصر في هذه المكتبة',
                      style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  itemBuilder: (context, index) => _itemCard(_items[index]),
                ),
        ),
      ],
    );
  }

  Widget _itemCard(_StoryItem s) {
    return InkWell(
      onTap: () => _openItem(s),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B2838),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orangeAccent.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    s.title,
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.orangeAccent),
                  onPressed: () =>
                      Provider.of<TTSService>(context, listen: false)
                          .speak(s.body),
                ),
              ],
            ),
            if (s.subtitle.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                s.subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 12),
                textDirection: TextDirection.rtl,
              ),
            ],
            const SizedBox(height: 8),
            Text(
              s.body,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}

/// صفحة التفاصيل: النص كاملاً + استماع + نسخ
class _StoryDetailScreen extends StatelessWidget {
  final _StoryItem item;
  const _StoryDetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    final tts = Provider.of<TTSService>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(item.title,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up, color: Colors.orangeAccent),
            onPressed: () => tts.speak(item.body),
          ),
          IconButton(
            icon: const Icon(Icons.copy, color: Colors.white70),
            onPressed: () async {
              await Clipboard.setData(
                  ClipboardData(text: '${item.title}\n\n${item.body}'));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('✅ تم نسخ النص')));
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.subtitle.isNotEmpty) ...[
              Text(
                item.subtitle,
                style: TextStyle(
                  color: Colors.orangeAccent.withOpacity(0.8),
                  fontSize: 14,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(height: 12),
            ],
            SelectableText(
              item.body,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.8,
              ),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
