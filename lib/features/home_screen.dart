import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/floating_bubble_service.dart';
import '../services/language_service.dart';

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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
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

  @override
  Widget build(BuildContext context) {
    final bubbleService = Provider.of<FloatingBubbleService>(context);
    final isBubbleActive = bubbleService.isStarted;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: CustomScrollView(
        slivers: [
          // Header: Scorpion + Reflection
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  height: 320,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0D1B2A),
                        const Color(0xFF1B2838).withOpacity(_glowAnimation.value),
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(top: 10, child: Transform.flip(flipY: true, child: Opacity(opacity: 0.3, child: _buildScorpionLogo(isReflection: true)))),
                      _buildScorpionLogo(isReflection: false),
                      Positioned(top: 155, child: Container(width: 200, height: 2, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, Colors.blueAccent.withOpacity(0.6), Colors.transparent])))),
                      Positioned(top: 165, child: Text('🦂 ميرور سكربيون', style: TextStyle(color: Colors.blueAccent.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2))),
                    ],
                  ),
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isBubbleActive ? Icons.bubble_chart : Icons.bubble_chart_outlined, color: isBubbleActive ? Colors.blueAccent : Colors.grey),
                    const SizedBox(width: 12),
                    Text(isBubbleActive ? 'الفقاعة نشطة' : 'تفعيل الفقاعة العائمة', style: TextStyle(color: isBubbleActive ? Colors.blueAccent : Colors.white70, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Switch(value: isBubbleActive, onChanged: (_) => _toggleBubble(), activeColor: Colors.blueAccent),
                  ],
                ),
              ),
            ),
          ),

          // 6 Cards Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.9),
              delegate: SliverChildListDelegate([
                _buildCard(icon: Icons.translate, title: 'ترجمة نصية', subtitle: '100 لغة + مايك', color: Colors.blueAccent, onTap: () => Navigator.pushNamed(context, '/translate')),
                _buildCard(icon: Icons.forum, title: 'حوار مترجم', subtitle: 'محادثة ثنائية فورية', color: Colors.cyanAccent, onTap: () => Navigator.pushNamed(context, '/dialogue')),
                _buildCard(icon: Icons.document_scanner, title: 'مستندات وعدسة', subtitle: 'ترجمة صور وملفات', color: Colors.tealAccent, onTap: () => Navigator.pushNamed(context, '/document')),
                _buildCard(icon: Icons.auto_stories, title: 'قصص وإلهام', subtitle: 'مكتبة ذكية متكاملة', color: Colors.orangeAccent, onTap: () => Navigator.pushNamed(context, '/stories')),
                _buildCard(icon: Icons.sports_esports, title: 'ألعاب 3D', subtitle: 'شطرنج + روبيك', color: Colors.purpleAccent, onTap: () => _showGamesSelection(context)),
                _buildCard(icon: Icons.settings, title: 'الإعدادات', subtitle: 'تخصيص وترقية برو', color: Colors.blueGrey, onTap: () => Navigator.pushNamed(context, '/settings')),
              ]),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Column(
                    children: [
                      const Text('🦂 Mirror Scorpion', style: TextStyle(color: Colors.white, fontSize: 12)),
                      const SizedBox(height: 5),
                      const Text("v1.2.0 Build Stable — جميع الأنظمة نشطة", style: TextStyle(color: Colors.white, fontSize: 10)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorpionLogo({bool isReflection = false}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isReflection ? 1.0 : _pulseAnimation.value,
          child: Container(
            width: isReflection ? 120 : 140,
            height: isReflection ? 120 : 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: isReflection ? Colors.blueAccent.withOpacity(0.15) : Colors.blueAccent.withOpacity(0.5), width: isReflection ? 1 : 2),
              boxShadow: isReflection ? [] : [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 25, spreadRadius: 8)],
              image: const DecorationImage(image: AssetImage('assets/images/scorpion_icon.jpeg'), fit: BoxFit.cover),
            ),
          ),
        );
      },
    );
  }

  void _showGamesSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('اختر لعبتك', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _buildGameIcon(icon: Icons.sports_kabaddi, label: 'شطرنج 3D', color: Colors.purpleAccent, onTap: () { Navigator.pop(ctx); Navigator.pushNamed(context, '/chess'); }),
              _buildGameIcon(icon: Icons.blur_on, label: 'روبيك 3D', color: Colors.amberAccent, onTap: () { Navigator.pop(ctx); Navigator.pushNamed(context, '/rubik'); }),
            ]),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGameIcon({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120, height: 120,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.3))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 50, color: color),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ]),
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
