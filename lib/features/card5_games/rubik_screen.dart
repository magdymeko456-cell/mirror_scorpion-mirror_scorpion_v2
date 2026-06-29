import 'package:flutter/material.dart';

class RubikScreen extends StatelessWidget {
  const RubikScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مكعب روبيك'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.construction, size: 80, color: Colors.teal),
        const SizedBox(height: 24),
        const Text('قيد التطوير', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal)),
        const SizedBox(height: 12),
        const Text('مكعب روبيك مع AI سيكون متاحاً قريباً', style: TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(16), margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.shade200)),
          child: const Column(children: [
            Text('المميزات القادمة:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            SizedBox(height: 8),
            Text('AI يحل المكعب'), Text('محاكي 3D'), Text('تحديات يومية'),
          ]),
        ),
      ])),
    );
  }
}
