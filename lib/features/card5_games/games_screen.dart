import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/language_service.dart';
import 'chess_screen.dart';
import 'rubik_screen.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  String? _selectedOption;
  bool _showResult = false;
  bool _isCorrect = false;

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);
    // جلب التحدي الذكي من محرك الذكاء الاصطناعي بناءً على اللغة الحالية
    final challenge = langService.generateSmartGameChallenge(
      langService.getLanguageForScreen('dialogue_from')
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('ركن الألعاب والذكاء', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- كارت تحدي الذكاء الاصطناعي التفاعلي ---
            Card(
              color: const Color(0xFF1B2838),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: Colors.cyanAccent, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          'تحدي الذكاء الاصطناعي اليومي',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white10, height: 20),
                    Text(
                      challenge['question'],
                      style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(challenge['options'].length, (index) {
                      final option = challenge['options'][index];
                      return RadioListTile<String>(
                        title: Text(option, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                        value: option,
                        groupValue: _selectedOption,
                        activeThumbColor: Colors.cyanAccent,
                        onChanged: (val) {
                          setState(() {
                            _selectedOption = val;
                            _showResult = false;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('💡 تلميحة: ${challenge['hint']}'),
                                backgroundColor: const Color(0xFF1B2838),
                              ),
                            );
                          },
                          child: const Text('إظهار تلميحة', style: TextStyle(color: Colors.amberAccent)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent.shade700,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: _selectedOption == null ? null : () {
                            setState(() {
                              _showResult = true;
                              _isCorrect = _selectedOption == challenge['answer'];
                            });
                          },
                          child: const Text('تحقق من الإجابة'),
                        ),
                      ],
                    ),
                    if (_showResult) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isCorrect ? Colors.green.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _isCorrect ? Colors.green : Colors.red),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isCorrect ? Icons.check_circle : Icons.cancel,
                              color: _isCorrect ? Colors.greenAccent : Colors.redAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _isCorrect ? 'إجابة عبقرية صحيحة! 🎉' : 'حاول مرة أخرى يا بطل! ❌',
                              style: TextStyle(color: _isCorrect ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- أزرار الدخول للألعاب الأساسية ---
            const Text(
              'الألعاب الاستراتيجية',
              style: TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            
            // زر الشطرنج
            ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF1B2838),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.3)),
              ),
            ).primaryElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChessScreen()),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.grid_on, color: Colors.amberAccent),
                  SizedBox(width: 12),
                  Text('🎮 خوض معركة الشطرنج 3D', style: TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // زر مكعب روبيك
            ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF1B2838),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
              ),
            ).primaryElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RubikScreen()),
                );
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.view_in_ar, color: Colors.greenAccent),
                  SizedBox(width: 12),
                  Text('🧩 حل مكعب روبيك السحري', style: TextStyle(color: Colors.white, fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// إضافة Extension لتسهيل عمل التصميم المتناسق بدون كسر الهيكل القديم
extension on ButtonStyle {
  ElevatedButton primaryElevatedButton({required VoidCallback onPressed, required Widget child}) {
    return ElevatedButton(style: this, onPressed: onPressed, child: child);
  }
}
