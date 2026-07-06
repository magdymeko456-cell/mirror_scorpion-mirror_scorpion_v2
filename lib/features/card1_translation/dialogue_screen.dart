import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialogueScreen extends StatefulWidget {
  final String initialText;
  const DialogueScreen({super.key, this.initialText = ''});
  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  String _fromLanguage = 'ar';
  String _toLanguage = 'en';
  String _statusMessage = '';

  static const Map<String, String> _langs = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français',
    'es': 'Español',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialText.isNotEmpty) _inputController.text = widget.initialText;
  }

  @override
  void dispose() { _inputController.dispose(); _outputController.dispose(); super.dispose(); }

  void _simulateTranslation() {
    if (_inputController.text.trim().isEmpty) {
      setState(() => _statusMessage = '⚠️ أدخل نصاً أولاً');
      return;
    }
    setState(() {
      _statusMessage = 'جاري الترجمة...';
    });
    // محاكاة ترجمة بسيطة
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _outputController.text = '[مترجم إلى ${_langs[_toLanguage] ?? _toLanguage}]\n\n${_inputController.text}';
          _statusMessage = '✅ تمت الترجمة';
        });
      }
    });
  }

  void _swapLanguages() {
    setState(() { final t = _fromLanguage; _fromLanguage = _toLanguage; _toLanguage = t; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌐 ترجمة نصوص'),
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
          if (_statusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_statusMessage, style: TextStyle(color: _statusMessage.contains('✅') ? Colors.green : Colors.orange)),
            ),

          // Language selectors
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(child: DropdownButtonFormField<String>(
                  value: _fromLanguage,
                  items: _langs.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (v) => setState(() => _fromLanguage = v ?? 'ar'),
                  decoration: const InputDecoration(labelText: 'من', border: OutlineInputBorder(), isDense: true),
                )),
                IconButton(onPressed: _swapLanguages, icon: const Icon(Icons.swap_horiz, color: Colors.teal)),
                Expanded(child: DropdownButtonFormField<String>(
                  value: _toLanguage,
                  items: _langs.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (v) => setState(() => _toLanguage = v ?? 'en'),
                  decoration: const InputDecoration(labelText: 'إلى', border: OutlineInputBorder(), isDense: true),
                )),
              ],
            ),
          ),

          // Input
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.grey.shade100,
                    child: Row(children: [
                      const Text('📝 النص الأصلي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () { setState(() { _inputController.clear(); _outputController.clear(); _statusMessage = ''; }); },
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      decoration: const InputDecoration(hintText: 'اكتب النص هنا...', border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
                      maxLines: null, expands: true, textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Translate button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _simulateTranslation,
                icon: const Icon(Icons.translate),
                label: const Text('🔄 ترجمة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Output
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.teal.shade50,
                    child: Row(children: [
                      const Text('🌐 الترجمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 18, color: Colors.teal),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _outputController.text));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم النسخ')));
                        },
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.share, size: 18, color: Colors.teal),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: '${_outputController.text}\n\n— Mirror Scorpion 🦂'));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم التجهيز للمشاركة')));
                        },
                        padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _outputController,
                      decoration: const InputDecoration(hintText: 'الترجمة...', border: InputBorder.none, contentPadding: EdgeInsets.all(12)),
                      maxLines: null, expands: true, readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
