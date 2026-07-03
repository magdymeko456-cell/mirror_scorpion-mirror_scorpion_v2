import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  String _sourceLang = 'auto';
  String _targetLang = 'ar';
  bool _isListening = false;
  bool _isTranslating = false;

  final List<String> _languages = [
    'auto','ar','en','fr','es','de','it','pt','ru','zh','ja','ko',
    'tr','ur','fa','hi','bn','id','ms','nl','sv','no','da','fi',
    'pl','cs','hu','ro','el','he','th','vi','sw','tl','mr','ta',
    'te','gu','kn','ml','pa','ne','si','km','lo','my','ka','hy',
    'az','uz','kk','mn','bo','dz','ps','sd','ckb','am','om','ti',
    'ha','ig','yo','zu','xh','af','st','tn','ts','ss','ve','nr',
    'rw','rn','mg','ny','sn','so','ja','jv','su','ceb','haw','sm',
    'mi','gil','tet','fj','to','ty','chr','iku','iu','kl','se',
    'smj','sms','sma','smn','sms','smj','sje','fit','rmy','rom',
    'lmo','vec','sc','co','oc','an','ast','mwl','gl','ext','arg'
  ];

  String _getLangName(String code) {
    final names = {
      'auto': 'الكشف التلقائي', 'ar': 'العربية', 'en': 'English',
      'fr': 'Français', 'es': 'Español', 'de': 'Deutsch',
      'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
      'zh': '中文', 'ja': '日本語', 'ko': '한국어',
      'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی',
      'hi': 'हिन्दी', 'bn': 'বাংলা', 'id': 'Bahasa Indonesia',
      'ms': 'Bahasa Melayu',
    };
    return names[code] ?? code;
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _startListening() {
    setState(() => _isListening = true);
    // سيتم ربطها بمكتبة speech_to_text لاحقاً
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _sourceController.text = 'نص تجريبي للتعرف على الكلام...';
          _isListening = false;
        });
      }
    });
  }

  void _translate() {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    // سيتم ربطها بمكتبة الترجمة لاحقاً
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _targetController.text = '[ترجمة: ${_sourceController.text}]';
          _isTranslating = false;
        });
      }
    });
  }

  void _speakTarget() {
    // سيتم ربطها بـ TTS
  }

  void _shareAudio() {
    // مشاركة ملف الصوت
  }

  void _pickAudioFile() {
    // رفع ملف صوتي للترجمة
  }

  void _copyTranslation() {
    Clipboard.setData(ClipboardData(text: _targetController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الترجمة')),
    );
  }

  void _clearAll() {
    _sourceController.clear();
    _targetController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🦂 ترجمة نصية')),
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
              // ✅ زر اختيار اللغة في منتصف الشاشة العلوي
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLangDropdown(_sourceLang, (v) {
                      setState(() => _sourceLang = v!);
                    }),
                  ],
                ),
              ),

              // ✅ المحرر العلوي لإدخال النص
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _sourceController,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'اكتب أو استخدم المايك...',
                                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                                border: InputBorder.none,
                              ),
                              maxLines: null,
                              expands: true,
                              textAlign: TextAlign.right,
                              onChanged: (v) {
                                if (v.isEmpty) _clearAll();
                              },
                            ),
                          ),
                          // ✅ الأزرار أسفل المحرر العلوي
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // مايك لالتقاط الكلام
                              GestureDetector(
                                onTapDown: (_) => _startListening(),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _isListening
                                        ? Colors.red.withOpacity(0.2)
                                        : Theme.of(context).primaryColor.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _isListening ? Colors.red : Colors.white38,
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    _isListening ? Icons.mic : Icons.mic_none,
                                    color: _isListening ? Colors.red : Colors.white70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ✅ زر الترجمة
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ElevatedButton.icon(
                  onPressed: _translate,
                  icon: _isTranslating
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.translate),
                  label: const Text('ترجمة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                ),
              ),

              // ✅ المحرر السفلي (الترجمة)
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _targetController,
                              style: TextStyle(color: Colors.green.shade300, fontSize: 16),
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
                          // ✅ أزرار أسفل الترجمة
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // 🎵 سبيكر لنطق الترجمة
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: Colors.green),
                                onPressed: _speakTarget,
                              ),
                              // 📤 مشاركة ملف الصوت
                              IconButton(
                                icon: const Icon(Icons.share, color: Colors.blue),
                                onPressed: _shareAudio,
                              ),
                              // 📎 رفع ملف صوتي
                              IconButton(
                                icon: const Icon(Icons.attach_file, color: Colors.orange),
                                onPressed: _pickAudioFile,
                              ),
                              // 📋 نسخ الترجمة
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.white70),
                                onPressed: _copyTranslation,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1B2838),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.language, color: Colors.white70, size: 18),
          items: _languages.map((code) {
            return DropdownMenuItem(
              value: code,
              child: Text(_getLangName(code), style: const TextStyle(fontSize: 12)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
