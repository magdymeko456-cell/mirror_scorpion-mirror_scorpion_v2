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
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/scorpion_icon.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Mirror Scorpion',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'حيث تُصنع البدايات',
              style: TextStyle(
                color: Colors.blueAccent.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Colors.blueAccent),
          ],
        ),
      ),
    );
  }
}
