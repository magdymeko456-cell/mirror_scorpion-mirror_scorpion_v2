import 'package:flutter/material.dart';

class ChessGameScreen extends StatelessWidget {
  const ChessGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('♟️ شطرنج ثلاثي الأبعاد والذكاء الاصطناعي', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.grid_4x4, size: 80, color: Colors.amberAccent),
            const SizedBox(height: 16),
            const Text(
              'محاكاة الشطرنج 3D بجميع المستويات',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'استمتع باللعب ضد محرك محلي يدعم حلول المواقف المعقدة.',
                style: TextStyle(color: Colors.white70, textAlign: Center),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amberAccent),
              onPressed: () {},
              child: const Text('ابدأ مباراة جديدة', style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}
