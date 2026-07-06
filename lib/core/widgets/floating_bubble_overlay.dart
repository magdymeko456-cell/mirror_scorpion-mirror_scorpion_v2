import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/floating_bubble_service.dart';

/// فقاعة عائمة حقيقية — تظهر فوق كل الشاشات
class FloatingBubbleOverlay extends StatefulWidget {
  final Widget child;
  const FloatingBubbleOverlay({super.key, required this.child});

  @override
  State<FloatingBubbleOverlay> createState() => _FloatingBubbleOverlayState();
}

class _FloatingBubbleOverlayState extends State<FloatingBubbleOverlay> {
  Offset _position = const Offset(20, 300);
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<FloatingBubbleService>(
      builder: (context, service, child) {
        if (!service.isEnabled) return widget.child;

        return Stack(
          children: [
            widget.child,
            // الفقاعة العائمة
            Positioned(
              left: _position.dx,
              top: _position.dy,
              child: GestureDetector(
                onTap: () {
                  // توسيع الفقاعة إلى شاشة كاملة مؤقتة
                  _showBubbleDetail(context, service);
                },
                onPanUpdate: (details) {
                  setState(() {
                    _position += details.delta;
                    _isDragging = true;
                  });
                },
                onPanEnd: (_) {
                  _isDragging = false;
                  // تثبيت على الحافة
                  final screenWidth = MediaQuery.of(context).size.width;
                  setState(() {
                    if (_position.dx < screenWidth / 2) {
                      _position = Offset(10, _position.dy);
                    } else {
                      _position = Offset(screenWidth - 70, _position.dy);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isDragging ? 60 : 56,
                  height: _isDragging ? 60 : 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.cyanAccent.withOpacity(0.7),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/scorpion_icon.jpeg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBubbleDetail(BuildContext context, FloatingBubbleService service) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50, height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/scorpion_icon.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('الفقاعة العائمة',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('ترجمة فورية بنقرة واحدة',
                  style: TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _bubbleAction(Icons.translate, 'ترجمة', () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/translate');
                  }),
                  _bubbleAction(Icons.mic, 'حوار', () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/dialogue');
                  }),
                  _bubbleAction(Icons.close, 'إغلاق', () {
                    service.toggle();
                    Navigator.pop(ctx);
                  }),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _bubbleAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Icon(icon, color: Colors.cyanAccent, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
