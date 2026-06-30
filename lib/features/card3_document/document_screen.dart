import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/language_service.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});
  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _filePath = '';
  String _fileName = '';
  String _translated = '';
  bool _loading = false;
  bool _showOriginal = false;
  bool _lensMode = false;
  String _lensLang = 'auto';
  static const String _sig = 'ترجم هذا المستند بواسطه ميرور اسكربيون';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(_lensMode ? 'العدسة' : 'مستندات وعدسة', style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        actions: [
          IconButton(
            icon: Icon(_lensMode ? Icons.description : Icons.camera_alt, color: Colors.orangeAccent),
            onPressed: () => setState(() => _lensMode = !_lensMode),
          ),
        ],
      ),
      body: _lensMode ? _lensUI() : _docUI(),
    );
  }

  Widget _lensUI() {
    final lang = context.watch<LanguageService>();
    final codes = lang.getLanguageCodes();
    return Column(children: [
      Expanded(child: Container(margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.orange.withOpacity(0.3))),
        child: Stack(alignment: Alignment.bottomCenter, children: [
          Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Colors.black87, Color(0xFF1A1A2E)])),
            child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.camera_alt, size: 60, color: Colors.orange.withOpacity(0.3)),
              const SizedBox(height: 10), const Text('وجه الكاميرا نحو النص', style: TextStyle(color: Colors.white38)),
              const SizedBox(height: 5), const Text('للترجمة الفورية', style: TextStyle(color: Colors.white24)),
            ]))),
          Positioned(top: 30, left: 30, right: 30, bottom: 80,
            child: Container(decoration: BoxDecoration(border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
              borderRadius: BorderRadius.circular(12)))),
          Positioned(bottom: 20, child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orangeAccent)),
            child: DropdownButtonHideUnderline(child: DropdownButton<String>(
              value: codes.contains(_lensLang) ? _lensLang : 'auto',
              dropdownColor: const Color(0xFF0D1B2A),
              style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
              items: [const DropdownMenuItem(value: 'auto', child: Text('تلقائي', style: TextStyle(color: Colors.white))),
                ...codes.map((c) => DropdownMenuItem(value: c, child: Text(lang.getLanguageName(c),
                  style: const TextStyle(color: Colors.white, fontSize: 12))))],
              onChanged: (v) { if (v != null) setState(() => _lensLang = v); },
            )))),
        ]))),
    ]);
  }

  Widget _docUI() {
    final done = _translated.isNotEmpty;
    return Column(children: [
      if (!done) ...[
        Expanded(child: Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.teal.withOpacity(0.3))),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(height: 50, decoration: BoxDecoration(color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.teal.withOpacity(0.3))),
              child: Row(children: [
                Expanded(child: TextField(controller: _urlController,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'الصق الرابط هنا...',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 13), border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16)))),
                Container(margin: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.teal,
                  borderRadius: BorderRadius.circular(12)),
                  child: IconButton(icon: const Icon(Icons.search, color: Colors.white, size: 22),
                    onPressed: _fetchUrl)),
              ])),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton.icon(
              onPressed: _pickFile,
              icon: const Icon(Icons.folder_open, color: Colors.tealAccent),
              label: const Text('📂 فتح من المستعرض'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.withOpacity(0.2),
                foregroundColor: Colors.tealAccent, padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
                  side: BorderSide(color: Colors.teal.withOpacity(0.4)))))),
            if (_fileName.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  const Icon(Icons.insert_drive_file, color: Colors.tealAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(_fileName, style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis)),
                ])),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: _loading ? null : _translateDoc,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.withOpacity(0.2),
                  foregroundColor: Colors.amber, padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.amber.withOpacity(0.4)))),
                child: _loading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
                  : const Text('🌐 ترجم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))),
            ],
          ]))),
      ],
      if (done) ...[
        Expanded(child: GestureDetector(
          onLongPressStart: (_) => setState(() => _showOriginal = true),
          onLongPressEnd: (_) => setState(() => _showOriginal = false),
          child: AnimatedSwitcher(duration: const Duration(milliseconds: 300),
            child: _showOriginal
              ? _contentBox('المستند الأصلي', _fileName, Colors.white, ValueKey('orig'))
              : Stack(key: const ValueKey('trans'), children: [
                  _contentBox('المستند المترجم', _translated, Colors.amberAccent, const ValueKey('tc')),
                  Positioned.fill(child: Opacity(opacity: 0.08, child: Center(
                    child: Transform.rotate(angle: 130 * 3.14159 / 180,
                      child: const Text(_sig, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))))))
                ])))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF1B2838),
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            TextButton.icon(onPressed: () => Share.share('$_sig\n\n$_translated'),
              icon: const Icon(Icons.share, color: Colors.tealAccent),
              label: const Text('مشاركة', style: TextStyle(color: Colors.tealAccent))),
            TextButton.icon(onPressed: () { setState(() { _translated = ''; _fileName = ''; _filePath = ''; _urlController.clear(); }); },
              icon: const Icon(Icons.refresh, color: Colors.orangeAccent),
              label: const Text('جديد', style: TextStyle(color: Colors.orangeAccent))),
          ])),
      ],
      Container(padding: const EdgeInsets.all(8), color: Colors.black26,
        child: const Text('📄 النسخة المجانية: حتى 5 صفحات • النسخة المدفوعة: غير محدود',
          style: TextStyle(color: Colors.white38, fontSize: 10), textAlign: TextAlign.center)),
    ]);
  }

  Widget _contentBox(String title, String body, Color color, Key key) {
    return Container(key: key, margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (color == Colors.amberAccent ? Colors.amber : Colors.teal).withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(color == Colors.amberAccent ? Icons.translate : Icons.description, color: color, size: 20),
          const SizedBox(width: 8), Text(title, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
        const Divider(color: Colors.white12),
        Expanded(child: SingleChildScrollView(child: Text(body, style: TextStyle(color: color, fontSize: 14, height: 1.8)))),
      ]));
  }

  void _fetchUrl() {
    if (_urlController.text.trim().isEmpty) return;
    setState(() { _fileName = _urlController.text.trim(); _filePath = _urlController.text.trim(); });
  }

  Future<void> _pickFile() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','txt','doc','docx','png','jpg','jpeg']);
    if (r != null && r.files.single.path != null) {
      setState(() { _filePath = r.files.single.path!; _fileName = r.files.single.name; _urlController.text = _filePath; });
    }
  }

  Future<void> _translateDoc() async {
    if (_filePath.isEmpty) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _translated = 'تمت ترجمة المستند: $_fileName\n\nهذه ترجمة تجريبية.\nالنسخة المدفوعة تدعم الترجمة الكاملة غير المحدودة.\n\n---\n🦂 Mirror Scorpion';
      _loading = false;
    });
  }
}
