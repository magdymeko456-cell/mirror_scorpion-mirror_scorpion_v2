import 'package:flutter/material.dart';

// 🌐 نص مائي (توقيع التطبيق)
class WatermarkText extends StatelessWidget {
  final String text;
  final double fontSize;

  const WatermarkText({
    super.key,
    required this.text,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 130 * 3.14159 / 180,
      child: Opacity(
        opacity: 0.15,
        child: Text(
          "ترجم هذا المستند بواسطة Mirror Scorpion",
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
