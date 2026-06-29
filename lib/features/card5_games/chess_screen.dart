import 'package:flutter/material.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});
  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  List<List<String>> _board = [];
  Set<String> _validMoves = {};
  int? _selectedRow, _selectedCol;
  bool _isWhiteTurn = true;
  Set<String> _capturedWhite = {};
  Set<String> _capturedBlack = {};

  static const Map<String, String> _pieces = {
    'wP': '♙', 'wR': '♖', 'wN': '♘', 'wB': '♗', 'wQ': '♕', 'wK': '♔',
    'bP': '♟', 'bR': '♜', 'bN': '♞', 'bB': '♝', 'bQ': '♛', 'bK': '♚',
  };

  @override
  void initState() {
    super.initState();
    _resetBoard();
  }

  void _resetBoard() {
    _board = [
      ['bR','bN','bB','bQ','bK','bB','bN','bR'],
      ['bP','bP','bP','bP','bP','bP','bP','bP'],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['','','','','','','',''],
      ['wP','wP','wP','wP','wP','wP','wP','wP'],
      ['wR','wN','wB','wQ','wK','wB','wN','wR'],
    ];
    _selectedRow = null;
    _selectedCol = null;
    _validMoves = {};
    _isWhiteTurn = true;
    _capturedWhite = {};
    _capturedBlack = {};
    setState(() {});
  }

  void _onTap(int r, int c) {
    if (_selectedRow == null) {
      if (_board[r][c].isNotEmpty && _board[r][c].startsWith(_isWhiteTurn ? 'w' : 'b')) {
        _selectedRow = r;
        _selectedCol = c;
        _validMoves = _getValidMoves(r, c);
        setState(() {});
      }
    } else {
      if (_validMoves.contains('$r,$c')) {
        String captured = _board[r][c];
        if (captured.isNotEmpty) {
          if (_isWhiteTurn) _capturedBlack.add(_pieces[captured] ?? '?');
          else _capturedWhite.add(_pieces[captured] ?? '?');
        }
        _board[r][c] = _board[_selectedRow!][_selectedCol!];
        _board[_selectedRow!][_selectedCol!] = '';
        _isWhiteTurn = !_isWhiteTurn;
      }
      _selectedRow = null;
      _selectedCol = null;
      _validMoves = {};
      setState(() {});
    }
  }

  Set<String> _getValidMoves(int r, int c) {
    Set<String> moves = {};
    String piece = _board[r][c];
    if (piece.isEmpty) return moves;
    String type = piece.substring(1);
    bool isWhite = piece.startsWith('w');

    if (type == 'P') { // Pawn
      int dir = isWhite ? -1 : 1;
      if (r + dir >= 0 && r + dir < 8 && _board[r + dir][c].isEmpty) {
        moves.add('${r + dir},$c');
        if ((isWhite && r == 6) || (!isWhite && r == 1)) {
          if (_board[r + 2 * dir][c].isEmpty) moves.add('${r + 2 * dir},$c');
        }
      }
      for (int dc in [-1, 1]) {
        if (c + dc >= 0 && c + dc < 8 && r + dir >= 0 && r + dir < 8) {
          if (_board[r + dir][c + dc].isNotEmpty && _board[r + dir][c + dc].startsWith(isWhite ? 'b' : 'w')) {
            moves.add('${r + dir},${c + dc}');
          }
        }
      }
    } else if (type == 'N') {
      for (var d in [(-2,-1),(-2,1),(-1,-2),(-1,2),(1,-2),(1,2),(2,-1),(2,1)]) {
        int nr = r + d.$1, nc = c + d.$2;
        if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8 && (_board[nr][nc].isEmpty || _board[nr][nc].startsWith(isWhite ? 'b' : 'w'))) {
          moves.add('$nr,$nc');
        }
      }
    } else if (type == 'B' || type == 'Q') {
      for (var d in [(-1,-1),(-1,1),(1,-1),(1,1)]) {
        int nr = r + d.$1, nc = c + d.$2;
        while (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
          if (_board[nr][nc].isEmpty) { moves.add('$nr,$nc'); }
          else { if (_board[nr][nc].startsWith(isWhite ? 'b' : 'w')) moves.add('$nr,$nc'); break; }
          nr += d.$1; nc += d.$2;
        }
      }
    }
    if (type == 'R' || type == 'Q') {
      for (var d in [(-1,0),(1,0),(0,-1),(0,1)]) {
        int nr = r + d.$1, nc = c + d.$2;
        while (nr >= 0 && nr < 8 && nc >= 0 && nc < 8) {
          if (_board[nr][nc].isEmpty) { moves.add('$nr,$nc'); }
          else { if (_board[nr][nc].startsWith(isWhite ? 'b' : 'w')) moves.add('$nr,$nc'); break; }
          nr += d.$1; nc += d.$2;
        }
      }
    }
    if (type == 'K') {
      for (var d in [(-1,-1),(-1,0),(-1,1),(0,-1),(0,1),(1,-1),(1,0),(1,1)]) {
        int nr = r + d.$1, nc = c + d.$2;
        if (nr >= 0 && nr < 8 && nc >= 0 && nc < 8 && (_board[nr][nc].isEmpty || _board[nr][nc].startsWith(isWhite ? 'b' : 'w'))) {
          moves.add('$nr,$nc');
        }
      }
    }
    return moves;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('شطرنج 3D ♚'), backgroundColor: Colors.deepPurple, foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.refresh), onPressed: _resetBoard)]),
      body: Column(children: [
        // Info
        Container(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16), color: Colors.deepPurple.shade50,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('⚫ ${_isWhiteTurn ? '' : '⬅️'} أسود', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold)),
            Text('${_isWhiteTurn ? '⬅️' : ''} أبيض ⚪', style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
          ]),
        ),
        // Captured
        if (_capturedBlack.isNotEmpty) Padding(padding: const EdgeInsets.only(left: 12, top: 4), child: Row(children: [const Text('⚫ ', style: TextStyle(fontSize: 16)), ..._capturedBlack.map((p) => Text(p, style: const TextStyle(fontSize: 16)))])),
        if (_capturedWhite.isNotEmpty) Padding(padding: const EdgeInsets.only(left: 12, top: 4), child: Row(children: [const Text('⚪ ', style: TextStyle(fontSize: 16)), ..._capturedWhite.map((p) => Text(p, style: const TextStyle(fontSize: 16)))])),
        // Board
        Expanded(child: Padding(padding: const EdgeInsets.all(8), child: AspectRatio(aspectRatio: 1, child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
          itemCount: 64, itemBuilder: (_, i) {
            int r = i ~/ 8, c = i % 8;
            bool isLight = (r + c) % 2 == 0;
            bool isSelected = _selectedRow == r && _selectedCol == c;
            bool isValidMove = _validMoves.contains('$r,$c');
            return GestureDetector(onTap: () => _onTap(r, c), child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.yellow.shade300 : (isValidMove ? Colors.green.shade200 : (isLight ? Colors.orange.shade100 : Colors.orange.shade800)),
                border: isSelected ? Border.all(color: Colors.yellow, width: 2) : null,
              ),
              child: Center(child: Text(_board[r][c].isNotEmpty ? (_pieces[_board[r][c]] ?? '') : '', style: TextStyle(fontSize: 28, shadows: [Shadow(color: Colors.black38, blurRadius: 2)]))),
            ));
          },
        )))),
      ]),
    );
  }
}
