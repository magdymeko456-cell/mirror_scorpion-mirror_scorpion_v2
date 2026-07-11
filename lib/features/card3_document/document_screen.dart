import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../services/language_service.dart';
import '../../core/widgets/shared_widgets.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});

  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  String? _selectedFilePath;
  String? _selectedFileName;
  bool _isTranslating = false;
  bool _showOriginal = false;
  int _currentPage = 1;
  static const int _maxFreePages = 5;
  String _sourceLanguage = 'auto';
  String _targetLanguage = 'ar';

  @override
  void initState() {
    super.initState();
    _loadSavedLanguages();
  }

  Future<void> _loadSavedLanguages() async {
    final lang = context.read<LanguageService>();
    final saved = await lang.getLastUsedLanguages();
    if (saved != null && mounted) {
      setState(() {
        _sourceLanguage = saved['source'] ?? 'auto';
        _targetLanguage = saved['target'] ?? 'ar';
      });
    }
  }

  Future<void> _browseFile() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'doc', 'docx', 'rtf'],
      );
      if (result != null) {
        setState(() {
          _selectedFilePath = result.files.single.path;
          _selectedFileName = result.files.single.name;
          _urlController.text = _selectedFilePath ?? '';
        });
      }
    } catch (e) {
      _showMessage('خطأ في اختيار الملف: $e');
    }
  }

  Future<void> _searchUrl() async {
    _showMessage('💡 الصق رابط المستند هنا يدوياً');
  }

  Future<void> _startTranslation() async {
    if (_urlController.text.isEmpty && _selectedFilePath == null) {
      _showMessage('الرجاء اختيار ملف أو إدخال رابط أولاً');
      return;
    }

    setState(() {
      _isTranslating = true;
      _showOriginal = false;
    });

    // محاكاة عملية ترجمة
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _isTranslating = false;
      _translationController.text = '''
📄 المستند المترجم (معاينة)

هذا نص تجريبي يمثل المستند بعد الترجمة.

🔖 التوقيع:
"ترجم هذا المستند بواسطة ميرور سكربيون"

💡 ملاحظة: النسخة المجانية تترجم حتى 5 صفحات فقط.
النسخة المدفوعة تترجم بلا حدود وتحفظ المستندات.

📊 عدد الصفحات: $_currentPage / $_maxFreePages
''';
    });

    // حفظ اللغات
    final lang = context.read<LanguageService>();
    await lang.saveLastUsedLanguages(
      source: _sourceLanguage,
      target: _targetLanguage,
    );

    _showMessage('✅ تمت الترجمة بنجاح');
  }

  Future<void> _shareDocument() async {
    if (_translationController.text.isEmpty) return;
    await Share.share(
      '${_translationController.text}\n\n— ترجم هذا المستند بواسطة ميرور سكربيون —',
      subject: 'مستند مترجم - Mirror Scorpion',
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1B2838),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('📄 ترجمة مستندات', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.cyanAccent),
            onPressed: _translationController.text.isEmpty ? null : _shareDocument,
            tooltip: 'مشاركة',
          ),
        ],
      ),
      body: Column(
        children: [
          // ── زر العدسة (للدخول للـ Lens) ──
          Container(
            margin: const EdgeInsets.all(12),
            child: Material(
              color: Colors.purpleAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () => Navigator.pushNamed(context, '/lens'),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: const Row(
                    children: [
                      Icon(Icons.camera_alt, color: Colors.purpleAccent, size: 28),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'العدسة - ترجمة فورية',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'استخدم الكاميرا لترجمة النصوص فوراً',
                              style: TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.purpleAccent, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── حقل الرابط + زر البحث ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _urlController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'الصق رابط المستند أو اختر ملف...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1B2838),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(Icons.link, color: Colors.white54),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.cyanAccent),
                  onPressed: _searchUrl,
                  tooltip: 'بحث',
                ),
              ],
            ),
          ),
          // ── زر "فتح من المستعرض" ──
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _browseFile,
                icon: const Icon(Icons.folder_open, color: Colors.white),
                label: const Text('فتح من المستعرض', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
          if (_selectedFileName != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: Colors.cyanAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFileName!,
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          // ── زر الترجمة الكبير (في الثلث الأخير) ──
          if (_isTranslating)
            const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            )
          else
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _startTranslation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text(
                    '🔄 ترجم',
                    style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          // ── عرض المستند المترجم (إذا تم) ──
          if (_translationController.text.isNotEmpty)
            Expanded(
              child: GestureDetector(
                onLongPressStart: (_) => setState(() => _showOriginal = true),
                onLongPressEnd: (_) => setState(() => _showOriginal = false),
                child: Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2838),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.cyanAccent),
                  ),
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Text(
                          _showOriginal
                              ? '📄 المستند الأصلي:\n\n[النص الأصلي للمستند]\n\n(اضغط مطولاً للترجمة)'
                              : _translationController.text,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      // ── التوقيع المائي ──
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Center(
                            child: Transform.rotate(
                              angle: 130 * 3.14159 / 180,
                              child: Opacity(
                                opacity: 0.12,
                                child: const Text(
                                  'ترجم هذا المستند بواسطة ميرور سكربيون',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
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
        ],
      ),
    );
  }
}
