import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});
  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  String? _selectedFilePath;
  String _extractedText = '';
  String _translatedText = '';
  bool _isProcessing = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _extractedText = '';
        _translatedText = '';
      });
      _extractText();
    }
  }

  Future<void> _extractText() async {
    if (_selectedFilePath == null) return;
    setState(() => _isProcessing = true);
    try {
      final file = File(_selectedFilePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() => _extractedText = content.isNotEmpty ? content : 'تعذر قراءة محتوى الملف');
      } else {
        setState(() => _extractedText = 'الملف غير موجود');
      }
    } catch (e) {
      setState(() => _extractedText = 'خطأ في قراءة الملف: $e');
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('📄 المستندات والترجمة', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.cyanAccent),
            onPressed: _pickFile,
            tooltip: 'اختيار ملف',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_selectedFilePath != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                ),
                child: Text(
                  _selectedFilePath!.split('/').last,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            const SizedBox(height: 16),
            if (_isProcessing)
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Colors.cyanAccent),
                    SizedBox(height: 8),
                    Text('جارٍ المعالجة...', style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            if (_extractedText.isNotEmpty) ...[
              const Text('النص المستخرج:', style: TextStyle(color: Colors.cyanAccent, fontSize: 14)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _extractedText,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
            const Spacer(),
            if (_extractedText.isEmpty && !_isProcessing)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.description_outlined, size: 80, color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text('اختر ملفاً لبدء الترجمة', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 16)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.add),
                      label: const Text('اختيار ملف'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
