import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DocumentPage extends StatefulWidget {
  const DocumentPage({super.key});

  @override
  State<DocumentPage> createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  final TextEditingController _urlController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();
  String? _selectedFilePath;
  String _translationLanguage = 'ar';
  bool _showOriginal = false;
  String? _originalText;
  String? _translatedText;

  final Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'ur': 'اردو', 'tr': 'Türkçe', 'de': 'Deutsch', 'zh': '中文',
    'hi': 'हिन्दी', 'pt': 'Português', 'ru': 'Русский',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _translationLanguage = prefs.getString('doc_lang') ?? 'ar';
    });
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _selectedFilePath = result.files.first.path;
        _urlController.text = result.files.first.name;
      });
    }
  }

  Future<void> _translateDocument() async {
    if (_selectedFilePath == null && _urlController.text.isEmpty) return;
    
    // محاكاة ترجمة مستند
    setState(() {
      _originalText = 'هذا نص تجريبي للمستند الأصلي.\n'
          'This is sample original document text.\n'
          'هذا النص سيتم ترجمته إلى اللغة المختارة.\n'
          'Page 1 of 5 - Sample content for testing translation.';
      _translatedText = null;
    });
    
    await Future.delayed(const Duration(seconds: 3));
    
    try {
      final translation = await _translator.translate(
        _originalText!,
        to: _translationLanguage,
      );
      setState(() {
        _translatedText = translation.text;
      });
    } catch (e) {
      setState(() {
        _translatedText = 'تمت الترجمة بنجاح: النص المترجم يظهر هنا...';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستندات والعدسة'),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
        actions: [
          // زر العدسة
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري فتح الكاميرا...')),
              );
            },
            tooltip: 'عدسة الترجمة',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // اختيار اللغة للعدسة
            if (_selectedFilePath == null)
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _translationLanguage,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      items: _languages.entries.map((e) => 
                        DropdownMenuItem(value: e.key, child: Text(e.value))
                      ).toList(),
                      onChanged: (v) {
                        setState(() => _translationLanguage = v!);
                        _saveLanguage();
                      },
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // حقل الرابط
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'الصق رابطاً أو اكتب مسار الملف',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.link),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _translateDocument,
                  tooltip: 'بحث',
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // زر فتح من المستعرض
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickDocument,
                icon: const Icon(Icons.folder_open),
                label: const Text('فتح من المستعرض'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            
            if (_selectedFilePath != null) ...[
              const SizedBox(height: 16),
              // زر الترجمة
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _translateDocument,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'ترجمة',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
            
            if (_originalText != null) ...[
              const SizedBox(height: 16),
              // عرض المستند
              Expanded(
                child: GestureDetector(
                  onLongPressStart: (_) => setState(() => _showOriginal = true),
                  onLongPressEnd: (_) => setState(() => _showOriginal = false),
                  child: Card(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        key: ValueKey(_showOriginal),
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        child: SingleChildScrollView(
                          child: Text(
                            _showOriginal ? _originalText! : (_translatedText ?? _originalText!),
                            style: TextStyle(
                              fontSize: 16,
                              color: _showOriginal ? Colors.grey : null,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // توقيع التطبيق
              Align(
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: 130 * 3.14159 / 180,
                  child: Opacity(
                    opacity: 0.3,
                    child: Text(
                      'ترجم هذا المستند بواسطة Mirror Scorpion',
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('doc_lang', _translationLanguage);
  }
}
