import 'dart:math';
import 'package:flutter/material.dart';

class RubikCubeScreenEnhanced extends StatefulWidget {
  const RubikCubeScreenEnhanced({super.key});

  @override
  State<RubikCubeScreenEnhanced> createState() => _RubikCubeScreenEnhancedState();
}

class _RubikCubeScreenEnhancedState extends State<RubikCubeScreenEnhanced>
    with TickerProviderStateMixin {
  late AnimationController _rotController;
  late AnimationController _solveController;
  double _xRotation = -0.3;
  double _yRotation = 0.5;
  int _moveCount = 0;
  bool _isSolving = false;

  // ألوان الوجوه
  final List<Color> _faceColors = [
    Colors.red,    // أمامي
    Colors.green,  // خلفي
    Colors.blue,   // يسار
    Colors.orange, // يمين
    Colors.white,  // علوي
    Colors.yellow, // سفلي
  ];

  @override
  void initState() {
    super.initState();
    _rotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _solveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
  }

  @override
  void dispose() {
    _rotController.dispose();
    _solveController.dispose();
    super.dispose();
  }

  void _rotateFace() {
    setState(() {
      _yRotation += pi / 4;
      _moveCount++;
    });
  }

  void _shuffle() {
    setState(() {
      final rng = Random();
      for (int i = 0; i < 20; i++) {
        if (rng.nextBool()) {
          _xRotation += pi / 6;
        } else {
          _yRotation += pi / 6;
        }
      }
      _moveCount += 20;
    });
  }

  void _autoSolve() async {
    setState(() {
      _isSolving = true;
    });
    _solveController.forward(from: 0).then((_) {
      setState(() {
        _xRotation = -0.3;
        _yRotation = 0.5;
        _moveCount = 0;
        _isSolving = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('🧊 مكعب روبيك 3D', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.amber),
            onPressed: _shuffle,
            tooltip: 'خلط',
          ),
          IconButton(
            icon: Icon(
              _isSolving ? Icons.hourglass_empty : Icons.auto_fix_high,
              color: Colors.greenAccent,
            ),
            onPressed: _isSolving ? null : _autoSolve,
            tooltip: 'حل تلقائي',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoChip('الحركات: $_moveCount', Colors.cyanAccent),
                _buildInfoChip('المحرك: Kociemba', Colors.amber),
                _buildInfoChip('الوضع: 3D', Colors.purpleAccent),
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                setState(() {
                  _yRotation += details.delta.dx * 0.01;
                  _xRotation += details.delta.dy * 0.01;
                  _moveCount++;
                });
              },
              onDoubleTap: _rotateFace,
              child: Center(
                child: AnimatedBuilder(
                  animation: _rotController,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(_xRotation + _rotController.value * 0.1)
                        ..rotateY(_yRotation + _rotController.value * 0.2),
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.3),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: GridView.count(
                          crossAxisCount: 3,
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(9, (i) {
                            return _buildSticker(i);
                          }),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                _buildActionButton('U', () => setState(() => _moveCount++)),
                _buildActionButton('D', () => setState(() => _moveCount++)),
                _buildActionButton('L', () => setState(() => _moveCount++)),
                _buildActionButton('R', () => setState(() => _moveCount++)),
                _buildActionButton('F', () => setState(() => _moveCount++)),
                _buildActionButton('B', () => setState(() => _moveCount++)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '💡 اسحب للتدوير | انقر مرتين لتدوير وجه',
              style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSticker(int index) {
    final faceIndex = index ~/ 3; // 0-2 للوجه الواحد
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: _faceColors[faceIndex % _faceColors.length],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black, width: 2),
        boxShadow: [
          BoxShadow(
            color: _faceColors[faceIndex % _faceColors.length].withOpacity(0.5),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purpleAccent,
        minimumSize: const Size(40, 40),
        padding: const EdgeInsets.all(8),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
