import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';

import '../../services/translation_api.dart';
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

  String _fileName = '';

  final ImagePicker _picker = ImagePicker();
  TextRecognizer? _recognizer;

  static const Map<String, String> _langs = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'de': 'Deutsch',
    'es': 'Español', 'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی',
    'hi': 'हिन्दी', 'bn': 'বাংলা', 'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu',
    'nl': 'Nederlands', 'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk',
    'fi': 'Suomi', 'no': 'Norsk', 'cs': 'Čeština', 'hu': 'Magyar',
    'ro': 'Română', 'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย',
    'vi': 'Tiếng Việt', 'tl': 'Filipino', 'sw': 'Kiswahili',
  };

  @override
  void dispose() {
    _recognizer?.close();
    super.dispose();
  }

  // ── 📷 العدسة: صورة من الكاميرا أو المعرض ──
  Future<void> _pickFromCamera() async => _processPicked(await _picker.pickImage(source: ImageSource.camera));
  Future<void> _pickFromGallery() async => _processPicked(await _picker.pickImage(source: ImageSource.gallery));

  Future<void> _processPicked(XFile? img) async {
    if (img == null) return;
    setState(() {
      _fileName = img.name;
      _extractedText = '';
      _translatedText = '';
      
      _isProcessing = true;
    });
    try {
      _recognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
      final input = InputImage.fromFilePath(img.path);
      final result = await _recognizer!.processImage(input);
      if (!mounted) return;
      setState(() {
        _extractedText = result.text.trim();
        _isProcessing = false;
      });
      if (_extractedText.isEmpty) {
        _showMsg('لم يتم التعرف على نص — جرب صورة أوضح');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showMsg('فشل التعرف على الصورة: $e');
    }
  }

  // ── 📁 اختيار ملف نصي ──
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null || result.files.isEmpty) return;
    final f = result.files.first;
    setState(() {
      _fileName = f.name;
      _extractedText = '';
      _translatedText = '';
      
      _isProcessing = true;
    });
    try {
      final path = f.path;
      if (path == null) throw Exception('مسار فارغ');
      final ext = path.split('.').last.toLowerCase();
      if (!['txt', 'csv', 'json', 'md', 'log', 'srt'].contains(ext)) {
        throw Exception('النوع $ext غير مدعوم — اختر ملفاً نصياً');
      }
      final content = await File(path).readAsString();
      if (!mounted) return;
      setState(() {
        _extractedText = content.trim();
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showMsg('تعذّر قراءة الملف: $e');
    }
  }

  // ── 🔗 فتح رابط داخل webview ──
  Future<void> _openFromBrowser() async {
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('🔗 فتح رابط مستند',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          style: TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'https://example.com/document.txt',
            hintStyle: TextStyle(color: Colors.white30),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(color: Colors.white54))),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('فتح')),
        ],
      ),
    );
    if (url == null || url.isEmpty) return;
    setState(() {
      _fileName = 'رابط: $url';
      _extractedText = '';
      _translatedText = '';
      
    });
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          title: const Text('🌐 المستند من الرابط', style: TextStyle(fontSize: 15)),
          backgroundColor: const Color(0xFF1B2838),
          foregroundColor: Colors.teal,
        ),
        body: WebViewWidget(controller: WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..loadRequest(Uri.parse(url.startsWith('http') ? url : 'https://$url'))),
      ),
    ));
  }

  // ── 🌐 ترجمة النص المستخرج ──
  Future<void> _translate() async {
    if (_extractedText.isEmpty || _isTranslating) return;
    setState(() => _isTranslating = true);
    var res = await TranslationApi.translate(_extractedText, to: _targetLang, from: 'auto');
    if (res.isEmpty) res = '[$targetLang] تعذّر الترجمة الآن — تحقق من الاتصال';
    if (!mounted) return;
    setState(() {
      _translatedText = res;
      _isTranslating = false;
    });
  }

  String get targetLang => _langs[_targetLang] ?? _targetLang;

  void _showMsg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final tts = Provider.of<TTSService>(context);
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('📄 المستندات والعدسة',
            style: TextStyle(color: Colors.white, fontSize: 17)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── مصادر الإدخال ──
            Row(children: [
              Expanded(child: _btn(Icons.photo_camera, 'كاميرا', Colors.blueAccent, _pickFromCamera)),
              const SizedBox(width: 10),
              Expanded(child: _btn(Icons.photo_library, 'المعرض', Colors.tealAccent, _pickFromGallery)),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _btn(Icons.insert_drive_file, 'ملف نصي', Colors.orangeAccent, _pickFile)),
              const SizedBox(width: 10),
              Expanded(child: _btn(Icons.link, 'رابط', Colors.purpleAccent, _openFromBrowser)),
            ]),
            if (_fileName.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('📎 $_fileName', style: TextStyle(color: Colors.white54, fontSize: 12), textAlign: TextAlign.center),
            ],
            const SizedBox(height: 16),

            // ── لغة الترجمة ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _targetLang,
                  dropdownColor: const Color(0xFF0D1B2A),
                  isExpanded: true,
                  style: TextStyle(color: Colors.teal),
                  items: _langs.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Text(e.value,
                                style: TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _targetLang = v!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── النص المستخرج ──
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(color: Colors.teal),
              ),
            if (_extractedText.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('النص المستخرج:',
                        style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    SelectableText(_extractedText,
                        style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isTranslating ? null : _translate,
                  icon: _isTranslating
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.translate),
                  label: Text(_isTranslating ? 'جارٍ الترجمة...' : '🌐 ترجمة المستند'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
            if (_translatedText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Text('الترجمة:', style: TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.greenAccent, size: 20),
                        onPressed: () => tts.speak(_translatedText),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.white54, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _translatedText));
                          _showMsg('✅ تم نسخ الترجمة');
                        },
                      ),
                    ]),
                    const SizedBox(height: 4),
                    SelectableText(_translatedText,
                        style: TextStyle(color: Colors.green.shade300, fontSize: 14, height: 1.6)),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            // ── إشعار 5 صفحات ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text('5 صفحات في النسخة العادية. ترجمة غير محدودة في Pro.',
                        style: TextStyle(fontSize: 12, color: Colors.amber)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _btn(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          color: color.withValues(alpha: 0.05),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
