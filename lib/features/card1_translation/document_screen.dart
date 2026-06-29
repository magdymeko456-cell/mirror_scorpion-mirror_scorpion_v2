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

  final _langs = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français',
    'de': 'Deutsch', 'es': 'Español', 'tr': 'Türkçe',
    'ur': 'اردو', 'fa': 'فارسی',
  };

  Future<void> _pickImage() async {
    setState(() {
      _fileName = 'تم اختيار صورة (تجريبي)';
      _extractedText = '';
      _translatedText = '';
    });
    _extractTextFromImage();
  }

  Future<void> _captureWithCamera() async {
    setState(() {
      _fileName = 'تم التقاط صورة (تجريبي)';
      _extractedText = '';
      _translatedText = '';
    });
    _extractTextFromImage();
  }

  Future<void> _extractTextFromImage() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _extractedText = 'نص تجريبي مستخرج من الصورة:\n\n'
          'هذا نص تجريبي. في الإصدار الكامل سيتم استخدام Google ML Kit '
          'لاستخراج النص تلقائياً من الصورة وترجمته.';
      _isProcessing = false;
    });
  }

  Future<void> _translate() async {
    if (_extractedText.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final resp = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': _extractedText, 'source': 'auto', 'target': _targetLang, 'format': 'text'}),
      ).timeout(const Duration(seconds: 15));
      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        setState(() => _translatedText = data['translatedText'] as String? ?? '');
      }
    } catch (_) {
      setState(() => _translatedText = '⚠️ فشل الاتصال — تحقق من الإنترنت');
    }
    setState(() => _isTranslating = false);
  }

  void _speakTranslation() {
    if (_translatedText.isNotEmpty) {
      Provider.of<TTSService>(context, listen: false).speak(_translatedText, language: _targetLang);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('عدسة ومستندات 📄', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Preview area
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
              color: Colors.white.withOpacity(0.02),
            ),
            child: _fileName != null
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.check_circle, size: 40, color: Colors.greenAccent.withOpacity(0.6)),
                      const SizedBox(height: 8),
                      Text(_fileName!, style: const TextStyle(color: Colors.white54)),
                    ]),
                  )
                : Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.document_scanner, size: 50, color: Colors.tealAccent.withOpacity(0.4)),
                      const SizedBox(height: 8),
                      const Text('اختر صورة أو مستند للترجمة', style: TextStyle(color: Colors.white38)),
                    ]),
                  ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(children: [
            Expanded(child: _actionButton(Icons.image, 'المعرض', Colors.tealAccent, _pickImage)),
            const SizedBox(width: 12),
            Expanded(child: _actionButton(Icons.camera_alt, 'الكاميرا', Colors.blueAccent, _captureWithCamera)),
          ]),
          const SizedBox(height: 16),

          // Language selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _targetLang,
                isExpanded: true,
                dropdownColor: const Color(0xFF1B2838),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.tealAccent),
                items: _langs.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(color: Colors.white)))).toList(),
                onChanged: (v) => setState(() => _targetLang = v!),
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_isProcessing)
            const LinearProgressIndicator(backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation<Color>(Colors.tealAccent)),
          if (_isProcessing) const SizedBox(height: 8),

          if (_extractedText.isNotEmpty) ...[
            const Text('النص المستخرج:', style: TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.tealAccent.withOpacity(0.2))),
              child: Text(_extractedText, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTranslating ? null : _translate,
                icon: _isTranslating
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.translate),
                label: Text(_isTranslating ? 'جارٍ الترجمة...' : 'ترجمة النص'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent.withOpacity(0.2),
                  foregroundColor: Colors.tealAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.tealAccent.withOpacity(0.3))),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],

          if (_translatedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('النص المترجم:', style: TextStyle(color: Colors.amberAccent, fontSize: 13)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amberAccent.withOpacity(0.2))),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(_translatedText, style: const TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold, height: 1.5))),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _speakTranslation,
                  child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.volume_up, color: Colors.cyanAccent, size: 22)),
                ),
              ]),
            ),
          ],
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _actionButton(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3)), color: color.withOpacity(0.05)),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
