import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/floating_bubble_service.dart';
import '../services/tts_service.dart';
import '../services/premium_verification_service.dart';
import '../services/language_service.dart';
import '../card5_games/games_screen.dart'; // استدعاء مباشر ومستقر لكارت الألعاب

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleBubble() {
    final service = context.read<FloatingBubbleService>();
    if (service.isEnabled) {
      service.stopBubble();
    } else {
      service.startBubble();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bubbleService = context.watch<FloatingBubbleService>();
    final premium = context.watch<PremiumVerificationService>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🦂 Mirror Scorpion', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(premium.isPremium ? '⭐ Pro Member' : 'نسخة مجانية',
                style: TextStyle(fontSize: 12, color: premium.isPremium ? Colors.amber : Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.teal,
        actions: [
          // الأيقونة التفاعلية الكبيرة والنباضة للفقاعة الذكية
          ScaleTransition(
            scale: _pulseAnimation,
            child: IconButton(
              icon: Icon(bubbleService.isEnabled ? Icons.bubble_chart : Icons.bubble_chart_outlined,
                  color: bubbleService.isEnabled ? Colors.cyanAccent : Colors.white54, size: 28),
              onPressed: _toggleBubble,
              tooltip: 'الفقاعة العائمة التفاعلية',
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // بنر الحكمة والآيات المؤثرة لمحرك الإلهام
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.teal.shade700, Colors.teal.shade500]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.teal.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 6))],
                ),
                child: const Column(
                  children: [
                    Icon(Icons.auto_stories, color: Colors.white, size: 32),
                    SizedBox(height: 8),
                    Text('إِنَّ مَعَ الْعُسْرِ يُسْرًا',
                        style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Traditional Arabic'),
                        textDirection: TextDirection.rtl),
                    SizedBox(height: 4),
                    Text('سورة الشرح (الآية 6)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ),
            // شبكة الكروت الستة المستقرة هندسياً وعملياً
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildListDelegate([
                  _buildCard(icon: Icons.translate, title: 'ترجمة نصية', subtitle: '100 لغة + مايك', color: Colors.blueAccent,
                      onTap: () => Navigator.pushNamed(context, '/translate')),
                  _buildCard(icon: Icons.forum, title: 'حوار مترجم', subtitle: 'محادثة ثنائية فورية', color: Colors.cyanAccent,
                      onTap: () => Navigator.pushNamed(context, '/dialogue')),
                  _buildCard(icon: Icons.document_scanner, title: 'مستندات وعدسة', subtitle: 'ترجمة صور وملفات', color: Colors.tealAccent,
                      onTap: () => Navigator.pushNamed(context, '/document')),
                  _buildCard(icon: Icons.auto_stories, title: 'قصص وإلهام', subtitle: 'مكتبة ذكية متكاملة', color: Colors.orangeAccent,
                      onTap: () => Navigator.pushNamed(context, '/stories')),
                  // تعديل الربط المباشر والمستقر لكارت الألعاب لتجنب مشاكل الـ Sheets
                  _buildCard(icon: Icons.sports_esports, title: 'ألعاب 3D', subtitle: 'شطرنج + روبيك ذكي', color: Colors.purpleAccent,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const GamesScreen()),
                        );
                      }),
                  _buildCard(icon: Icons.settings, title: 'الإعدادات', subtitle: 'تخصيص وترقية برو', color: Colors.blueGrey,
                      onTap: () => Navigator.pushNamed(context, '/settings')),
                ]),
              ),
            ),
            // الفوتر السفلي للشاشات
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Opacity(
                    opacity: 0.3,
                    child: Column(
                      children: const [
                        Text('🦂 Mirror Scorpion', style: TextStyle(color: Colors.white, fontSize: 14)),
                        SizedBox(height: 4),
                        Text('الوقت هو العملة الأغلى', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
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
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withValues(alpha: 0.1), Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 12),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                    textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54),
                    textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
