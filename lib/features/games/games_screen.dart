import 'package:flutter/material.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🦂 الألعاب')),
    body: GridView.count(padding: const EdgeInsets.all(16), crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1,
      children: [
        _g(context, 'ترجمة بالبطاقات', Icons.flip, Colors.blue, 'اختبر مهاراتك'),
        _g(context, 'خمن الكلمة', Icons.quiz, Colors.green, 'خمن المعاني'),
        _g(context, 'ذاكرة المفردات', Icons.memory, Colors.orange, 'طابق الكلمات'),
        _g(context, 'سباق الترجمة', Icons.speed, Colors.red, 'ترجم بأسرع وقت'),
      ],
    ),
  );

  Widget _g(BuildContext c, String t, IconData ic, Color cl, String sub) => Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text('🎮 $t قريباً!'))),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: cl.withOpacity(0.15), shape: BoxShape.circle), child: Icon(ic, size: 36, color: cl)),
        const SizedBox(height: 12), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4), Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey.shade600), textAlign: TextAlign.center),
      ])),
    ),
  );
}
