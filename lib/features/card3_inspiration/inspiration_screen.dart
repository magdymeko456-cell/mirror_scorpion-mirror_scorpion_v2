import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/premium_verification_service.dart';

class InspirationScreen extends StatefulWidget {
  const InspirationScreen({super.key});

  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen> {
  static final List<AyahWithTafsir> _ayahs = [
    AyahWithTafsir(
      text: 'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      surah: 'الشرح', ayah: 6,
      tafsirJalalayn: 'إن مع الشدة سهولة وراحة',
      tafsirIbnKathir: 'يبشر الله نبيه بأن بعد الشدة فرجاً',
      asbabNuzul: 'نزلت تسلية للنبي صلى الله عليه وسلم',
      arbaeenNawawi: '', hadithQudsi: '', sahihHadith: '',
    ),
    AyahWithTafsir(
      text: 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا',
      surah: 'الطلاق', ayah: '2-3',
      tafsirJalalayn: 'من يخف الله يجعل له مخرجاً من كل ضيق',
      tafsirIbnKathir: 'آية عظيمة فيها بشرى للمتقين',
      asbabNuzul: 'نزلت في شأن المطلقات',
      arbaeenNawawi: '', hadithQudsi: '', sahihHadith: '',
    ),
    AyahWithTafsir(
      text: 'وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ',
      surah: 'البقرة', ayah: 216,
      tafsirJalalayn: 'قد تكرهون شيئاً وهو خير لكم',
      tafsirIbnKathir: 'تسليم الأمر لله فإنه يعلم العواقب',
      asbabNuzul: 'نزلت في شأن الجهاد',
      arbaeenNawawi: '', hadithQudsi: '', sahihHadith: '',
    ),
    AyahWithTafsir(
      text: 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا',
      surah: 'آل عمران', ayah: 8,
      tafsirJalalayn: 'لا تمل قلوبنا عن الحق بعد الهداية',
      tafsirIbnKathir: 'دعاء عظيم ينبغي الإكثار منه',
      asbabNuzul: 'نزلت في دعاء المؤمنين',
      arbaeenNawawi: '', hadithQudsi: '', sahihHadith: '',
    ),
    AyahWithTafsir(
      text: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا * إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      surah: 'الشرح', ayah: '5-6',
      tafsirJalalayn: 'فإن مع الشدة سعة وراحة (كرر للتوكيد)',
      tafsirIbnKathir: 'كرر الله لتطمئن قلوب المؤمنين',
      asbabNuzul: 'نزلت بعد فترة شدة',
      arbaeenNawawi: '', hadithQudsi: '', sahihHadith: '',
    ),
  ];

  AyahWithTafsir? _selectedAyah;
  String _selectedSource = 'تفسير الجلالين';
  final Random _random = Random();

  final List<String> _sources = [
    'تفسير الجلالين', 'تفسير ابن كثير', 'أسباب النزول',
    'الأربعون النووية', 'الحديث القدسي', 'صحيح الأحاديث',
  ];

  @override
  void initState() {
    super.initState();
    _selectedAyah = _ayahs[_random.nextInt(_ayahs.length)];
  }

  void _nextAyah() {
    setState(() {
      _selectedAyah = _ayahs[_random.nextInt(_ayahs.length)];
    });
  }

  String _getTafsirText(AyahWithTafsir ayah) {
    switch (_selectedSource) {
      case 'تفسير الجلالين': return ayah.tafsirJalalayn;
      case 'تفسير ابن كثير': return ayah.tafsirIbnKathir;
      case 'أسباب النزول': return ayah.asbabNuzul;
      case 'الأربعون النووية': return ayah.arbaeenNawawi.isNotEmpty ? ayah.arbaeenNawawi : 'لا يوجد';
      case 'الحديث القدسي': return ayah.hadithQudsi.isNotEmpty ? ayah.hadithQudsi : 'لا يوجد';
      case 'صحيح الأحاديث': return ayah.sahihHadith.isNotEmpty ? ayah.sahihHadith : 'لا يوجد';
      default: return ayah.tafsirJalalayn;
    }
  }

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumVerificationService>();
    final isPro = premium.isPremium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإلهام اليومي'),
        backgroundColor: Colors.teal, foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.shuffle), onPressed: _nextAyah, tooltip: 'آية جديدة'),
        ],
      ),
      body: _selectedAyah == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Container(width: double.infinity, padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(colors: [Colors.teal.shade700, Colors.teal.shade500])),
                      child: Column(children: [
                        const Icon(Icons.auto_stories, color: Colors.white, size: 40), const SizedBox(height: 16),
                        Text(_selectedAyah!.text, style: const TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Traditional Arabic', height: 1.8),
                          textAlign: TextAlign.center, textDirection: TextDirection.rtl),
                        const SizedBox(height: 12),
                        Text('سورة ${_selectedAyah!.surah} (الآية ${_selectedAyah!.ayah})',
                          style: TextStyle(fontSize: 14, color: Colors.teal.shade100)),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(border: Border.all(color: Colors.teal.shade300), borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(value: _selectedSource, isExpanded: true,
                        items: _sources.map((s) => DropdownMenuItem(value: s, child: Row(children: [
                          const Icon(Icons.source, size: 18, color: Colors.teal), const SizedBox(width: 8), Text(s),
                        ]))).toList(),
                        onChanged: (v) { if (v != null) setState(() => _selectedSource = v); },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(width: double.infinity, padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade200)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.menu_book, color: Colors.amber, size: 20), const SizedBox(width: 8),
                        Text('تفسير: $_selectedSource', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown)),
                      ]),
                      const Divider(),
                      Text(_getTafsirText(_selectedAyah!), style: const TextStyle(fontSize: 15, height: 1.6, fontFamily: 'Traditional Arabic'), textDirection: TextDirection.rtl),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    OutlinedButton.icon(onPressed: () {
                      final text = '${_selectedAyah!.text}\n\n${_getTafsirText(_selectedAyah!)}\n\nMirror Scorpion';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
                    }, icon: const Icon(Icons.copy), label: const Text('نسخ')),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(onPressed: _nextAyah, icon: const Icon(Icons.shuffle), label: const Text('آية جديدة')),
                  ]),
                  if (!isPro) ...[
                    const SizedBox(height: 24),
                    Container(padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber)),
                      child: Row(children: [
                        const Icon(Icons.workspace_premium, color: Colors.amber), const SizedBox(width: 8),
                        Expanded(child: Text('جميع الآيات مع التفسير الكامل من 6 مصادر متاحة في Pro', style: TextStyle(color: Colors.brown.shade700, fontSize: 13))),
                        TextButton(onPressed: () => Navigator.pushNamed(context, '/settings'), child: const Text('Pro', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
                      ]),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class AyahWithTafsir {
  final String text; final String surah; final dynamic ayah;
  final String tafsirJalalayn; final String tafsirIbnKathir;
  final String asbabNuzul; final String arbaeenNawawi;
  final String hadithQudsi; final String sahihHadith;
  const AyahWithTafsir({required this.text, required this.surah, required this.ayah,
    required this.tafsirJalalayn, required this.tafsirIbnKathir, required this.asbabNuzul,
    required this.arbaeenNawawi, required this.hadithQudsi, required this.sahihHadith});
}
