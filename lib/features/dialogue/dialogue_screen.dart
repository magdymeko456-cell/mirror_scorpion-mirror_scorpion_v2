import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});
  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  String _sourceLang = 'en';
  String _targetLang = 'ar';
  bool _isListening = false;

  final List<String> _languages = [
    'ar','en','fr','es','de','it','pt','ru','zh','ja','ko',
    'tr','ur','fa','hi','bn','id','ms'
  ];

  String _getLangName(String code) {
    final names = {
      'ar': 'العربية', 'en': 'English', 'fr': 'Français',
      'es': 'Español', 'de': 'Deutsch', 'it': 'Italiano',
      'pt': 'Português', 'ru': 'Русский', 'zh': '中文',
      'ja': '日本語', 'ko': '한국어', 'tr': 'Türkçe',
      'ur': 'اردو', 'fa': 'فارسی', 'hi': 'हिन्दी',
      'bn': 'বাংলা', 'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu',
    };
    return names[code] ?? code;
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
    });
  }

  void _startListening() {
    setState(() => _isListening = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _sourceController.text = 'Hello, how are you?';
          _isListening = false;
          _translateDialog();
        });
      }
    });
  }

  void _translateDialog() {
    if (_sourceController.text.trim().isEmpty) return;
    _targetController.text = '[${_getLangName(_targetLang)}]: ${_sourceController.text}';
  }

  void _speakTranslation() {}

  void _pickAudioFile() {}

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🦂 حوار مترجم')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // المحرر العلوي - المصدر
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _sourceController,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'النص الأصلي...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // أزرار التحكم بين المحررين
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // ✅ زر اختيار لغة المصدر (على اليمين)
                    Expanded(
                      child: _buildLangSelector(_sourceLang, (v) {
                        setState(() => _sourceLang = v!);
                      }),
                    ),
                    const SizedBox(width: 8),
                    // ✅ زر التبديل
                    GestureDetector(
                      onTap: _swapLanguages,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.swap_horiz, color: Colors.amber, size: 28),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ✅ زر المايك
                    GestureDetector(
                      onTapDown: (_) => _startListening(),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: _isListening ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _isListening ? Colors.red : Colors.white38,
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          _isListening ? Icons.mic : Icons.mic_none,
                          color: _isListening ? Colors.red : Colors.white70,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // ✅ زر اختيار لغة الهدف (على اليسار)
                    Expanded(
                      child: _buildLangSelector(_targetLang, (v) {
                        setState(() => _targetLang = v!);
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // المحرر السفلي - الترجمة
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _targetController,
                              style: const TextStyle(color: Colors.green.shade300, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'الترجمة...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              expands: true,
                              textAlign: TextAlign.right,
                              readOnly: true,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: Colors.green),
                                onPressed: _speakTranslation,
                              ),
                              IconButton(
                                icon: const Icon(Icons.attach_file, color: Colors.orange),
                                onPressed: _pickAudioFile,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangSelector(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1B2838),
          style: const TextStyle(color: Colors.white, fontSize: 12),
          isExpanded: true,
          items: _languages.map((code) {
            return DropdownMenuItem(
              value: code,
              child: Text(_getLangName(code), style: const TextStyle(fontSize: 11)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
