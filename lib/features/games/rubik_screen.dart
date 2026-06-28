import 'package:flutter/material.dart';

class RubikScreen extends StatelessWidget {
  const RubikScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('مكعب روبيك 3D', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.extension, size: 80, color: Colors.amberAccent),
            const SizedBox(height: 20),
            Text(
              'قريباً — روبيك بجميع طرق الحل',
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
