import 'package:flutter/material.dart';
import 'dart:math';

class RubikScreen extends StatefulWidget {
  const RubikScreen({super.key});

  @override
  State<RubikScreen> createState() => _RubikScreenState();
}

class _RubikScreenState extends State<RubikScreen> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  double _rotationX = 0.3;
  double _rotationY = 0.5;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _spinAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_spinController);
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('🔲 روبيك 3D', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedBuilder(
              animation: _spinAnimation,
              builder: (context, child) {
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_rotationX + _spinAnimation.value * 0.1)
                    ..rotateY(_rotationY + _spinAnimation.value * 0.2),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _RubikCubePainter(),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('مكعب روبيك 3D',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('اسحب لتدوير | قريباً جميع طرق الحل',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildColorDot(Colors.green),
                    _buildColorDot(Colors.red),
                    _buildColorDot(Colors.blue),
                    _buildColorDot(Colors.orange),
                    _buildColorDot(Colors.yellow),
                    _buildColorDot(Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 6)],
      ),
    );
  }
}

class _RubikCubePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final s = 60.0; // cube size

    final colors = [
      Colors.red, Colors.green, Colors.blue,
      Colors.orange, Colors.yellow, Colors.white,
    ];

    // رسم مكعبات 3x3
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        for (int z = -1; z <= 1; z++) {
          final posX = cx + x * s * 0.8;
          final posY = cy + y * s * 0.8;
          final depth = z * s * 0.3;

          // كل وجه من المكعب
          final faces = [
            [posX - s / 2 + depth, posY - s / 2, posX + s / 2 + depth, posY + s / 2, colors[(x + 3).abs() % 6]],
            [posX - s / 2, posY - s / 2 + depth, posX + s / 2, posY + s / 2 + depth, colors[(y + 3).abs() % 6]],
            [posX - s / 2, posY - s / 2, posX + s / 2, posY + s / 2, colors[(z + 3).abs() % 6]],
          ];

          for (final face in faces) {
            paint.color = face[4] as Color;
            final rect = Rect.fromLTRB(
              face[0] as double, face[1] as double,
              face[2] as double, face[3] as double,
            );
            canvas.drawRect(rect, paint);
            canvas.drawRect(rect, strokePaint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
