import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../services/language_service.dart';
import '../../services/translation_service.dart';
import '../../core/widgets/shared_widgets.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});
  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  String? _selectedFilePath;
  String _selectedFileName = '', _extractedText = '', _translatedText = '';
  bool _isProcessing = false, _showOriginal = true;
  String _targetLang = 'ar';

  @override
  void initState() { super.initState(); _loadSavedLang(); }
  void _loadSavedLang() {
    final ls = context.read<LanguageService>();
    setState(() { _targetLang = ls.getLanguageForScreen('document_lang'); if (_targetLang == 'auto') _targetLang = 'ar'; });
  }

  Future<void> _pickFile() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt','pdf','doc','docx']);
    if (r != null && r.files.single.path != null) {
      setState(() { _selectedFilePath = r.files.single.path; _selectedFileName = r.files.single.name; _extractedText = ''; _translatedText = ''; });
      _extractAndTranslate();
    }
  }
  Future<void> _openFromBrowser() async { await _pickFile(); }

  Future<void> _extractAndTranslate() async {
    if (_selectedFilePath == null) return;
    setState(() => _isProcessing = true);
    try {
      final file = File(_selectedFilePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (mounted) setState(() => _extractedText = content.isNotEmpty ? content : 'الملف فارغ');
        if (content.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 3));
          final ts = context.read<TranslationService>();
          final r = await ts.translate(content.length > 5000 ? content.substring(0, 5000) : content, 'auto', _targetLang);
          if (mounted) setState(() { _translatedText = r; _isProcessing = false; _showOriginal = false; });
        } else { if (mounted) setState(() => _isProcessing = false); }
      } else { if (mounted) setState(() => _isProcessing = false); }
    } catch (e) { if (mounted) { setState(() => _isProcessing = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e'))); } }
  }

  void _shareTranslated() {
    if (_translatedText.isEmpty) return;
    SharePlus.instance.share(ShareParams(text: "ترجم هذا المستند بواسطة Mirror Scorpion 🦂\n\n$_translatedText"));
  }

  @override
  Widget build(BuildContext context) {
    final ls = context.watch<LanguageService>();
    final codes = ls.getAvailableLanguages();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: const Text('ترجمة مستندات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.camera_alt, color: Colors.tealAccent, size:24), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عدسة الترجمة قيد التفعيل قريباً'))); }, tooltip: 'عدسة الترجمة'),
          PopupMenuButton<String>(icon: const Icon(Icons.language, color: Colors.tealAccent),
            onSelected: (l) { setState(() => _targetLang = l); ls.saveLanguageForScreen('document_lang', l); },
            itemBuilder: (c) => codes.map((c) => PopupMenuItem(value: c, child: Text('${ls.getLanguageName(c)} ($c)', style: const TextStyle(color: Colors.white)))).toList()),
        ]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        if (_extractedText.isEmpty) Row(children: [
          Expanded(child: Container(height:48, padding: const EdgeInsets.symmetric(horizontal:16),
            decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.tealAccent.withOpacity(0.3))),
            child: TextField(style: const TextStyle(color: Colors.white, fontSize:14), decoration: InputDecoration(border: InputBorder.none, hintText: 'الصق رابط المستند...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize:13))))),
          const SizedBox(width:8),
          Container(decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: const Icon(Icons.search, color: Colors.tealAccent, size:24), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري معالجة الرابط...'))); }, tooltip: 'بحث'))
        ]),
        if (_extractedText.isEmpty) const SizedBox(height:12),
        if (_extractedText.isEmpty) SizedBox(width: double.infinity,
          child: ElevatedButton.icon(onPressed: _openFromBrowser, icon: const Icon(Icons.folder_open, size:20), label: const Text('فتح من المستعرض'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent.withOpacity(0.15), foregroundColor: Colors.tealAccent,
              side: BorderSide(color: Colors.tealAccent.withOpacity(0.4)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical:14)))),
        if (_extractedText.isEmpty) const SizedBox(height:20),
        if (_selectedFileName.isNotEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.withOpacity(0.3))),
          child: Row(children: [const Icon(Icons.insert_drive_file, color: Colors.tealAccent, size:20), const SizedBox(width:8),
            Expanded(child: Text(_selectedFileName, style: const TextStyle(color: Colors.white, fontSize:13), overflow: TextOverflow.ellipsis)),
            if (_translatedText.isNotEmpty) TextButton.icon(onPressed: _shareTranslated, icon: const Icon(Icons.share, color: Colors.tealAccent, size:18), label: const Text('مشاركة', style: TextStyle(color: Colors.tealAccent, fontSize:12))),
          ])),
        if (_selectedFileName.isNotEmpty) const SizedBox(height:16),
        if (_extractedText.isNotEmpty && _translatedText.isEmpty && !_isProcessing) SizedBox(width: double.infinity,
          child: ElevatedButton(onPressed: _extractAndTranslate,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical:16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation:5, shadowColor: Colors.tealAccent.withOpacity(0.3)),
            child: const Text('ترجمة', style: TextStyle(fontSize:18, fontWeight: FontWeight.bold)))),
        if (_isProcessing) Container(width: double.infinity, height:300,
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(20)),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width:60, height:60, child: CircularProgressIndicator(color: Colors.tealAccent, strokeWidth:4)),
            SizedBox(height:20), Text('جاري قراءة الملف وترجمته...', style: TextStyle(color: Colors.white54, fontSize:15)),
            SizedBox(height:8), Text('قد تستغرق العملية بضع ثوانٍ', style: TextStyle(color: Colors.white24, fontSize:12))])),
        if (_translatedText.isNotEmpty && !_isProcessing) GestureDetector(
          onLongPress: () => setState(() => _showOriginal = true),
          onLongPressUp: () => setState(() => _showOriginal = false),
          child: Container(width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _showOriginal ? Colors.teal.withOpacity(0.3) : Colors.amberAccent.withOpacity(0.4), width:1.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(_showOriginal ? Icons.description : Icons.translate, color: _showOriginal ? Colors.tealAccent : Colors.amberAccent, size:18),
                const SizedBox(width:8),
                Text(_showOriginal ? 'المستند الأصلي' : 'المستند المترجم', style: TextStyle(color: _showOriginal ? Colors.tealAccent : Colors.amberAccent, fontSize:13, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (!_showOriginal) const Opacity(opacity:0.4, child: WatermarkText(text: 'Mirror Scorpion')),
              ]),
              const SizedBox(height:12),
              Text(_showOriginal ? _extractedText : _translatedText, style: TextStyle(color: _showOriginal ? Colors.white70 : Colors.amberAccent, fontSize:14, height:1.6), textAlign: TextAlign.justify),
              const SizedBox(height:12),
              Opacity(opacity:0.4, child: Text('اضغط مطولاً لرؤية المستند الأصلي - ارفع إصبعك للعودة للمترجم', style: TextStyle(color: Colors.white, fontSize:11))),
            ]))),
        if (_extractedText.isEmpty && !_isProcessing) Column(children: [
          const SizedBox(height:40), Icon(Icons.description_outlined, size:100, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height:16), Text('اختر ملفاً لبدء الترجمة', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize:16)),
          const SizedBox(height:24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(onPressed: _pickFile, icon: const Icon(Icons.upload_file, size:20), label: const Text('اختيار ملف'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal:24, vertical:14))),
            const SizedBox(width:16),
            ElevatedButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عدسة الترجمة قيد التفعيل'))); },
              icon: const Icon(Icons.camera_alt, size:20), label: const Text('عدسة'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal:24, vertical:14))),
          ])
        ]),
      ])),
    );
  }
}
