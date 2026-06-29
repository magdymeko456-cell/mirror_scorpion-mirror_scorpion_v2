import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/floating_bubble_service.dart';
import '../services/tts_service.dart';
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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _toggleBubble() {
    final service = Provider.of<FloatingBubbleService>(context, listen: false);
    service.toggle();
  }

  @override
  Widget build(BuildContext context) {
    final bubbleService = context.watch<FloatingBubbleService>();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('🦂 Mirror Scorpion',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              bubbleService.isEnabled ? Icons.bubble_chart : Icons.bubble_chart_outlined,
              color: bubbleService.isEnabled ? Colors.amber : Colors.white54,
            ),
            onPressed: _toggleBubble,
            tooltip: 'الفقاعة العائمة',
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white54),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Scorpion Logo + Banner
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFF0D1B2A),
                        const Color(0xFF1B2838).withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00BCD4).withOpacity(_glowAnimation.value),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.translate, color: Colors.white, size: 40),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Traditional Arabic',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'سورة الشرح (الآية 6)',
                        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 6 Cards Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildListDelegate([
                _buildCard(
                  icon: Icons.translate,
                  title: 'ترجمة نصوص',
                  subtitle: 'نصوص - حوار - مستندات',
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(context, '/translate'),
                ),
                _buildCard(
                  icon: Icons.forum,
                  title: 'حوار مترجم',
                  subtitle: 'ترجمة فورية للمحادثات',
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, '/dialogue'),
                ),
                _buildCard(
                  icon: Icons.description,
                  title: 'مستندات وعدسة',
                  subtitle: 'ترجمة مستندات + عدسة',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/document'),
                ),
                _buildCard(
                  icon: Icons.menu_book,
                  title: 'قصص وأحاديث',
                  subtitle: 'أحاديث - قصص - إلهام',
                  color: Colors.green,
                  onTap: () => Navigator.pushNamed(context, '/stories'),
                ),
                _buildCard(
                  icon: Icons.extension,
                  title: 'ألعاب ذكية',
                  subtitle: 'شطرنج 3D - روبيك 3D',
                  color: Colors.purple,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: const Color(0xFF1B2838),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                      ),
                      builder: (ctx) => Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('اختر اللعبة',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 20),
                            ListTile(
                              leading: const Icon(Icons.grid_view, color: Colors.purpleAccent, size: 32),
                              title: const Text('مكعب روبيك 3D', style: TextStyle(color: Colors.white)),
                              subtitle: const Text('جميع طرق الحل', style: TextStyle(color: Colors.white54)),
                              onTap: () { Navigator.pop(ctx); Navigator.pushNamed(context, '/rubik'); },
                            ),
                            const Divider(color: Colors.white24),
                            ListTile(
                              leading: const Icon(Icons.castle, color: Colors.purpleAccent, size: 32),
                              title: const Text('شطرنج 3D', style: TextStyle(color: Colors.white)),
                              subtitle: const Text('لعبة شطرنج ثلاثية الأبعاد', style: TextStyle(color: Colors.white54)),
                              onTap: () { Navigator.pop(ctx); Navigator.pushNamed(context, '/chess'); },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                _buildCard(
                  icon: Icons.workspace_premium,
                  title: 'الإعدادات',
                  subtitle: 'فقاعة - Pro - صوت',
                  color: Colors.amber,
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.1), Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.white54),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
