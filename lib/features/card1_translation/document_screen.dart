import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});
  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  String _extractedText = '';
  String _translatedText = '';
  String _targetLang = 'ar';
  bool _isProcessing = false;
  bool _isTranslating = false;
  String? _fileName;
  bool _showOriginal = true;
  final _langs = {'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'de': 'Deutsch', 'es': 'Español', 'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی'};

  void _pickImage() { setState(() { _fileName = 'تم اختيار مستند'; _extractedText = ''; _translatedText = ''; }); _process(); }
  void _openFromBrowser() { setState(() { _fileName = 'تم فتح المستند'; _extractedText = ''; _translatedText = ''; }); _process(); }

  Future<void> _process() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _extractedText = 'نص تجريبي للمستند المترجم.\n\nفي النسخة الكاملة يتم استخدام OCR لاستخراج النص من الصور والمستندات.';
      _isProcessing = false;
    });
  }

  Future<void> _translate() async {
    if (_extractedText.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final resp = await http.post(Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': _extractedText, 'source': 'auto', 'target': _targetLang, 'format': 'text'}),
      ).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        setState(() => _translatedText = data['translatedText'] as String? ?? '');
      }
    } catch (_) { setState(() => _translatedText = '⚠️ فشل الاتصال'); }
    setState(() => _isTranslating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عدسة ومستندات'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(width: double.infinity, height: 200,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300), color: Colors.grey.shade50),
          child: _fileName != null ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.check_circle, size: 40, color: Colors.green),
            const SizedBox(height: 8), Text(_fileName!, style: const TextStyle(color: Colors.grey)),
          ])) : const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.document_scanner, size: 50, color: Colors.grey),
            SizedBox(height: 8), Text('اختر مستنداً للترجمة', style: TextStyle(color: Colors.grey)),
          ])),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _btn(Icons.image, 'المعرض', Colors.teal, _pickImage)),
          const SizedBox(width: 12),
          Expanded(child: _btn(Icons.folder_open, 'المستعرض', Colors.blue, _openFromBrowser)),
        ]),
        const SizedBox(height: 16),
        // URL input
        TextField(decoration: InputDecoration(hintText: 'أو الصق رابط المستند...', border: OutlineInputBorder(), prefixIcon: const Icon(Icons.link), suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () {}))),
        const SizedBox(height: 16),
        // Language
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(30)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(value: _targetLang, isExpanded: true,
            items: _langs.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
            onChanged: (v) => setState(() => _targetLang = v!)))),
        const SizedBox(height: 16),
        if (_isProcessing) const LinearProgressIndicator(),
        if (_extractedText.isNotEmpty && _isProcessing == false) ...[
          const SizedBox(height: 16),
          GestureDetector(
            onLongPress: () => setState(() => _showOriginal = !_showOriginal),
            child: Container(width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.shade200)),
              child: Column(children: [
                Row(children: [
                  Text(_showOriginal ? 'النص الأصلي' : 'النص المترجم', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  const Spacer(),
                  Text('اضغط مطولاً للتبديل', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                ]),
                const SizedBox(height: 8),
                Text(_showOriginal ? _extractedText : (_translatedText.isNotEmpty ? _translatedText : 'اضغط ترجمة أولاً'), style: const TextStyle(fontSize: 14, height: 1.5)),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _isTranslating ? null : _translate,
            icon: _isTranslating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.translate),
            label: Text(_isTranslating ? 'جارٍ الترجمة...' : 'ترجمة المستند'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)))),
        ],
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.amber)),
          child: const Row(children: [
            Icon(Icons.info_outline, color: Colors.amber, size: 20),
            SizedBox(width: 8),
            Expanded(child: Text('ترجمة المستندات: 5 صفحات مجاناً. غير محدود في Pro.', style: TextStyle(fontSize: 12, color: Colors.brown))),
          ]),
        ),
      ])),
    );
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3)), color: color.withOpacity(0.05)),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: color, size: 22), const SizedBox(width: 8), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold))])));
  }
}
