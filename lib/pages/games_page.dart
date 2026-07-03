import 'package:flutter/material.dart';

class GamesPage extends StatefulWidget {
  const GamesPage({super.key});

  @override
  State<GamesPage> createState() => _GamesPageState();
}

class _GamesPageState extends State<GamesPage> {
  int _selectedGame = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الألعاب'),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
      ),
      body: Column(
        children: [
          // اختيار اللعبة
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: _gameButton(0, 'شطرنج 3D', Icons.extension),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _gameButton(1, 'روبيك 3D', Icons.grid_on),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _selectedGame == 0
                ? _buildChess3D()
                : _buildRubik3D(),
          ),
        ],
      ),
    );
  }

  Widget _gameButton(int index, String title, IconData icon) {
    final isSelected = _selectedGame == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedGame = index),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChess3D() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // تمثيل مبسط للوحة شطرنج
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(10, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                children: List.generate(8, (row) {
                  return Expanded(
                    child: Row(
                      children: List.generate(8, (col) {
                        final isDark = (row + col) % 2 == 0;
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF769656)
                                  : const Color(0xFFEEEED2),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.1),
                                width: 0.5,
                              ),
                            ),
                            child: Center(
                              child: (row == 0 || row == 7) && (col == 0 || col == 7)
                                  ? Icon(
                                      Icons.extension,
                                      size: 20,
                                      color: row == 0 ? Colors.black : Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'شطرنج 3D - قريباً مع محرك AI',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اللوحة ثلاثية الأبعاد قيد التطوير',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRubik3D() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // تمثيل مبسط لمكعب روبيك
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(8, 8),
                ),
              ],
            ),
            child: Column(
              children: List.generate(3, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(3, (col) {
                      final colors = [Colors.red, Colors.blue, Colors.green,
                                       Colors.yellow, Colors.orange, Colors.white,
                                       Colors.purple, Colors.cyan, Colors.brown];
                      final index = (row * 3 + col) % colors.length;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: colors[index],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'مكعب روبيك 3D - بجميع طرق الحل',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'قريباً مع محاكاة ثلاثية الأبعاد كاملة',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }
}
