import 'package:flutter/material.dart';

class DialogueScreen extends StatelessWidget {
  const DialogueScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('حوار مترجم', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 20),
            Text(
              'قريباً — محادثة ثنائية فورية',
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
