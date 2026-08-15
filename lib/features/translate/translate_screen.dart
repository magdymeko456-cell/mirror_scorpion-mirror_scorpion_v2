import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../services/translation_service.dart';
import '../../services/tts_service.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TranslationService _translationService = TranslationService();
  final TTSService _ttsService = TTSService();
  late stt.SpeechToText _speech;

  bool _isListening = false;
  bool _isTranslating = false;
  String _sourceLang = 'auto';
  String _targetLang = 'ar';
  String _detectedLang = '';

  List<String> _languages = ['auto','ar','en'];
  bool _languagesLoaded = false;

  static const Map<String, String> _langNames = {
    'auto': 'الكشف التلقائي', 'ar': 'العربية', 'en': 'English',
    'fr': 'Français', 'es': 'Español', 'de': 'Deutsch', 'it': 'Italiano',
    'pt': 'Português', 'ru': 'Русский', 'zh': '中文', 'ja': '日本語',
    'ko': '한국어', 'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی',
    'hi': 'हिन्दी', 'bn': 'বাংলা', 'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu',
    'nl': 'Nederlands', 'sv': 'Svenska', 'no': 'Norsk', 'da': 'Dansk',
    'fi': 'Suomi', 'pl': 'Polski', 'cs': 'Čeština', 'hu': 'Magyar',
    'ro': 'Română', 'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย',
    'vi': 'Tiếng Việt', 'sw': 'Kiswahili',
  };

  String _getLangName(String code) => _langNames[code] ?? code.toUpperCase();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadLanguages();
  }

  Future<void> _loadLanguages() async {
    final langs = await _translationService.getSupportedLanguages();
    if (langs.isNotEmpty && mounted) {
      setState(() {
        _languages = ['auto', ...langs.where((l) => l.length == 2 && l != 'auto').take(50)];
        _languagesLoaded = true;
      });
    }
  }

  Future<void> _startListening() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ يرجى منح إذن الميكروفون')),
      );
      return;
    }

    final available = await _speech.initialize();
    if (!available) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ التعرف على الكلام غير متاح على هذا الجهاز')),
      );
      return;
    }

    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (r) => _sourceController.text = r.recognizedWords,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    if (_sourceController.text.trim().isNotEmpty) _translate();
  }

  Future<void> _translate() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);

    final result = await _translationService.translate(
      text: _sourceController.text,
      targetLang: _targetLang,
      sourceLang: _sourceLang,
    );

    if (mounted) {
      setState(() {
        _targetController.text = result['translated'] ?? '';
        _detectedLang = result['detected'] ?? '';
        _isTranslating = false;
      });
    }
  }

  void _speakTarget() {
    if (_targetController.text.isNotEmpty) {
      _ttsService.speak(_targetController.text, language: _targetLang);
    }
  }

  void _copyTranslation() {
    Clipboard.setData(ClipboardData(text: _targetController.text));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📋 تم نسخ الترجمة')),
    );
  }

  void _clearAll() {
    _sourceController.clear();
    _targetController.clear();
    setState(() => _detectedLang = '');
  }

  @override
  void dispose() {
    _speech.stop();
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
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
        child: SafeArea(child: Column(children: [
          // ✅ شريط اللغات
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _buildLangDropdown(_sourceLang, (v) => setState(() => _sourceLang = v!)),
              const SizedBox(width: 8),
              if (_detectedLang.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('🔄 ${_getLangName(_detectedLang)}',
                    style: const TextStyle(color: Colors.green, fontSize: 10)),
                ),
            ]),
          ),

          // ✅ المحرر العلوي
          Expanded(flex: 3, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
                Expanded(child: TextField(
                  controller: _sourceController,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'اكتب أو استخدم المايك...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    border: InputBorder.none,
                  ),
                  maxLines: null, expands: true, textAlign: TextAlign.right,
                  onChanged: (v) { if (v.isEmpty) _clearAll(); },
                )),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  // مايك حقيقي
                  GestureDetector(
                    onTapDown: (_) => _startListening(),
                    onTapUp: (_) => _stopListening(),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: _isListening ? Colors.red.withValues(alpha: 0.2) : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: _isListening ? Colors.red : Colors.white38, width: 2),
                      ),
                      child: Icon(_isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : Colors.white70),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white38),
                    onPressed: _clearAll,
                  ),
                ]),
              ])),
            ),
          )),

          // ✅ زر الترجمة
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ElevatedButton.icon(
              onPressed: _translate,
              icon: _isTranslating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.translate),
              label: Text(_isTranslating ? 'جاري الترجمة...' : 'ترجمة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
            ),
          ),

          // ✅ المحرر السفلي (الترجمة)
          Expanded(flex: 3, child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
              ),
              child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
                Expanded(child: TextField(
                  controller: _targetController,
                  style: TextStyle(color: Colors.green.shade300, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'الترجمة...',
                    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                    border: InputBorder.none,
                  ),
                  maxLines: null, expands: true, textAlign: TextAlign.right,
                  readOnly: true,
                )),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Colors.green),
                    onPressed: _speakTarget,
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.white70),
                    onPressed: _copyTranslation,
                  ),
                ]),
              ])),
            ),
          )),
        ])),
      ),
    );
  }

  Widget _buildLangDropdown(String value, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: const Color(0xFF1B2838),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.language, color: Colors.white70, size: 18),
          items: _languages.map((code) => DropdownMenuItem(
            value: code,
            child: Text(_getLangName(code), style: const TextStyle(fontSize: 12)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
