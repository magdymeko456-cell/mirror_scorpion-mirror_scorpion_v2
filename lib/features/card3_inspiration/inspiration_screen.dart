import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class InspirationScreen extends StatefulWidget {
  final String initialQuote;
  const InspirationScreen({super.key, this.initialQuote = ''});
  @override
  State<InspirationScreen> createState() => _InspirationScreenState();
}

class _InspirationScreenState extends State<InspirationScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<String> _messages = [];
  final TextEditingController _aiController = TextEditingController();
  String _aiMessage = '';
  
  final List<Map<String, String>> _localQuotes = [
    {'quote': 'إن مع العسر يسرا', 'author': 'القرآن الكريم (الشرح: 6)'},
    {'quote': 'لا تحزن إن الله معنا', 'author': 'القرآن الكريم (التوبة: 40)'},
    {'quote': 'وما توفيقي إلا بالله', 'author': 'القرآن الكريم (هود: 88)'},
    {'quote': 'ربنا لا تؤاخذنا إن نسينا أو أخطأنا', 'author': 'القرآن الكريم (البقرة: 286)'},
    {'quote': 'إن الله لا يضيع أجر المحسنين', 'author': 'القرآن الكريم (التوبة: 120)'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialQuote.isNotEmpty) {
      setState(() => _aiMessage = widget.initialQuote);
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _aiController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_inputController.text.trim().isEmpty) return;
    setState(() {
      _messages.add('👤 ${_inputController.text}');
      final random = Random();
      final quote = _localQuotes[random.nextInt(_localQuotes.length)];
      _messages.add('🤖 ${quote['quote']}\n— ${quote['author']}');
      _inputController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💡 إلهام'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            color: Colors.teal.withOpacity(0.05),
            child: const Text('🦂 Mirror Scorpion', style: TextStyle(fontSize: 10, color: Colors.teal), textAlign: TextAlign.center),
          ),
          Expanded(
            child: _aiMessage.isNotEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // ✅ HOTFIX: إزالة const من TextStyle لأن Colors.teal.shade800 ليس ثابتاً
                        Text(_aiMessage,
                            style: TextStyle(fontSize: 14, height: 1.4, color: Colors.teal.shade800),
                            textDirection: TextDirection.rtl),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const Icon(Icons.copyright, size: 14, color: Colors.teal),
                              const SizedBox(width: 6),
                              Text('🦂 ميرور اسكربيون', style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _messages.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (_, i) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(_messages[i], textDirection: TextDirection.rtl),
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    decoration: const InputDecoration(
                      hintText: 'اكتب رسالتك هنا...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sendMessage,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                  child: const Text('إرسال'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
