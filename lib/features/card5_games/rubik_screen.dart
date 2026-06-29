import 'dart:math';
import 'package:flutter/material.dart';

class RubikScreen extends StatefulWidget {
  const RubikScreen({super.key});
  @override
  State<RubikScreen> createState() => _RubikScreenState();
}

class _RubikScreenState extends State<RubikScreen> {
  List<List<Color>> _faces = [];
  final Random _random = Random();
  bool _isSolved = true;
  int _moveCount = 0;

  final List<Color> _faceColors = [Colors.green, Colors.blue, Colors.red, Colors.orange, Colors.white, Colors.yellow];

  @override
  void initState() { super.initState(); _initCube(); }

  void _initCube() {
    _faces = [];
    for (int f = 0; f < 6; f++) {
      _faces.add(List.generate(9, (_) => _faceColors[f]));
    }
    _isSolved = true;
    _moveCount = 0;
    setState(() {});
  }

  void _scramble() {
    _initCube();
    final moves = ['U', "U'", 'D', "D'", 'R', "R'", 'L', "L'", 'F', "F'", 'B', "B'"];
    for (int i = 0; i < 20; i++) {
      _rotateFace(moves[_random.nextInt(moves.length)], updateState: false);
    }
    _isSolved = false;
    _moveCount = 0;
    setState(() {});
  }

  void _rotateFace(String move, {bool updateState = true}) {
    // Map face rotations to our face indices
    Map<String, int> faceMap = {'U': 4, 'D': 5, 'R': 2, 'L': 3, 'F': 0, 'B': 1};
    bool isPrime = move.contains("'");
    String face = move.replaceAll("'", "");
    int fi = faceMap[face] ?? 0;

    // Rotate the face itself
    List<Color> faceColors = List.from(_faces[fi]);
    if (isPrime) {
      // Counter-clockwise
      for (int i = 0; i < 9; i++) {
        int src = [2, 5, 8, 1, 4, 7, 0, 3, 6][i];
        _faces[fi][i] = faceColors[src];
      }
    } else {
      // Clockwise
      for (int i = 0; i < 9; i++) {
        int src = [6, 3, 0, 7, 4, 1, 8, 5, 2][i];
        _faces[fi][i] = faceColors[src];
      }
    }

    if (updateState) {
      _moveCount++;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('روبيك 3D 🧩'), backgroundColor: Colors.teal, foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _initCube), IconButton(icon: const Icon(Icons.shuffle), onPressed: _scramble, tooltip: 'خلط')]),
      body: Column(children: [
        // Info bar
        Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), color: Colors.teal.shade50,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_isSolved ? '✅ مكعب محلول' : '❌ غير محلول', style: TextStyle(color: _isSolved ? Colors.green : Colors.red, fontWeight: FontWeight.bold)),
            Text('عدد الحركات: $_moveCount', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ),
        // Cube faces
        Expanded(child: GridView.count(crossAxisCount: 3, padding: const EdgeInsets.all(8),
          childAspectRatio: 1, mainAxisSpacing: 8, crossAxisSpacing: 8,
          children: List.generate(6, (fi) => Container(
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(8)),
            child: Column(children: [
              Padding(padding: const EdgeInsets.all(4), child: Text(_faceNames[fi], style: TextStyle(fontSize: 10, color: Colors.grey.shade600))),
              Expanded(child: GridView.count(crossAxisCount: 3, physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1,
                children: List.generate(9, (i) => Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(color: _faces[fi][i], borderRadius: BorderRadius.circular(3), border: Border.all(color: Colors.black12)),
                )),
              )),
            ]),
          )),
        )),
        // Quick moves
        Container(padding: const EdgeInsets.all(8), color: Colors.grey.shade100,
          child: Column(children: [
            const Text('حركات سريعة', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Wrap(spacing: 4, runSpacing: 4, children: ['U', "U'", 'D', "D'", 'R', "R'", 'L', "L'", 'F', "F'", 'B', "B'"].map((m) => 
              ActionChip(label: Text(m, style: const TextStyle(fontSize: 11)), onPressed: () => _rotateFace(m)),
            ).toList()),
          ]),
        ),
        // Solve button
        Padding(padding: const EdgeInsets.all(8), child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
          onPressed: _scramble, icon: const Icon(Icons.auto_fix_high), label: const Text('خلط المكعب'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
        ))),
      ]),
    );
  }
}
