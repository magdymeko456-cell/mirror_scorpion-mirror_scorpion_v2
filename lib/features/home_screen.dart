import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/floating_bubble_service.dart';
import '../services/premium_verification_service.dart';

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
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
            Text(
              premium.isPremium ? '⭐ Pro Member' : 'نسخة مجانية',
              style: TextStyle(fontSize: 12, color: premium.isPremium ? Colors.amber : Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          // Bubble toggle
          IconButton(
            icon: Icon(
              bubbleService.isEnabled ? Icons.bubble_chart : Icons.bubble_chart_outlined,
              color: bubbleService.isEnabled ? Colors.amber : Colors.white54,
            ),
            onPressed: () => bubbleService.toggle(),
            tooltip: bubbleService.isEnabled ? 'إخفاء الفقاعة العائمة' : 'إظهار الفقاعة العائمة',
          ),
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Ayah banner
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal.shade700, Colors.teal.shade500],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(Icons.auto_stories, color: Colors.white, size: 28),
                  const SizedBox(height: 8),
                  const Text(
                    'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Traditional Arabic',
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سورة الشرح (الآية 6)',
                    style: TextStyle(color: Colors.teal.shade100, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Cards grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(12),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  _buildCard(
                    context,
                    icon: Icons.translate,
                    title: 'ترجمة',
                    subtitle: 'نصوص - حوار - مستندات',
                    color: Colors.blue,
                    route: '/translate',
                  ),
                  _buildCard(
                    context,
                    icon: Icons.menu_book,
                    title: 'قصص إسلامية',
                    subtitle: '6 مصادر إسلامية',
                    color: Colors.green,
                    route: '/stories',
                  ),
                  _buildCard(
                    context,
                    icon: Icons.lightbulb,
                    title: 'إلهام يومي',
                    subtitle: 'آية + تفسير من 6 مصادر',
                    color: Colors.amber,
                    route: '/inspiration',
                  ),
                  _buildCard(
                    context,
                    icon: Icons.extension,
                    title: 'ألعاب ذكية',
                    subtitle: 'شطرنج - روبيك',
                    color: Colors.purple,
                    route: '/chess',
                  ),
                  _buildCard(
                    context,
                    icon: Icons.settings,
                    title: 'الإعدادات',
                    subtitle: 'فقاعة - Pro - صوت',
                    color: Colors.grey,
                    route: '/settings',
                  ),
                  _buildCard(
                    context,
                    icon: Icons.workspace_premium,
                    title: premium.isPremium ? 'Pro نشط' : 'ترقية Pro',
                    subtitle: premium.isPremium ? 'جميع الميزات مفعلة' : 'فتح جميع الميزات',
                    color: Colors.amber,
                    route: '/settings',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
