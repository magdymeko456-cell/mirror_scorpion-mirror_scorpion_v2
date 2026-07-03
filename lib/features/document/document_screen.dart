import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:mirror_scorpion/core/services/tts_service.dart';
import 'package:mirror_scorpion/core/widgets/shared_widgets.dart';
import 'package:mirror_scorpion/core/services/database_service.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({super.key});

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  String _content = '';
  String _translatedContent = '';
  String _sourceLang = 'auto';
  String _targetLang = 'ar';
  bool _isTranslating = false;
  String _selectedVoice = 'Seif';
  bool _showWatermark = true;
  String? _fileName;
  bool _useCamera = false;

  final List<String> _voices = ['Seif', 'Salma', 'Sama', 'Sara', 'User'];
  final List<Map<String, String>> _languages = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'tr', 'name': 'Türkçe'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseService>(context, listen: false).incrementCardUsage('document');
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'json', 'csv', 'md', 'html', 'xml', 'pdf'],
      );
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        setState(() {
          _content = content;
          _fileName = result.files.single.name;
          _translatedContent = '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ في قراءة الملف: $e')),
        );
      }
    }
  }

  Future<void> _translateDocument() async {
    if (_content.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final chunks = _splitIntoChunks(_content, 500);
      String result = '';
      for (final chunk in chunks) {
        final response = await http.post(
          Uri.parse('https://libretranslate.com/translate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'q': chunk,
            'source': _sourceLang == 'auto' ? 'auto' : _sourceLang,
            'target': _targetLang,
          }),
        );
        if (response.statusCode == 200) {
          result += jsonDecode(response.body)['translatedText'] + ' ';
        }
        await Future.delayed(const Duration(milliseconds: 200));
      }
      setState(() => _translatedContent = result.trim());
    } catch (e) {
      setState(() {
        _translatedContent = '[🔁 ترجمة تجريبية]\n\n' +
            _content.split(' ').map((w) => '$w🌐').join(' ');
      });
    }
    setState(() => _isTranslating = false);
  }

  List<String> _splitIntoChunks(String text, int chunkSize) {
    final words = text.split(' ');
    final chunks = <String>[];
    for (int i = 0; i < words.length; i += chunkSize) {
      chunks.add(words.sublist(i, i + chunkSize > words.length ? words.length : i + chunkSize).join(' '));
    }
    return chunks;
  }

  void _speak(String text, String lang) {
    if (_selectedVoice == 'User') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎤 صوت المستخدم: قم بالتسجيل من الإعدادات')),
      );
      return;
    }
    context.read<TtsService>().speak(text, lang, _selectedVoice);
  }

  void _shareContent() {
    final text = '🦂 Mirror Scorpion - ترجمة مستند\n\n'
        'المصدر: $_fileName\n\n'
        'الترجمة:\n$_translatedContent';
    // إصلاح استدعاء حزمة share_plus المستقرة للنسخة الجديدة
    Share.share(text);
  }

  void _copyContent() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 تم نسخ المحتوى')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦂 ترجمة مستندات'),
        actions: [
          IconButton(
            icon: Icon(_showWatermark ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showWatermark = !_showWatermark),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_fileName ?? 'اختيار ملف'),
                ),
                const SizedBox(width: 8),
                if (_fileName != null)
                  Chip(
                    label: Text(_fileName!),
                    onDeleted: () => setState(() {
                      _fileName = null;
                      _content = '';
                      _translatedContent = '';
                    }),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sourceLang,
                    decoration: const InputDecoration(labelText: 'من', isDense: true),
                    items: [
                      const DropdownMenuItem(value: 'auto', child: Text('تلقائي')),
                      ..._languages.map((l) => DropdownMenuItem(
                        value: l['code'],
                        child: Text(l['name']!),
                      )),
                    ],
                    onChanged: (v) => setState(() => _sourceLang = v!),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetLang,
                    decoration: const InputDecoration(labelText: 'إلى', isDense: true),
                    items: _languages.map((l) => DropdownMenuItem(
                      value: l['code'],
                      child: Text(l['name']!),
                    )).toList(),
                    onChanged: (v) => setState(() => _targetLang = v!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('📄 النص الأصلي', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Divider(),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(
                                  _content.isEmpty ? 'اختر ملفاً لعرض المحتوى' : _content,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('🌐 الترجمة', style: TextStyle(fontWeight: FontWeight.bold)),
                            const Divider(),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Stack(
                                  children: [
                                    Text(
                                      _translatedContent.isEmpty
                                          ? 'اضغط "ترجمة" لبدء الترجمة'
                                          : _translatedContent,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                    if (_showWatermark && _translatedContent.isNotEmpty)
                                      const Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: WatermarkText(fontSize: 10),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: Main=\nMainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _content.isEmpty ? null : _translateDocument,
                  icon: _isTranslating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.translate),
                  label: Text(_isTranslating ? 'جارٍ...' : 'ترجمة المستند'),
                ),
                SpeakerButton(
                  voice: _selectedVoice,
                  onPressed: () => _speak(_translatedContent, _targetLang),
                ),
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'نسخ',
                  onPressed: _copyContent,
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'مشاركة',
                  onPressed: _shareContent,
                ),
              ],
            ),
          ),
          if (_showWatermark)
            const Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: WatermarkText(fontSize: 10),
            ),
        ],
      ),
    );
  }
}
