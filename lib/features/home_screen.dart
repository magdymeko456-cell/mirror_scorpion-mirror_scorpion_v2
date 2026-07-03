import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/floating_bubble_service.dart';
import '../core/services/database_service.dart';
import '../core/services/language_service.dart';
import '../core/widgets/shared_widgets.dart';
import 'translate/translate_screen.dart';
import 'dialogue/dialogue_screen.dart';
import 'document/document_screen.dart';
import 'hadith_stories/hadith_stories_screen.dart';
import 'games/games_screen.dart';
import 'settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _bubbleActive = false; bool _showWm = true;

  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    setState(() => _bubbleActive = p.getBool('bubble_active') ?? false);
  }

  void _toggleBubble() async {
    final bs = context.read<FloatingBubbleService>();
    if (_bubbleActive) bs.stopBubble(); else await bs.startBubble(context);
    setState(() => _bubbleActive = !_bubbleActive);
    (await SharedPreferences.getInstance()).setBool('bubble_active', _bubbleActive);
  }

  @override Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(20,20,20,10), child: Row(children: [
        CircleAvatar(radius: 24, backgroundColor: t.primaryColor, child: const Text('🦂', style: TextStyle(fontSize: 28))),
        const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Mirror Scorpion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text('مترجمك الذكي | قصص وأحاديث', style: TextStyle(fontSize: 12)),
        ])),
        IconButton(icon: Icon(_bubbleActive ? Icons.brightness_1 : Icons.brightness_1_outlined, color: _bubbleActive ? Colors.amber : Colors.grey, size: 32), tooltip: 'الفقاعة', onPressed: _toggleBubble),
        IconButton(icon: Icon(_showWm ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _showWm = !_showWm)),
      ])),
      Expanded(child: GridView.count(crossAxisCount: 2, padding: const EdgeInsets.all(16), mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.85,
        children: [
          _card(context, 'ترجمة\nالنصوص', Icons.translate, Colors.blue, const TranslateScreen()),
          _card(context, 'محادثة\nذكية', Icons.chat, Colors.green, const DialogueScreen()),
          _card(context, 'ترجمة\nمستندات', Icons.description, Colors.orange, const DocumentScreen()),
          _card(context, 'قصص\nوأحاديث', Icons.auto_stories, Colors.purple, const HadithStoriesScreen()),
          _card(context, 'ألعاب', Icons.sports_esports, Colors.red, const GamesScreen()),
          _card(context, 'الإعدادات', Icons.settings, Colors.teal, const SettingsScreen()),
        ],
      )),
      if (_showWm) const Padding(padding: EdgeInsets.only(bottom: 4), child: WatermarkText(text: "Mirror Scorpion 🦂")),
    ])));
  }

  Widget _card(BuildContext c, String t, IconData ic, Color cl, Widget s) => Card(
    elevation: 4, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    child: InkWell(borderRadius: BorderRadius.circular(20), onTap: () => Navigator.push(c, MaterialPageRoute(builder: (_) => s)),
      child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [cl.withOpacity(0.15), cl.withOpacity(0.05)])),
        child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: cl.withOpacity(0.15), shape: BoxShape.circle), child: Icon(ic, size: 40, color: cl)),
          const SizedBox(height: 12), Text(t, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cl), textAlign: TextAlign.center),
        ])),
      ),
    ),
  );
}
