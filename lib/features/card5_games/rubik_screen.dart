import 'package:flutter/material.dart';

class RubikScreen extends StatefulWidget {
  const RubikScreen({super.key});
  @override
  State<RubikScreen> createState() => _RubikScreenState();
}

class _RubikScreenState extends State<RubikScreen> {
  // ✅ HOTFIX: إضافة _faceNames (كانت مفقودة وتسبب الخطأ)
  final List<String> _faceNames = ['أمامي', 'خلفي', 'أيسر', 'أيمن', 'علوي', 'سفلي'];
  
  // مصفوفة بسيطة تمثل 6 أوجه كل وجه 3x3
  final List<List<List<Color>>> _cube = List.generate(
    6, (_) => List.generate(3, (_) => List.generate(3, (_) => Colors.white)),
  );

  final List<Color> _faceColors = [
    Colors.green, Colors.blue, Colors.orange,
    Colors.red, Colors.white, Colors.yellow,
  ];

  @override
  void initState() {
    super.initState();
    // تعيين الألوان الابتدائية
    for (int f = 0; f < 6; f++) {
      for (int r = 0; r < 3; r++) {
        for (int c = 0; c < 3; c++) {
          _cube[f][r][c] = _faceColors[f];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧩 روبيك 3D', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          // عرض الأوجه كشبكات
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: 6,
              itemBuilder: (context, fi) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 4),
                      // ✅ HOTFIX: استخدام _faceNames[fi]
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(_faceNames[fi],
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 1.0,
                              mainAxisSpacing: 2,
                              crossAxisSpacing: 2,
                            ),
                            itemCount: 9,
                            itemBuilder: (_, ci) {
                              final r = ci ~/ 3;
                              final c = ci % 3;
                              return Container(
                                decoration: BoxDecoration(
                                  color: _cube[fi][r][c],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: Colors.grey.shade400, width: 1.5),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
