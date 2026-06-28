import 'package:flutter/material.dart';

class DocumentScreen extends StatelessWidget {
  const DocumentScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('ترجمة مستندات', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.document_scanner, size: 80, color: Colors.tealAccent),
            const SizedBox(height: 20),
            Text(
              'قريباً — ترجمة الملفات والصور بعدسة جوجل',
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
