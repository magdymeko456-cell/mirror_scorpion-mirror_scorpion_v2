import 'package:flutter/material.dart';

class ChessScreen extends StatelessWidget {
  const ChessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('شطرنج 3D', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.chess_board, size: 80, color: Colors.purpleAccent),
            const SizedBox(height: 20),
            Text(
              'قريباً — شطرنج ثلاثي الأبعاد',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
