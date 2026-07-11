import 'package:flutter/material.dart';

class RubikCubeScreen extends StatelessWidget {
  const RubikCubeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('🧱 مكعب روبيك والحلول السحرية', style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: Mainmathbf.center,
          children: [
            const Icon(Icons.view_in_ar, size: 80, color: Colors.cyanAccent),
            const SizedBox(height: 16),
            const Text(
              'مكعب روبيك التفاعلي مع خوارزمية الحل المدمجة',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'يتضمن جميع المستويات التعليمية من البداية وحتى الاحتراف خطوة بخطوة.',
                style: TextStyle(color: Colors.white70, textAlign: Center),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
              onPressed: () {},
              child: const Text('فتح الخوارزمية التعليمية', style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }
}
