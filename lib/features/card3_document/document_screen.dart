import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
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
  String _selectedFileName = '';
  String _extractedText = '';
  String _translatedText = '';
  bool _isProcessing = false;
  bool _showOriginal = true;
  String _targetLang = 'ar';

  @override
  void initState() {
    super.initState();
    _loadSavedLang();
  }

  void _loadSavedLang() {
    final langService = context.read<LanguageService>();
    setState(() {
      _targetLang = langService.getLanguageForScreen('document_lang');
      if (_targetLang == 'auto') _targetLang = 'ar';
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
        _extractedText = '';
        _translatedText = '';
      });
      _extractAndTranslate();
    }
  }

  Future<void> _openFromBrowser() async {
    await _pickFile();
  }

  void _pasteLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('الصق الرابط في الحقل أعلاه ثم اضغط بحث')),
    );
  }

  Future<void> _extractAndTranslate() async {
    if (_selectedFilePath == null) return;
    setState(() => _isProcessing = true);

    try {
      final file = File(_selectedFilePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        setState(() => _extractedText = content.isNotEmpty ? content : 'الملف فارغ');
        if (_extractedText.isNotEmpty && _extractedText != 'الملف فارغ') {
          final translated = await TranslationService().translate(
            _extractedText.substring(0, _extractedText.length > 5000 ? 5000 : _extractedText.length),
            from: 'auto', to: _targetLang,
          );
          _translatedText = translated;
        }
      }
    } catch (e) {
      setState(() => _extractedText = 'خطأ: $e');
    }
    setState(() => _isProcessing = false);
  }

  Future<void> _captureWithLens() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      if (image == null) return;
      setState(() => _isProcessing = true);

      // محاكاة التعرف على النص (لأن google_mlkit قد لا يكون متاحاً)
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _extractedText = 'تم التقاط الصورة بنجاح\n(خدمة التعرف على النص من الصور قيد التفعيل الكامل)';
      });

      final translated = await TranslationService().translate(
        _extractedText, from: 'auto', to: _targetLang,
      );
      _translatedText = translated;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
    setState(() => _isProcessing = false);
  }

  void _shareTranslated() {
    if (_translatedText.isEmpty) return;
    final signedText = '${_translatedText}\n\nترجم هذا المستند بواسطة Mirror Scorpion \u{1F982}';
    Share.share(signedText, subject: 'مستند مترجم - Mirror Scorpion');
  }

  @override
  Widget build(BuildContext context) {
    final langService = context.watch<LanguageService>();
    final List<String> langCodes = langService.getLanguageCodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('مستندات وعدسة',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.tealAccent),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.tealAccent, size: 26),
            onPressed: _captureWithLens,
            tooltip: 'عدسة الترجمة',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // اختيار لغة الترجمة
            if (_extractedText.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.language, color: Colors.tealAccent, size: 20),
                  const SizedBox(width: 8),
                  const Text('لغة الترجمة:', style: TextStyle(color: Colors.white54, fontSize: 13)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: langCodes.contains(_targetLang) ? _targetLang : 'ar',
                      dropdownColor: const Color(0xFF0D1B2A),
                      style: const TextStyle(color: Colors.tealAccent, fontSize: 13),
                      underline: const SizedBox(),
                      isExpanded: true,
                      items: langCodes.map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(langService.getLanguageName(code),
                          style: const TextStyle(color: Colors.white, fontSize: 13)),
                      )).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _targetLang = v);
                          langService.saveLanguageForScreen('document_lang', v);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_extractedText.isEmpty) const SizedBox(height: 16),

            // حقل لصق الرابط
            if (_extractedText.isEmpty)
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2838),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const TextField(
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintText: 'الصق الرابط هنا...',
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                        prefixIcon: Icon(Icons.link, color: Colors.white38, size: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.search, color: Colors.tealAccent, size: 24),
                    onPressed: _pasteLink,
                    tooltip: 'بحث',
                  ),
                ),
              ],
            ),
            if (_extractedText.isEmpty) const SizedBox(height: 12),

            // زر فتح من المستعرض
            if (_extractedText.isEmpty)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openFromBrowser,
                icon: const Icon(Icons.folder_open, size: 20),
                label: const Text('فتح من المستعرض'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.withOpacity(0.15),
                  foregroundColor: Colors.tealAccent,
                  side: BorderSide(color: Colors.tealAccent.withOpacity(0.4)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (_extractedText.isEmpty) const SizedBox(height: 20),

            // اسم الملف
            if (_selectedFileName.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.tealAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(_selectedFileName,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      overflow: TextOverflow.ellipsis),
                  ),
                  if (_translatedText.isNotEmpty)
                    TextButton.icon(
                      onPressed: _shareTranslated,
                      icon: const Icon(Icons.share, color: Colors.tealAccent, size: 18),
                      label: const Text('مشاركة', style: TextStyle(color: Colors.tealAccent, fontSize: 12)),
                    ),
                ],
              ),
            ),
            if (_selectedFileName.isNotEmpty) const SizedBox(height: 16),

            // زر الترجمة
            if (_extractedText.isNotEmpty && _translatedText.isEmpty && !_isProcessing)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _extractAndTranslate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                  shadowColor: Colors.tealAccent.withOpacity(0.3),
                ),
                child: const Text('ترجمة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            // شاشة تحميل
            if (_isProcessing)
            Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(width: 60, height: 60,
                    child: CircularProgressIndicator(color: Colors.tealAccent, strokeWidth: 4)),
                  SizedBox(height: 20),
                  Text('جاري المعالجة والترجمة...',
                    style: TextStyle(color: Colors.white54, fontSize: 15)),
                ],
              ),
            ),

            // عرض النص المترجم مع التبديل بالضغط المطول
            if (_translatedText.isNotEmpty && !_isProcessing)
            GestureDetector(
              onLongPress: () => setState(() => _showOriginal = true),
              onLongPressUp: () => setState(() => _showOriginal = false),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _showOriginal ? Colors.teal.withOpacity(0.3) : Colors.amberAccent.withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_showOriginal ? Icons.description : Icons.translate,
                          color: _showOriginal ? Colors.tealAccent : Colors.amberAccent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _showOriginal ? 'المستند الأصلي' : 'المستند المترجم',
                          style: TextStyle(
                            color: _showOriginal ? Colors.tealAccent : Colors.amberAccent,
                            fontSize: 13, fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (!_showOriginal)
                          const Opacity(
                            opacity: 0.4,
                            child: WatermarkText(text: 'Mirror Scorpion'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _showOriginal ? _extractedText : _translatedText,
                      style: TextStyle(
                        color: _showOriginal ? Colors.white70 : Colors.amberAccent,
                        fontSize: 14, height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 12),
                    Opacity(
                      opacity: 0.4,
                      child: Text(
                        'اضغط مطولاً لرؤية المستند الأصلي - ارفع إصبعك للعودة للمترجم',
                        style: TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // الحالة الافتراضية
            if (_extractedText.isEmpty && !_isProcessing)
            Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.description_outlined, size: 100, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 16),
                Text('اختر ملفاً أو صوّر نصاً للترجمة',
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16)),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickFile,
                      icon: const Icon(Icons.upload_file, size: 20),
                      label: const Text('اختيار ملف'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _captureWithLens,
                      icon: const Icon(Icons.camera_alt, size: 20),
                      label: const Text('عدسة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
