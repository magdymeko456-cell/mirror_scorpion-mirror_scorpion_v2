import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/hadith_model.dart';
import 'models/story_model.dart';
import 'services/hadith_service.dart';
import 'services/quote_service.dart';
import 'data/stories_data.dart';

class HadithStoriesScreen extends StatefulWidget {
  const HadithStoriesScreen({super.key});
  @override
  State<HadithStoriesScreen> createState() => _HadithStoriesScreenState();
}

class _HadithStoriesScreenState extends State<HadithStoriesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Hadith State
  Hadith? _currentHadith;
  bool _hadithLoading = false;
  String? _hadithError;
  HadithCollection _selectedCollection = HadithCollection.collections[0];
  bool _showArabicHadith = true;

  // Story State
  String _selectedStoryCategory = 'prophets';
  IslamicStory? _currentStory;
  bool _showArabicStory = true;
  final TextEditingController _creativityController = TextEditingController();

  // Quote State
  IslamicQuote? _currentQuote;
  bool _quoteLoading = false;
  bool _islamicQuoteMode = true;
  final List<IslamicQuote> _savedQuotes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRandomHadith();
    _filterStoriesByCategory();
    _loadRandomQuote();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _creativityController.dispose();
    super.dispose();
  }

  // ===================== HADITH =====================
  Future<void> _loadRandomHadith() async {
    setState(() {
      _hadithLoading = true;
      _hadithError = null;
    });
    try {
      final hadith =
          await HadithService.fetchRandomHadith(_selectedCollection.apiPrefix);
      if (mounted) {
        setState(() {
          _currentHadith = hadith;
          _hadithLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hadithError = e.toString();
          _hadithLoading = false;
        });
      }
    }
  }

  void _selectCollection(HadithCollection collection) {
    setState(() => _selectedCollection = collection);
    _loadRandomHadith();
  }

  // ===================== STORIES =====================
  void _filterStoriesByCategory() {
    final filtered = StoriesData.stories
        .where((s) => s.category == _selectedStoryCategory)
        .toList();
    if (filtered.isNotEmpty) {
      final random = Random();
      setState(() => _currentStory = filtered[random.nextInt(filtered.length)]);
    } else {
      setState(() => _currentStory = null);
    }
  }

  void _nextStory() {
    if (_selectedStoryCategory == 'creativity') return;
    _filterStoriesByCategory();
  }

  bool _isContentSafe(String text) {
    final bannedWords = [
      'تنمر', 'سخرية', 'شتيمة', 'كره', 'عنصرية', 'طائفية'
    ];
    for (var word in bannedWords) {
      if (text.contains(word)) return false;
    }
    return true;
  }

  void _generateCreativeStory() {
    final userMood = _creativityController.text.trim();
    if (userMood.isEmpty) return;
    if (!_isContentSafe(userMood)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('عذراً، يجب أن يكون المحتوى خالياً من الكراهية أو التنمر أو الإساءة.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('جاري إلهام قصة خاصة بمزاجك...')),
    );
  }

  // ===================== QUOTES =====================
  Future<void> _loadRandomQuote() async {
    setState(() => _quoteLoading = true);
    try {
      IslamicQuote quote;
      if (_islamicQuoteMode) {
        quote = QuoteService.getRandomIslamicQuote();
      } else {
        quote = await QuoteService.fetchZenQuote();
      }
      if (mounted) setState(() { _currentQuote = quote; _quoteLoading = false; });
    } catch (e) {
      final quote = QuoteService.getRandomIslamicQuote();
      if (mounted) setState(() { _currentQuote = quote; _quoteLoading = false; });
    }
  }

  void _toggleQuoteMode() {
    setState(() => _islamicQuoteMode = !_islamicQuoteMode);
    _loadRandomQuote();
  }

  void _saveQuote() {
    if (_currentQuote != null && !_savedQuotes.contains(_currentQuote)) {
      setState(() => _savedQuotes.add(_currentQuote!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حفظ الاقتباس')),
      );
    }
  }

  void _removeSavedQuote(int index) {
    setState(() => _savedQuotes.removeAt(index));
  }

  // ===================== HADITH COPY (FIXED) =====================
  void _copyHadithText() {
    if (_currentHadith != null) {
      Clipboard.setData(ClipboardData(text: _currentHadith!.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ الحديث')),
      );
    }
  }

  void _copyQuoteText() {
    if (_currentQuote != null) {
      Clipboard.setData(ClipboardData(text: _currentQuote!.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم نسخ الاقتباس')),
      );
    }
  }

  // ===================== BUILD UI =====================
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('📖 قصص وأحاديث وإلهام'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(icon: Icon(Icons.mosque), text: 'أحاديث'),
              Tab(icon: Icon(Icons.auto_stories), text: 'قصص'),
              Tab(icon: Icon(Icons.lightbulb_outline), text: 'إلهام'),
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
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildHadithTab(),
              _buildStoriesTab(),
              _buildInspirationTab(),
            ],
          ),
        ),
      ),
    );
  }

  // ===================== HADITH TAB =====================
  Widget _buildHadithTab() {
    return Column(
      children: [
        // Collection selector
        Container(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: HadithCollection.collections.map((c) {
                final selected = c == _selectedCollection;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(c.name, style: const TextStyle(fontSize: 12)),
                    selected: selected,
                    selectedColor: Colors.amber.shade700,
                    onSelected: (_) => _selectCollection(c),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Hadith content
        Expanded(
          child: _hadithLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentHadith != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.amber.withOpacity(0.2)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.format_quote, size: 40, color: Colors.amber),
                            const SizedBox(height: 12),
                            Text(
                              _currentHadith!.text,
                              style: const TextStyle(fontSize: 18, height: 1.8, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentHadith!.grade ?? _currentHadith!.bookName,
                              style: TextStyle(fontSize: 14, color: Colors.amber.shade300),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.content_copy),
                                  onPressed: _copyHadithText,
                                  tooltip: 'نسخ',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.shuffle),
                                  onPressed: _loadRandomHadith,
                                  tooltip: 'التالي',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up),
                                  onPressed: () {},
                                  tooltip: 'استماع',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(child: Text('لا توجد أحاديث متاحة')),
        ),
      ],
    );
  }

  // ===================== STORIES TAB =====================
  Widget _buildStoriesTab() {
    return Column(
      children: [
        // Category selector
        Container(
          padding: const EdgeInsets.all(8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _storyChip('prophets', 'الأنبياء'),
                _storyChip('women', 'النساء'),
                _storyChip('nations', 'الأقوام'),
                _storyChip('animals', 'الحيوانات'),
                _storyChip('human', 'الإنسان'),
                _storyChip('creativity', '🖊 إبداع'),
              ],
            ),
          ),
        ),
        // Content
        Expanded(
          child: _selectedStoryCategory == 'creativity'
              ? _buildCreativityEditor()
              : _currentStory != null
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _currentStory!.titleAr,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _currentStory!.storyAr,
                              style: const TextStyle(fontSize: 16, height: 1.8, color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.volume_up),
                                  onPressed: () {},
                                  tooltip: 'استماع',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.movie),
                                  onPressed: () {},
                                  tooltip: 'مشاهدة فيديو',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next),
                                  onPressed: _nextStory,
                                  tooltip: 'التالي',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )
                  : const Center(child: Text('اختر تصنيفاً للقصص')),
        ),
      ],
    );
  }

  Widget _storyChip(String category, String label) {
    final selected = _selectedStoryCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ChoiceChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: selected,
        selectedColor: Colors.amber.shade700,
        onSelected: (_) {
          setState(() => _selectedStoryCategory = category);
          _filterStoriesByCategory();
        },
      ),
    );
  }

  Widget _buildCreativityEditor() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text(
            '🖊 محطة الإبداع',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.amber),
          ),
          const SizedBox(height: 12),
          const Text(
            'اكتب مشاعرك أو فكرتك وسنلهمك قصة',
            style: TextStyle(color: Colors.white54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _creativityController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'مثال: قصة عن الصبر في مواجهة الصعاب...',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 12),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _generateCreativeStory,
            icon: const Icon(Icons.auto_fix_high, size: 18),
            label: const Text('توليد القصة الآن'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ===================== INSPIRATION TAB =====================
  Widget _buildInspirationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildModeToggle(),
          const SizedBox(height: 16),
          _quoteLoading
              ? const Center(child: CircularProgressIndicator())
              : _currentQuote != null
                  ? _buildQuoteCard()
                  : const Center(child: Text('فشل تحميل الاقتباس')),
          const SizedBox(height: 20),
          if (_savedQuotes.isNotEmpty) _buildSavedQuotesSection(),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () { if (!_islamicQuoteMode) _toggleQuoteMode(); },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _islamicQuoteMode ? Colors.green.shade700.withOpacity(0.4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.mosque, size: 16, color: _islamicQuoteMode ? Colors.green.shade300 : Colors.white54),
                    const SizedBox(width: 6),
                    Text('اقتباسات إسلامية',
                      style: TextStyle(color: _islamicQuoteMode ? Colors.green.shade300 : Colors.white54,
                        fontWeight: _islamicQuoteMode ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () { if (_islamicQuoteMode) _toggleQuoteMode(); },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !_islamicQuoteMode ? Colors.blue.shade700.withOpacity(0.4) : Colors.transparent,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.light_mode, size: 16, color: !_islamicQuoteMode ? Colors.blue.shade300 : Colors.white54),
                    const SizedBox(width: 6),
                    Text('عام',
                      style: TextStyle(color: !_islamicQuoteMode ? Colors.blue.shade300 : Colors.white54,
                        fontWeight: !_islamicQuoteMode ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuoteCard() {
    final quote = _currentQuote!;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [const Color(0xFF1A3A2A).withOpacity(0.8), const Color(0xFF0F2A1A).withOpacity(0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade300.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.format_quote, size: 40, color: Colors.green.shade300.withOpacity(0.3)),
            const SizedBox(height: 8),
            Text(
              quote.text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Colors.white,
                fontFamily: 'serif', fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person, size: 14, color: Colors.green.shade300),
                  const SizedBox(width: 6),
                  Text(quote.attribution ?? '',
                    style: TextStyle(color: Colors.green.shade300, fontSize: 13, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.content_copy, 'نسخ', _copyQuoteText),
                _buildActionButton(Icons.bookmark_add, 'حفظ', _saveQuote),
                _buildActionButton(Icons.shuffle, 'تجديد', _loadRandomQuote),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, size: 20, color: Colors.green.shade300),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSavedQuotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.bookmarks, size: 18, color: Colors.amber.shade300),
            const SizedBox(width: 8),
            Text('المحفوظات (${_savedQuotes.length})',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _savedQuotes.length,
            itemBuilder: (context, index) {
              final saved = _savedQuotes[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(saved.text, maxLines: 3, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic)),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(saved.attribution ?? '',
                              style: TextStyle(fontSize: 9, color: Colors.green.shade300.withOpacity(0.7)), overflow: TextOverflow.ellipsis),
                          ),
                          GestureDetector(
                            onTap: () => _removeSavedQuote(index),
                            child: Icon(Icons.delete_outline, size: 14, color: Colors.red.shade400),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
