import 'dart:math';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/premium_verification_service.dart';
import '../../services/tts_service.dart';

class InspirationScreen extends StatefulWidget {
  const InspirationScreen({super.key});
  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen> {
  static final List<Map<String, String>> _ayahs = [
    {'text': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'surah': 'الشرح', 'ayah': '6', 'tafsir': 'إن مع الشدة سهولة وراحة', 'asbab': 'نزلت تسلية للنبي صلى الله عليه وسلم'},
    {'text': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا', 'surah': 'الطلاق', 'ayah': '2-3', 'tafsir': 'من يخف الله يجعل له مخرجاً من كل ضيق', 'asbab': 'نزلت في شأن المطلقات'},
    {'text': 'وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ', 'surah': 'البقرة', 'ayah': '216', 'tafsir': 'قد تكرهون شيئاً وهو خير لكم', 'asbab': 'نزلت في شأن الجهاد'},
    {'text': 'إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنفُسِهِمْ', 'surah': 'الرعد', 'ayah': '11', 'tafsir': 'لا يزيل الله نعمة عن قوم حتى يغيروا ما في أنفسهم', 'asbab': 'تذكير بالتغيير الذاتي'},
    {'text': 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا', 'surah': 'البقرة', 'ayah': '250', 'tafsir': 'دعاء الأنبياء للثبات في الشدائد', 'asbab': 'دعاء المؤمنين في القتال'},
    {'text': 'لَا تَحْزَنْ إِنَّ اللَّهَ مَعَنَا', 'surah': 'التوبة', 'ayah': '40', 'tafsir': 'كلمة النبي لأبي بكر في الغار', 'asbab': 'نزلت في الهجرة'},
    {'text': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا', 'surah': 'الشرح', 'ayah': '5', 'tafsir': 'تكرار للتأكيد على أن الفرج قريب', 'asbab': 'تثبيت لفؤاد النبي'},
    {'text': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ', 'surah': 'الطلاق', 'ayah': '3', 'tafsir': 'من يفوض أمره لله كفاه كل شيء', 'asbab': 'وعد الله للمتوكلين'},
  ];

  final List<String> _inspirationalMessages = [
    'لا تقلق فإن الله معك، وهو أرحم بك من أمك.',
    'ما أظلمت الدنيا إلا لتشرق شمس جديدة.',
    'الصبر مفتاح الفرج، والثمرة الحلوة تحتاج وقتاً.',
    'استعن بالله ولا تعجز، كل شيء بقدر.',
    'اليوم هم وغداً فرج، هكذا هي الأيام.',
    'لا تيأس فإن الله يسمعك ويراك.',
    'بعد العسر يسراً، وبعد الضيق فرجاً.',
    'ثق بالله يكفيك، وتوكل عليه يرضيك.',
    'أنت أقوى مما تظن، وأعز مما تعتقد.',
    'كل ما يحدث لك اليوم هو تمهيد لأجمل أيامك.',
  ];

  Map<String, String>? _selectedAyah;
  String _selectedSource = 'تفسير الجلالين';
  final Random _random = Random();
  bool _showAIMessage = false;
  String _aiMessage = '';

  @override
  void initState() { super.initState(); _nextAyah(); _generateAIMessage(); }

  void _nextAyah() { setState(() { _selectedAyah = _ayahs[_random.nextInt(_ayahs.length)]; }); }

  void _generateAIMessage() {
    final idx = _random.nextInt(_inspirationalMessages.length);
    _aiMessage = _inspirationalMessages[idx];
    _showAIMessage = true;
  }

  @override
  Widget build(BuildContext context) {
    final premium = context.watch<PremiumVerificationService>();
    final tts = context.watch<TTSService>();
    final isPro = premium.isPremium;

    return Scaffold(
      appBar: AppBar(title: const Text('الإلهام اليومي'), backgroundColor: Colors.teal, foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.shuffle), onPressed: () { _nextAyah(); _generateAIMessage(); }, tooltip: 'آية جديدة')]),
      body: _selectedAyah == null ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
          // Ayah card
          Card(elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Container(width: double.infinity, padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), gradient: LinearGradient(colors: [Colors.teal.shade700, Colors.teal.shade500])),
              child: Column(children: [
                const Icon(Icons.auto_stories, color: Colors.white, size: 40),
                const SizedBox(height: 16),
                Text(_selectedAyah!['text']!, style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Traditional Arabic', height: 1.8), textAlign: TextAlign.center, textDirection: TextDirection.rtl),
                const SizedBox(height: 12),
                Text('سورة ${_selectedAyah!['surah']} (الآية ${_selectedAyah!['ayah']})', style: TextStyle(fontSize: 14, color: Colors.teal.shade100)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: const Icon(Icons.volume_up, color: Colors.teal), onPressed: () => tts.speak(_selectedAyah!['text'] ?? '')),
            IconButton(icon: const Icon(Icons.copy, color: Colors.teal), onPressed: () {
              Clipboard.setData(ClipboardData(text: '${_selectedAyah!['text']}\n\n${_getTafsir()}\n\n- Mirror Scorpion'));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ')));
            }),
          ]),
          const SizedBox(height: 8),
          // Tafsir
          Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade200)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [const Icon(Icons.menu_book, color: Colors.amber, size: 20), const SizedBox(width: 8), Text('تفسير: $_selectedSource', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown))]),
              const Divider(),
              Text(_getTafsir(), style: const TextStyle(fontSize: 15, height: 1.6), textDirection: TextDirection.rtl),
              if (_selectedAyah!['asbab'] != null && _selectedAyah!['asbab']!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(children: [const Icon(Icons.info_outline, color: Colors.teal, size: 16), const SizedBox(width: 4), Text('سبب النزول: ${_selectedAyah!['asbab']}', style: TextStyle(color: Colors.teal.shade700, fontSize: 13))]),
              ],
            ]),
          ),
          const SizedBox(height: 16),
          // AI Inspiration
          if (_showAIMessage) Container(width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.shade200)),
            child: Row(children: [
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle), child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('رسالة ملهمة 🤖', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 13)),
                const SizedBox(height: 4),
                Text(_aiMessage, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.teal.shade800), textDirection: TextDirection.rtl),
              ])),
            ]),
          ),
          if (!isPro) ...[
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber)),
              child: Row(children: [
                const Icon(Icons.workspace_premium, color: Colors.amber), const SizedBox(width: 8),
                Expanded(child: Text('جميع الآيات + رسائل AI يومياً + إشعارات في Pro', style: TextStyle(color: Colors.brown.shade700, fontSize: 13))),
                TextButton(onPressed: () => Navigator.pushNamed(context, '/settings'), child: const Text('Pro', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
              ]),
            ),
          ],
        ]),
      ),
    );
  }

  String _getTafsir() => _selectedAyah!['tafsir'] ?? '';
}
