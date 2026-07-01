import 'package:flutter/material.dart';

/// شاشة الألعاب الرئيسية - تستدعي شطرنج وروبيك من المسارات الحقيقية
class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // توجيه مباشر إلى games_menu_screen الموجود في features/games/
    // للحفاظ على التوافق مع الكود الموجود
    return const _GamesRedirector();
  }
}

class _GamesRedirector extends StatefulWidget {
  const _GamesRedirector();
  @override
  State<_GamesRedirector> createState() => _GamesRedirectorState();
}

class _GamesRedirectorState extends State<_GamesRedirector> {
  @override
  void initState() {
    super.initState();
    // التوجيه الفوري إلى شاشة الألعاب الحقيقية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacementNamed(context, '/games-menu');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0D1B2A),
      body: Center(child: CircularProgressIndicator(color: Colors.purpleAccent)),
    );
  }
}
