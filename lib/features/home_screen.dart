import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mirror_scorpion/core/services/floating_bubble_service.dart';
import 'package:mirror_scorpion/core/services/database_service.dart';
import 'package:mirror_scorpion/core/widgets/shared_widgets.dart';
import 'package:mirror_scorpion/features/translate/translate_screen.dart';
import 'package:mirror_scorpion/features/dialogue/dialogue_screen.dart';
import 'package:mirror_scorpion/features/document/document_screen.dart';
import 'package:mirror_scorpion/features/hadith_stories/hadith_stories_screen.dart';
import 'package:mirror_scorpion/features/games/games_screen.dart';
import 'package:mirror_scorpion/features/settings/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _bubbleActive = false;
  bool _showWatermark = true;
  Map<String, int> _cardUsage = {};

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bubbleActive = prefs.getBool('bubble_active') ?? false;
    });
    final db = context.read<DatabaseService>();
    final usage = await db.getAllCardUsage();
    if (mounted) setState(() => _cardUsage = usage);
  }

  void _toggleBubble() async {
    final bubbleService = context.read<FloatingBubbleService>();
    if (_bubbleActive) {
      bubbleService.stopBubble();
    } else {
      await bubbleService.startBubble(context);
    }
    setState(() => _bubbleActive = !_bubbleActive);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bubble_active', _bubbleActive);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor.withOpacity(0.1),
              theme.colorScheme.secondary.withOpacity(0.1),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: theme.primaryColor,
                      child: const Text('🦂', style: TextStyle(fontSize: 28)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mirror Scorpion',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.primaryColor,
                            ),
                          ),
                          const Text('مترجمك الذكي | قصص وأحاديث'),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _bubbleActive ? Icons.brightness_1 : Icons.brightness_1_outlined,
                        color: _bubbleActive ? Colors.amber : Colors.grey,
                        size: 32,
                      ),
                      tooltip: 'الفقاعة العائمة',
                      onPressed: _toggleBubble,
                    ),
                    IconButton(
                      icon: Icon(_showWatermark ? Icons.visibility : Icons.visibility_off),
                      onPressed: () => setState(() => _showWatermark = !_showWatermark),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(16),
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    _buildCard(context, title: 'ترجمة النصوص', icon: Icons.translate, color: Colors.blue, screen: const TranslateScreen(), usage: _cardUsage['translate'] ?? 0),
                    _buildCard(context, title: 'محادثة ذكية', icon: Icons.chat, color: Colors.green, screen: const DialogueScreen(), usage: _cardUsage['dialogue'] ?? 0),
                    _buildCard(context, title: 'ترجمة مستندات', icon: Icons.description, color: Colors.orange, screen: const DocumentScreen(), usage: _cardUsage['document'] ?? 0),
                    _buildCard(context, title: 'قصص وأحاديث', icon: Icons.auto_stories, color: Colors.purple, screen: const HadithStoriesScreen(), usage: _cardUsage['stories'] ?? 0),
                    _buildCard(context, title: 'ألعاب', icon: Icons.sports_esports, color: Colors.red, screen: const GamesScreen(), usage: _cardUsage['games'] ?? 0),
                    _buildCard(context, title: 'الإعدادات', icon: Icons.settings, color: Colors.teal, screen: const SettingsScreen(), usage: _cardUsage['settings'] ?? 0),
                  ],
                ),
              ),
              if (_showWatermark)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: WatermarkText(fontSize: 10),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, {required String title, required IconData icon, required Color color, required Widget screen, int usage = 0}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: color.withOpacity(0.15), shape: BoxShape.circle),
                  child: Icon(icon, size: 40, color: color),
                ),
                const SizedBox(height: 12),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
                if (usage > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text('استخدمت $usage مرة', style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
