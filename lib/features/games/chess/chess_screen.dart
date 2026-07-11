import 'package:flutter/material.dart';

class ChessGameScreen extends StatelessWidget {
  const ChessGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شطرنج 3D')),
      body: const Center(child: Text('لعبة الشطرنج قيد التطوير - ميرور سكربيون')),
    );
  }
}
