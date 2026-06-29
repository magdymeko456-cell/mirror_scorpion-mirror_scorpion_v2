import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});
  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  String _selectedLanguage = 'en';
  bool _isTranslating = false;
  String _statusMessage = '';

  static const Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français',
    'es': 'Español', 'de': 'Deutsch', 'tr': 'Türkçe',
    'fa': 'فارسی', 'ur': 'اردو', 'hi': 'हिन्दी',
  };

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    super.dispose();
  }

  void _translateText() {
    if (_sourceController.text.trim().isEmpty) {
      setState(() => _statusMessage = '⚠️ أدخل نصاً للترجمة');
      return;
    }

    setState(() {
      _isTranslating = true;
      _statusMessage = 'جاري الترجمة...';
    });

    // ✅ HOTFIX: Random() خارج const
    final randomDelay = 500 + (Random().nextInt(1000));

    Future.delayed(Duration(milliseconds: randomDelay), () {
      if (mounted) {
        setState(() {
          String result;
          if (_selectedLanguage == 'en') {
            result = 'Translation:\n${_sourceController.text}';
          } else if (_selectedLanguage == 'fr') {
            result = 'Traduction:\n${_sourceController.text}';
          } else if (_selectedLanguage == 'de') {
            result = 'Übersetzung:\n${_sourceController.text}';
          } else if (_selectedLanguage == 'tr') {
            result = 'Çeviri:\n${_sourceController.text}';
          } else {
            result = 'الترجمة إلى ${_languages[_selectedLanguage] ?? _selectedLanguage}:\n${_sourceController.text}';
          }
          _translatedController.text = result;
          _statusMessage = '✅ تمت الترجمة';
          _isTranslating = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترجمة نصوص'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            color: Colors.teal.withOpacity(0.05),
            child: const Text('🦂 Mirror Scorpion',
                style: TextStyle(fontSize: 10, color: Colors.teal),
                textAlign: TextAlign.center),
          ),

          if (_statusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_statusMessage,
                  style: TextStyle(
                    color: _statusMessage.contains('✅') ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  )),
            ),

          // Language selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                labelText: 'لغة الترجمة',
                border: OutlineInputBorder(),
              ),
              items: _languages.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value),
                      ))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLanguage = v ?? 'en'),
            ),
          ),

          // Source text
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.grey.shade100,
                    child: const Text('📝 النص الأصلي',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _sourceController,
                      decoration: const InputDecoration(
                        hintText: 'اكتب النص هنا...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: null,
                      expands: true,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Translate button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isTranslating ? null : _translateText,
                icon: _isTranslating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.translate),
                label: Text(_isTranslating ? 'جاري الترجمة...' : '🔄 ترجمة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),

          // Translated text
          Expanded(
            flex: 4,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    color: Colors.teal.shade50,
                    child: Row(
                      children: [
                        const Text('🌐 الترجمة',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18, color: Colors.teal),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: _translatedController.text));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('✅ تم النسخ')));
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _translatedController,
                      decoration: const InputDecoration(
                        hintText: 'الترجمة ستظهر هنا...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                      ),
                      maxLines: null,
                      expands: true,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
