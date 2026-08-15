import 'package:flutter/material.dart';

class ChessScreen extends StatefulWidget {
  const ChessScreen({super.key});

  @override
  State<ChessScreen> createState() => _ChessScreenState();
}

class _ChessScreenState extends State<ChessScreen> {
  final List<List<String>> _board = List.generate(8, (_) => List.filled(8, ''));
  String _selectedPiece = '';
  int _selectedRow = -1;
  int _selectedCol = -1;
  bool _isWhiteTurn = true;

  @override
  void initState() {
    super.initState();
    _initBoard();
  }

  void _initBoard() {
    const pieces = ['♜', '♞', '♝', '♛', '♚', '♝', '♞', '♜'];
    for (int i = 0; i < 8; i++) {
      _board[0][i] = pieces[i];
      _board[1][i] = '♟';
      _board[6][i] = '♙';
      _board[7][i] = pieces[i].replaceAll('♜', '♖').replaceAll('♞', '♘')
          .replaceAll('♝', '♗').replaceAll('♛', '♕').replaceAll('♚', '♔');
    }
  }

  void _onCellTap(int row, int col) {
    if (_selectedRow == -1) {
      if (_board[row][col].isNotEmpty) {
        setState(() {
          _selectedRow = row;
          _selectedCol = col;
          _selectedPiece = _board[row][col];
        });
      }
    } else {
      if (_board[row][col].isEmpty) {
        setState(() {
          _board[row][col] = _selectedPiece;
          _board[_selectedRow][_selectedCol] = '';
          _selectedRow = -1;
          _selectedCol = -1;
          _selectedPiece = '';
          _isWhiteTurn = !_isWhiteTurn;
        });
      } else {
        setState(() {
          _selectedRow = -1;
          _selectedCol = -1;
          _selectedPiece = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('♟ شطرنج 3D', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Text(_isWhiteTurn ? '⬜ دور الأبيض' : '⬛ دور الأسود',
            style: TextStyle(
              color: _isWhiteTurn ? Colors.white : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: AspectRatio(
                aspectRatio: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.brown.shade700, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 64,
                    itemBuilder: (_, index) {
                      int row = index ~/ 8;
                      int col = index % 8;
                      bool isDark = (row + col) % 2 == 0;
                      bool isSelected = _selectedRow == row && _selectedCol == col;

                      return GestureDetector(
                        onTap: () => _onCellTap(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.yellow.withValues(alpha: 0.6)
                                : isDark
                                    ? const Color(0xFFB58863)
                                    : const Color(0xFFF0D9B5),
                            border: isSelected
                                ? Border.all(color: Colors.yellow, width: 2)
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _board[row][col],
                              style: TextStyle(
                                fontSize: 32,
                                color: _board[row][col] == _board[row][col]?.toUpperCase()
                                    ? Colors.white
                                    : Colors.black,
                                shadows: [
                                  Shadow(
                                    blurRadius: 2,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('♟ العب بالنقر على القطعة ثم المربع الهدف',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
