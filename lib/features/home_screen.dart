import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/floating_bubble_service.dart';
import '../services/language_service.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  String _deviceLanguage = 'ar';

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _glowController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(CurvedAnimation(parent: _glowController, curve: Curves.easeInOut));
    _loadLanguage();
  }

  void _loadLanguage() {
    final langService = Provider.of<LanguageService>(context, listen: false);
    setState(() => _deviceLanguage = langService.getDeviceLanguage());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _toggleBubble() async {
    final service = Provider.of<FloatingBubbleService>(context, listen: false);
    if (service.isStarted) {
      await service.stopBubble();
    } else {
      await service.startBubble();
    }
  }

  Future<void> _showInspiration() async {
    final ai = Provider.of<AIService>(context, listen: false);
    final insp = await ai.generateInspiration();
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.auto_awesome, color: Colors.amber), SizedBox(width: 8), Text('🦂 إلهام اليوم', style: TextStyle(color: Colors.white))]),
        content: Text(insp, style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.6)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('📋 تم', style: TextStyle(color: Colors.cyanAccent)))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bubbleService = Provider.of<FloatingBubbleService>(context);
    final isBubbleActive = bubbleService.isStarted;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  height: 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [const Color(0xFF0D1B2A), const Color(0xFF1B2838).withOpacity(_glowAnimation.value)],
                    ),
                  ),
                  child: Stack(alignment: Alignment.center, children: [
                    // Main Scorpion
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(scale: _pulseAnimation.value, child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle, border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                            boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 25, spreadRadius: 8)],
                            image: const DecorationImage(image: AssetImage('assets/images/scorpion_icon.jpeg'), fit: BoxFit.cover),
                          ),
                        ));
                      },
                    ),
                    // Inspiration button
                    Positioned(bottom: 15, child: GestureDetector(
                      onTap: _showInspiration,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                        decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.amber.withOpacity(0.3))),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.auto_awesome, color: Colors.amber, size: 16),
                          SizedBox(width: 6),
                          Text('إلهام اليوم', style: TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold)),
                        ]),
                      ),
                    )),
                  ]),
                );
              },
            ),
          ),

          // Bubble Toggle
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: isBubbleActive ? Colors.blueAccent : Colors.white24)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(isBubbleActive ? Icons.bubble_chart : Icons.bubble_chart_outlined, color: isBubbleActive ? Colors.blueAccent : Colors.grey),
                  const SizedBox(width: 12),
                  Text(isBubbleActive ? 'الفقاعة نشطة' : 'تفعيل الفقاعة العائمة', style: TextStyle(color: isBubbleActive ? Colors.blueAccent : Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Switch(value: isBubbleActive, onChanged: (_) => _toggleBubble(), activeColor: Colors.blueAccent),
                ]),
              ),
            ),
          ),

          // 6 Cards Grid فقط
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.9),
              delegate: SliverChildListDelegate([
                _buildCard(icon: Icons.translate, title: 'ترجمة نصية', subtitle: '100 لغة + مايك', color: Colors.blueAccent, onTap: () => Navigator.pushNamed(context, '/translate')),
                _buildCard(icon: Icons.forum, title: 'حوار مترجم', subtitle: 'محادثة ثنائية فورية', color: Colors.cyanAccent, onTap: () => Navigator.pushNamed(context, '/dialogue')),
                _buildCard(icon: Icons.document_scanner, title: 'مستندات وعدسة', subtitle: 'ترجمة صور وملفات', color: Colors.tealAccent, onTap: () => Navigator.pushNamed(context, '/document')),
                _buildCard(icon: Icons.auto_stories, title: 'قصص وإلهام', subtitle: 'مكتبة إسلامية ذكية', color: Colors.orangeAccent, onTap: () => Navigator.pushNamed(context, '/stories')),
                _buildCard(icon: Icons.settings, title: 'الإعدادات', subtitle: 'تخصيص وترقية برو', color: Colors.blueGrey, onTap: () => Navigator.pushNamed(context, '/settings')),
                _buildCard(icon: Icons.psychology, title: 'الذكاء الاصطناعي', subtitle: 'توليد نصوص وفيديو', color: Colors.purpleAccent, onTap: _showInspiration),
              ]),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Opacity(opacity: 0.3, child: Column(children: [
                  const Text('🦂 Mirror Scorpion', style: TextStyle(color: Colors.white, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text("v1.2.0 — جميع الأنظمة نشطة", style: TextStyle(color: Colors.white, fontSize: 10)),
                ])),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Material(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withOpacity(0.1), Colors.transparent]),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ),
      ),
    );
  }
}
