import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});

  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedFilePath = '';
  String _selectedFileName = '';
  String _translatedText = '';
  bool _isProcessing = false;
  bool _showOriginal = false;
  bool _isLensMode = false;
  String _lensLanguage = 'auto';

  // توقيع التطبيق
  final String _appSignature = 'ترجم هذا المستند بواسطه ميرور اسكربيون';

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);
    final List<String> langCodes = langService.getLanguageCodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(_isLensMode ? 'العدسة' : 'مستندات وعدسة',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        actions: [
          IconButton(
            icon: Icon(_isLensMode ? Icons.description : Icons.camera_alt,
                color: Colors.orangeAccent),
            onPressed: () => setState(() => _isLensMode = !_isLensMode),
            tooltip: _isLensMode ? 'وضع المستندات' : 'وضع العدسة',
          ),
        ],
      ),
      body: _isLensMode ? _buildLensView(langCodes) : _buildDocumentView(langCodes),
    );
  }

  // ====== وضع العدسة ======
  Widget _buildLensView(List<String> langCodes) {
    final langService = Provider.of<LanguageService>(context);
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // محاكاة عدسة الكاميرا
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.black87, Color(0xFF1A1A2E)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 60, color: Colors.orange.withOpacity(0.3)),
                        const SizedBox(height: 10),
                        Text('وجه الكاميرا نحو النص',
                            style: TextStyle(color: Colors.white38, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text('للترجمة الفورية',
                            style: TextStyle(color: Colors.white24, fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                // إطار العدسة
                Positioned(
                  top: 30, left: 30, right: 30, bottom: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // زر اللغة أسفل العدسة
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orangeAccent),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: langCodes.contains(_lensLanguage) ? _lensLanguage : 'auto',
                        dropdownColor: const Color(0xFF0D1B2A),
                        style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                        items: [
                          const DropdownMenuItem(value: 'auto', child: Text('تلقائي', style: TextStyle(color: Colors.white))),
                          ...langCodes.map((code) => DropdownMenuItem(
                            value: code,
                            child: Text(langService.getLanguageName(code), style: const TextStyle(color: Colors.white, fontSize: 12)),
                          )),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _lensLanguage = v);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ====== وضع المستندات ======
  Widget _buildDocumentView(List<String> langCodes) {
    final isTranslated = _translatedText.isNotEmpty;

    return Column(
      children: [
        if (!isTranslated) ...[
          // حالة عدم وجود ترجمة -> إظهار واجهة الرفع
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // مستطيل متوسط - إدخال رابط
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.teal.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: '粘贴 الرابط هنا...',
                              hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white, size: 22),
                            onPressed: _fetchFromUrl,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // زر فتح من المستعرض
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.folder_open, color: Colors.tealAccent),
                      label: const Text('📂 فتح من المستعرض'),
SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('📂 فتح من المستعرض'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.withOpacity(0.2),
                        foregroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.teal.withOpacity(0.4)),
                        ),
                      ),
                    ),
                  ),

                  // إذا تم اختيار ملف، يظهر مساره
                  if (_selectedFileName.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, color: Colors.tealAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFileName,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // زر الترجمة
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _translateDocument,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.withOpacity(0.2),
                          foregroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.amber.withOpacity(0.4)),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
                            : const Text('🌐 ترجم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],

        // حالة وجود ترجمة -> إظهار المستند المترجم مع التوقيع
        if (isTranslated)
          Expanded(
            child: GestureDetector(
              onLongPressStart: (_) => setState(() => _showOriginal = true),
              onLongPressEnd: (_) => setState(() => _showOriginal = false),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showOriginal
                    ? _buildDocumentViewer('المستند الأصلي', _selectedFileName, Colors.white, false)
                    : Stack(
                        key: const ValueKey('translated'),
                        children: [
                          _buildDocumentViewer('المستند المترجم', _translatedText, Colors.amberAccent, true),
                          // توقيع التطبيق - شفاف عريض مائل 130 درجة
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.08,
                              child: Center(
                                child: Transform.rotate(
                                  angle: 130 * 3.14159 / 180,
                                  child: const Text(
                                    'ترجم هذا المستند بواسطه ميرور اسكربيون',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

        // أزرار المشاركة والإجراءات (تظهر فقط عند وجود ترجمة)
        if (isTranslated)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _shareDocument(),
                  icon: const Icon(Icons.share, color: Colors.tealAccent, size: 20),
                  label: const Text('مشاركة', style: TextStyle(color: Colors.tealAccent)),
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _translatedText = '';
                    _selectedFileName = '';
                    _selectedFilePath = '';
                    _urlController.clear();
                  }),
                  icon: const Icon(Icons.refresh, color: Colors.orangeAccent, size: 20),
                  label: const Text('جديد', style: TextStyle(color: Colors.orangeAccent)),
                ),
              ],
            ),
          ),

        // ملاحظة حدود النسخة المجانية
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black26,
          child: const Text(
            '📄 النسخة المجانية: حتى 5 صفحات • النسخة المدفوعة: غير محدود',
            style: TextStyle(color: Colors.white38, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentViewer(String title, String content, Color textColor, bool isTranslated) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isTranslated ? Colors.amber : Colors.teal).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isTranslated ? Icons.translate : Icons.description,
                  color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                content,
                style: TextStyle(color: textColor, fontSize: 14, height: 1.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchFromUrl() async {
    if (_urlController.text.trim().isEmpty) return;
    setState(() {
      _selectedFileName = _urlController.text.trim();
      _selectedFilePath = _urlController.text.trim();
    });
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path!;
          _selectedFileName = result.files.single.name;
          _urlController.text = _selectedFilePath;
        });
      }
    } catch (e) {
      // Silent
    }
  }

  Future<void> _translateDocument() async {
    if (_selectedFilePath.isEmpty) return;
    setState(() => _isProcessing = true);

    // محاكاة ترجمة لمدة 3 ثوان
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _translatedText = 'تمت ترجمة المستند: $_selectedFileName\n\n'
          'هذه ترجمة تجريبية للمستند المحدد.\n'
          'النسخة المدفوعة تدعم الترجمة الكاملة غير المحدودة.\n\n'
          '---\n'
          '🦂 Mirror Scorpion - حيث تُصنع البدايات';
      _isProcessing = false;
    });
  }

  void _shareDocument() {
    if (_translatedText.isEmpty) return;
    final shareText = '$_appSignature\n\n$_translatedText';
    Share.share(shareText, subject: 'مستند مترجم - Mirror Scorpion');
  }
}
