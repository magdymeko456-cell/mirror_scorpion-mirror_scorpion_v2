import 'package:flutter/material.dart';
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
  bool _showTranslatedDoc = false;
  String _urlInput = '';

  final _langs = {'ar': 'العربية', 'en': 'English', 'fr': 'Français',
    'de': 'Deutsch', 'es': 'Español', 'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی',
    'hi': 'हिन्दी', 'bn': 'বাংলা', 'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu',
    'nl': 'Nederlands', 'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk',
    'fi': 'Suomi', 'no': 'Norsk', 'cs': 'Čeština', 'hu': 'Magyar',
    'ro': 'Română', 'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย',
    'vi': 'Tiếng Việt', 'tl': 'Filipino', 'sw': 'Kiswahili',
  };

  void _pickImage() {
    setState(() {
      _fileName = 'تم اختيار مستند'; _extractedText = ''; _translatedText = '';
      _showTranslatedDoc = false;
    });
    _process();
  }

  void _openFromBrowser() {
    setState(() {
      _fileName = 'تم فتح المستند'; _extractedText = ''; _translatedText = '';
      _showTranslatedDoc = false;
    });
    _process();
  }

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
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _translatedText = 'النص المترجم إلى ${_langs[_targetLang] ?? _targetLang}:\n\n$_extractedText';
        _isTranslating = false;
        _showTranslatedDoc = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showTranslatedDoc) return _buildFullScreenDocument();
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦂 ترجمة مستندات وعدسة'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.teal,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ووترمارك
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.teal.withOpacity(0.1),
                child: const Text('🦂 ميرور سكربيون',
                    style: TextStyle(fontSize: 10, color: Colors.teal),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 16),
              // مستطيل عرض المستند
              Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  color: Colors.white.withOpacity(0.05),
                ),
                child: _fileName != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, size: 40, color: Colors.green),
                            const SizedBox(height: 8),
                            Text(_fileName!, style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.document_scanner, size: 50, color: Colors.white38),
                            SizedBox(height: 8),
                            Text('اختر مستنداً للترجمة', style: TextStyle(color: Colors.white38)),
                          ],
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              // أزرار الاختيار
              Row(
                children: [
                  Expanded(child: _btn(Icons.image, 'المعرض', Colors.teal, _pickImage)),
                  const SizedBox(width: 12),
                  Expanded(child: _btn(Icons.folder_open, 'المستعرض', Colors.blue, _openFromBrowser)),
                ],
              ),
              const SizedBox(height: 16),
              // حقل URL
              TextField(
                onChanged: (v) => _urlInput = v,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'أو الصق رابط المستند...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.link, color: Colors.teal),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.teal),
                    onPressed: _urlInput.isNotEmpty ? _openFromBrowser : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // اختيار اللغة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.teal.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _targetLang,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1B2838),
                    style: const TextStyle(color: Colors.white),
                    items: _langs.entries.map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value, style: const TextStyle(color: Colors.white)),
                    )).toList(),
                    onChanged: (v) => setState(() => _targetLang = v!),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // زر الترجمة
              if (_extractedText.isNotEmpty && !_isProcessing)
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
              if (_isProcessing) const Padding(
                padding: EdgeInsets.all(16),
                child: LinearProgressIndicator(),
              ),
              const SizedBox(height: 16),
              // إشعار 5 صفحات
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
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
      ),
    );
  }

  // شاشة Full Screen للمستند المترجم
  Widget _buildFullScreenDocument() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦂 المستند المترجم'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.teal),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ تم تجهيز المستند للمشاركة مع التوقيع')));
            },
          ),
        ],
      ),
      body: GestureDetector(
        onLongPress: () => setState(() => _showOriginal = !_showOriginal),
        onLongPressUp: () => setState(() => _showOriginal = !_showOriginal),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
            ),
          ),
          child: Stack(
            children: [
              // المستند الأصلي
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 40),
                        Text(
                          _showOriginal ? _extractedText : _translatedText,
                          style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.8),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // ورقة الترجمة التي تغطي المستند الأصلي
              if (!_showOriginal)
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2838).withOpacity(0.97),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.withOpacity(0.3)),
                    ),
                    child: Stack(
                      children: [
                        // النص المترجم
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),
                                Text(
                                  _translatedText,
                                  style: TextStyle(color: Colors.green.shade300, fontSize: 16, height: 1.8),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // التوقيع الشفاف
                        Positioned.fill(
                          child: IgnorePointer(
                            child: Transform.rotate(
                              angle: 130 * 3.14159 / 180,
                              child: Center(
                                child: Text(
                                  'ترجم هذا المستند بواسطة ميرور اسكربيون',
                                  style: TextStyle(
                                    color: Colors.teal.withOpacity(0.15),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // دليل long press
                        Positioned(
                          bottom: 8,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Text(
                              _showOriginal ? '👆 اضغط مطولاً للتبديل' : '👆 اضغط مطولاً للرجوع للأصل',
                              style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // دليل long press على الأصل
              if (_showOriginal)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '👆 اضغط مطولاً لرؤية الترجمة',
                      style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 11),
                    ),
                  ),
                ),
            ],
          ),
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
          border: Border.all(color: color.withOpacity(0.3)),
          color: color.withOpacity(0.05),
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
