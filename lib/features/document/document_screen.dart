import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../core/services/tts_service.dart';
import '../core/widgets/shared_widgets.dart';
import '../core/services/database_service.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  String _content = '', _translated = '';
  String _sourceLang = 'auto', _targetLang = 'ar';
  bool _isTranslating = false;
  String _voice = 'Seif';
  bool _showWm = true;
  String? _fileName;
  final List<String> _voices = ['Seif', 'Salma', 'Sama', 'Sara', 'User'];

  Future<void> _pick() async {
    try {
      final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt','json','csv','md','html','xml']);
      if (r != null && r.files.single.path != null) {
        final file = File(r.files.single.path!);
        final content = await file.readAsString();
        setState(() { _content = content; _fileName = r.files.single.name; _translated = ''; });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ $e')));
    }
  }

  Future<void> _translate() async {
    if (_content.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final chunks = _split(_content, 500);
      String result = '';
      for (final chunk in chunks) {
        final resp = await http.post(Uri.parse('https://libretranslate.com/translate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'q': chunk, 'source': _sourceLang == 'auto' ? 'auto' : _sourceLang, 'target': _targetLang}));
        if (resp.statusCode == 200) result += jsonDecode(resp.body)['translatedText'] + ' ';
        await Future.delayed(const Duration(milliseconds: 200));
      }
      setState(() => _translated = result.trim());
    } catch (e) {
      setState(() => _translated = '[🔁 تجريبي]\n${_content.split(' ').map((w) => '$w🌐').join(' ')}');
    }
    setState(() => _isTranslating = false);
  }

  List<String> _split(String text, int size) {
    final w = text.split(' '); final r = <String>[];
    for (int i = 0; i < w.length; i += size) r.add(w.sublist(i, i + size > w.length ? w.length : i + size).join(' '));
    return r;
  }

  void _speak(String text, String lang) {
    if (_voice == 'User') { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎤 صوت المستخدم'))); return; }
    context.read<TtsService>().speak(text, lang, _voice);
  }

  void _share() { SharePlus.instance.share(ShareParams(text: '🦂 Mirror Scorpion\n\n$_translated')); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🦂 ترجمة مستندات'), actions: [
        IconButton(icon: Icon(_showWm ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _showWm = !_showWm)),
      ]),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          ElevatedButton.icon(onPressed: _pick, icon: const Icon(Icons.upload_file), label: Text(_fileName ?? 'اختيار ملف')),
          if (_fileName != null) ...[const SizedBox(width: 8), Chip(label: Text(_fileName!), onDeleted: () => setState(() { _fileName = null; _content = ''; _translated = ''; }))],
        ])),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📄 النص الأصلي', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(child: SingleChildScrollView(child: Text(_content.isEmpty ? 'اختر ملفاً' : _content))),
          ])))),
          const SizedBox(width: 8),
          Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(8), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('🌐 الترجمة', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            Expanded(child: SingleChildScrollView(child: Stack(children: [
              Text(_translated.isEmpty ? 'اضغط ترجمة' : _translated),
              if (_showWm && _translated.isNotEmpty) Positioned(bottom: 0, right: 0, child: WatermarkText(fontSize: 10)),
            ]))),
          ])))),
        ]))),
        Padding(padding: const EdgeInsets.all(8), child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton.icon(onPressed: _content.isEmpty ? null : _translate,
            icon: _isTranslating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.translate),
            label: Text(_isTranslating ? 'جارٍ...' : 'ترجمة')),
          SpeakerButton(voice: _voice, onPressed: () => _speak(_translated, _targetLang)),
          IconButton(icon: const Icon(Icons.share), onPressed: _share),
        ])),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          const Text('🎤 '),
          DropdownButton<String>(value: _voice, underline: const SizedBox(),
            items: _voices.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _voice = v!)),
          const Spacer(),
          if (_showWm) const WatermarkText(fontSize: 10),
        ])),
      ]),
    );
  }
}
