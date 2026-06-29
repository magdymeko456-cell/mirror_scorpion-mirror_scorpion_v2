import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});
  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  String _selectedLanguage = 'en';
  bool _isProcessing = false;
  String _status = '';

  static const Map<String, String> _langs = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français',
    'es': 'Español', 'de': 'Deutsch',
  };

  @override
  void dispose() {
    _urlController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _processDocument() {
    if (_urlController.text.trim().isEmpty) {
      setState(() => _status = '⚠️ أدخل رابط المستند');
      return;
    }
    setState(() {
      _isProcessing = true;
      _status = 'جاري معالجة المستند...';
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _resultController.text = '📄 تمت معالجة المستند\n\n'
              'الرابط: ${_urlController.text}\n'
              'اللغة المستهدفة: ${_langs[_selectedLanguage] ?? _selectedLanguage}\n\n'
              '— Mirror Scorpion 🦂';
          _status = '✅ تمت المعالجة';
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('📄 مستندات وعدسة'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: (v) => setState(() => _selectedLanguage = v),
            itemBuilder: (_) => _langs.entries
                .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Watermark
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            color: Colors.teal.withOpacity(0.05),
            child: const Text('🦂 Mirror Scorpion',
                style: TextStyle(fontSize: 10, color: Colors.teal),
                textAlign: TextAlign.center),
          ),

          if (_status.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_status,
                  style: TextStyle(
                    color: _status.contains('✅') ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  )),
            ),

          // URL input
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'الصق رابط المستند...',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _urlController.clear();
                      _resultController.clear();
                      _status = '';
                    });
                  },
                ),
              ),
            ),
          ),

          // Process button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processDocument,
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.document_scanner),
                label: Text(_isProcessing ? 'جاري...' : '📄 معالجة المستند'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Result area
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.teal.shade50,
                    child: Row(
                      children: [
                        const Text('📝 النتيجة',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Colors.teal),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _resultController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ تم النسخ')));
                          },
                          padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _resultController,
                      decoration: const InputDecoration(
                        hintText: 'النتيجة ستظهر هنا...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: null,
                      expands: true,
                      readOnly: true,
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
