import 'package:flutter/material.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قصص وإلهام')),
      body: const Center(child: Text('قسم القصص قيد التطوير - ميرور سكربيون')),
    );
  }
}
