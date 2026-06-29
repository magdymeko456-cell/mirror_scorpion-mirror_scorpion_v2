import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart'; // ✅ HOTFIX: هذا الـ import كان مفقوداً

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
  bool _isTranslating = false;
  String _pickedFileName = '';

  static const Map<String, String> _langs = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français',
    'es': 'Español', 'de': 'Deutsch', 'tr': 'Türkçe',
    'fa': 'فارسی', 'ur': 'اردو', 'hi': 'हिन्दी',
  };

  @override
  void initState() {
    super.initState();
    if (widget.initialText.isNotEmpty) _inputController.text = widget.initialText;
  }

  @override
  void dispose() { _inputController.dispose(); _outputController.dispose(); super.dispose(); }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'doc', 'docx', 'pdf', 'json', 'csv', 'xml', 'html'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        setState(() {
          _pickedFileName = result.files.single.name;
          _inputController.text = content.length > 5000 ? content.substring(0, 5000) : content;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ تم رفع الملف: $_pickedFileName')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _translate() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': text.length > 2000 ? text.substring(0, 2000) : text, 'source': _fromLanguage, 'target': _toLanguage, 'format': 'text'}),
      ).timeout(const Duration(seconds: 20));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() => _outputController.text = data['translatedText'] ?? '❌ فشلت الترجمة');
      } else {
        setState(() => _outputController.text = '⚠️ تعذر الاتصال بالخادم');
      }
    } catch (e) { setState(() => _outputController.text = '⚠️ خطأ: $e'); }
    setState(() => _isTranslating = false);
  }

  void _swapLanguages() { setState(() { final t = _fromLanguage; _fromLanguage = _toLanguage; _toLanguage = t; }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌐 ترجمة نصوص'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.attach_file), onPressed: _pickFile, tooltip: 'رفع ملف')],
      ),
      body: Column(
        children: [
          Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12), color: Colors.teal.withOpacity(0.05),
            child: const Text('🦂 Mirror Scorpion — ترجم هذا بواسطه ميرور اسكربيون', style: TextStyle(fontSize: 10, color: Colors.teal), textAlign: TextAlign.center)),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(children: [
              Expanded(child: DropdownButtonFormField<String>(value: _fromLanguage, items: _langs.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(), onChanged: (v) => setState(() => _fromLanguage = v ?? 'ar'), decoration: const InputDecoration(labelText: 'من', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)))),
              IconButton(onPressed: _swapLanguages, icon: const Icon(Icons.swap_horiz, color: Colors.teal)),
              Expanded(child: DropdownButtonFormField<String>(value: _toLanguage, items: _langs.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(), onChanged: (v) => setState(() => _toLanguage = v ?? 'en'), decoration: const InputDecoration(labelText: 'إلى', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)))),
            ]),
          ),
          Expanded(flex: 3, child: Container(margin: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), color: Colors.grey.shade100,
                child: Row(children: [const Text('📝 النص الأصلي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const Spacer(),
                  if (_pickedFileName.isNotEmpty) Text(_pickedFileName, style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
                  if (_pickedFileName.isNotEmpty) IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () { setState(() { _inputController.clear(); _pickedFileName = ''; }); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ]),
              ),
              Expanded(child: TextField(controller: _inputController, decoration: const InputDecoration(hintText: 'اكتب النص هنا أو ارفع ملفاً...', border: InputBorder.none, contentPadding: EdgeInsets.all(12)), maxLines: null, expands: true, textDirection: TextDirection.rtl)),
            ]),
          )),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: _isTranslating ? null : _translate,
              icon: _isTranslating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.translate),
              label: Text(_isTranslating ? 'جاري الترجمة...' : '🔄 ترجمة'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
            )),
          ),
          Expanded(flex: 4, child: Container(margin: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), color: Colors.teal.shade50,
                child: Row(children: [
                  const Text('🌐 الترجمة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const Spacer(),
                  IconButton(icon: const Icon(Icons.copy, size: 18, color: Colors.teal), onPressed: () { Clipboard.setData(ClipboardData(text: _outputController.text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم النسخ'))); }, padding: EdgeInsets.zero, constraints: const BoxConstraints( + "

— Mirror Scorpion 🦂")),
                  IconButton(icon: const Icon(Icons.share, size: 18, color: Colors.teal), onPressed: () { Clipboard.setData(ClipboardData(text: '${_outputController.text}\n\n— تمت الترجمة بواسطة ميرور سكربيون 🦂')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ تم التجهيز للمشاركة مع توقيع التطبيق'))); }, padding: EdgeInsets.zero, constraints: const BoxConstraints( + "

— Mirror Scorpion 🦂")),
                ]),
              ),
              Expanded(child: TextField(controller: _outputController, decoration: const InputDecoration(hintText: 'الترجمة...', border: InputBorder.none, contentPadding: EdgeInsets.all(12)), maxLines: null, expands: true, readOnly: true)),
            ]),
          )),
        ],
      ),
    );
  }
}
