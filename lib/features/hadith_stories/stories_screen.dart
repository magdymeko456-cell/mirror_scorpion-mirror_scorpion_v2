import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/ai_service.dart';
import '../../services/database_service.dart';
import '../../services/notification_service.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});
  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  Map<String, List<Map<String, Object?>>> _data = {};
  bool _loading = true;

  static const _tafsir = [
    'سورة الفاتحة: سميت أم الكتاب، وهي أعظم سور القرآن، وتفتتح بها الصلاة.',
    'سورة الإخلاص: تعدل ثلث القرآن، وفيها توحيد الله تعالى.',
    'سورة الكوثر: نزلت تسلية للنبي ﷺ، والكوثر نهر في الجنة.',
  ];

  static const _noTahzan = [
    'لا تحزن.. فإن الله معك، ومعك كتابه، ومعك دعاؤك.',
    'إذا ضاقت عليك الأرض بما رحبت فاعلم أن الفرج قريب.',
    'لا تحزن على ما فات، فما كتبه الله لك سيأتيك ولو كان تحت قدميك.',
    'الحياة أقصر من أن نقضيها في الأحزان، فافرح بالله وقربه.',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = context.read<DatabaseService>();
    final anbia = await db.getStories('anbia');
    final women = await db.getStories('women');
    final ummam = await db.getStories('ummam');
    final hadiths = await db.getAllHadiths();
    final asbab = await db.getAsbab();
    if (!mounted) return;
    setState(() {
      _data = {
        'أنبياء (ابن كثير)': anbia,
        'نساء (قصص النساء)': women,
        'أمم (قصص الأمم)': ummam,
        'أحاديث قدسية': hadiths,
        'أسباب النزول': asbab,
      };
      _loading = false;
    });
  }

  Future<void> _inspire() async {
    final msg = context
        .read<AIService>()
        .generateInspiration(userMood: '', context: 'stories_screen');
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0
decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.tealAccent.withValues(alpha: 0.25)),
          ),
          child: Column(children: [
            Icon(ic, size: 34, color: Colors.tealAccent),
            const SizedBox(height: 8),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}
