import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
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
      body: _isLensMode ? _buildLensView() : _buildDocumentView(langCodes),
    );
  }

  Widget _buildLensView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/400x600/0D1B2A/FFFFFF?text=📷+Camera+Preview'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // زر اللغة
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: DropdownButton<String>(
                      value: 'ar',
                      dropdownColor: Colors.black87,
                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 13),
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'ar', child: Text('العربية', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'en', child: Text('English', style: TextStyle(color: Colors.white))),
                        DropdownMenuItem(value: 'fr', child: Text('Français', style: TextStyle(color: Colors.white))),
                      ],
                      onChanged: (_) {},
                    ),
                  ),
                ),
                // زر التقاط
                Positioned(
                  bottom: 16,
                  child: Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orangeAccent, width: 3),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera_alt, color: Colors.orangeAccent, size: 28),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('📷 تم التقاط الصورة - جارٍ التعرف على النص...')),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // نتيجة OCR
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1B2838),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const Text('النص المستخرج:', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'اضغط على زر الكاميرا للبدء\nسيتم التعرف على النص تلقائياً',
                  style: TextStyle(color: Colors.white54, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentView(List<String> langCodes) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // مربع إدخال الرابط
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2838),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: TextField(
                    controller: _urlController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      hintText: 'رابط المستند أو المسار...',
                      hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                      prefixIcon: Icon(Icons.link, color: Colors.orangeAccent, size: 20),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // زر البحث
              Container(
                decoration: BoxDecoration(
                  color: Colors.orangeAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.search, color: Colors.orangeAccent),
                  onPressed: () {
                    if (_urlController.text.isNotEmpty) {
                      setState(() => _isProcessing = true);
                      Future.delayed(const Duration(seconds: 2), () {
                        if (mounted) {
                          setState(() {
                            _isProcessing = false;
                            _translatedText = 'مستند تم تحميله من: ${_urlController.text}\n(محاكاة - النسخة الكاملة تتطلب API)';
                          });
                        }
                      });
                    }
                  },
                  tooltip: 'بحث',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // زر فتح من المستعرض
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.any,
                    allowMultiple: false,
                  );
                  if (result != null && result.files.single.path != null) {
                    setState(() {
                      _selectedFilePath = result.files.single.path!;
                      _selectedFileName = result.files.single.name;
                      _urlController.text = _selectedFileName;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('✅ تم اختيار: $_selectedFileName')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ $e')),
                  );
                }
              },
              icon: const Icon(Icons.folder_open),
              label: const Text('فتح من المستعرض'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orangeAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          if (_selectedFilePath.isNotEmpty || _translatedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            // زر الترجمة الكبير
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : () {
                  setState(() => _isProcessing = true);
                  Future.delayed(const Duration(seconds: 3), () {
                    if (mounted) {
                      setState(() {
                        _isProcessing = false;
                        _translatedText = '📄 النسخة المترجمة من المستند\n\n'
                            'النص الأصلي: $_selectedFileName\n'
                            'تمت الترجمة بنجاح ✓\n\n'
                            '(النسخة الكاملة تتطلب تفعيل API الترجمة)';
                      });
                      _showDocumentFullScreen();
                    }
                  });
                },
                icon: _isProcessing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.translate, size: 28),
                label: Text(_isProcessing ? 'جارٍ الترجمة...' : '🌐 ترجمة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDocumentFullScreen() {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => Scaffold(
        backgroundColor: const Color(0xFF0D1B2A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1B2838),
          iconTheme: const IconThemeData(color: Colors.orangeAccent),
          title: const Text('المستند', style: TextStyle(color: Colors.white)),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.orangeAccent),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: 
                  '$_translatedText\n\n— — — — — — — — — —\n🌐 تُرجم بواسطة ميرور سكربيون 🦂'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ تم النسخ مع التوقيع للمشاركة')),
                );
              },
              tooltip: 'مشاركة',
            ),
          ],
        ),
        body: GestureDetector(
          onLongPressStart: (_) => setState(() => _showOriginal = true),
          onLongPressEnd: (_) => setState(() => _showOriginal = false),
          child: Stack(
            children: [
              // المستند الأصلي (نص عربي وهمي)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Text(
                      'المستند الأصلي:\n\n'
                      'هذا هو النص الأصلي للمستند قبل الترجمة.\n'
                      'يظهر عند الضغط المطول على الشاشة.\n\n'
                      '﷽\n'
                      'بسم الله الرحمن الرحيم\n\n'
                      'الحمد لله رب العالمين، والصلاة والسلام على أشرف المرسلين.\n'
                      'أما بعد: فهذا مستند تجريبي للترجمة.',
                      style: TextStyle(
                        color: _showOriginal ? Colors.white : Colors.transparent,
                        fontSize: 16,
                        height: 1.8,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ),
              // المستند المترجم (يغطي الأصلي من اليمين)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                left: _showOriginal ? MediaQuery.of(context).size.width : 0,
                right: 0,
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2838),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 20,
                        offset: const Offset(-5, 0),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Stack(
                      children: [
                        // النص المترجم
                        SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('📄 المستند المترجم',
                                style: TextStyle(color: Colors.amberAccent, fontSize: 14, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text(
                                _translatedText,
                                style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.8),
                              ),
                              const SizedBox(height: 16),
                              // التوقيع الشفاف
                              Transform.rotate(
                                angle: 130 * 3.14159 / 180,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.2)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'تُرجم بواسطة ميرور سكربيون',
                                    style: TextStyle(
                                      color: Colors.cyanAccent.withOpacity(0.15),
                                      fontSize: 11,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // إشعار الضغط المطول
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('👆 اضغط مطولاً لرؤية النص الأصلي',
                                style: TextStyle(color: Colors.white38, fontSize: 11)),
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
    ));
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
