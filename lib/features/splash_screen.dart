import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1A237E), Color(0xFF0D1B2A)]),
      ),
      child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('🦂', style: TextStyle(fontSize: 80)),
        SizedBox(height: 20),
        Text('Mirror Scorpion', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
        SizedBox(height: 8),
        Text('مترجمك الذكي | قصص وأحاديث', style: TextStyle(fontSize: 16, color: Colors.white70)),
        SizedBox(height: 40),
        CircularProgressIndicator(color: Colors.white),
      ])),
    ),
  );
}
