import 'package:flutter/material.dart';

class RubikCubeScreen extends StatelessWidget {
  const RubikCubeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مكعب روبيك 3D')),
      body: const Center(child: Text('مكعب روبيك قيد التطوير - ميرور سكربيون')),
    );
  }
}
