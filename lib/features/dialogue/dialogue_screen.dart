import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import '../../services/translation_service.dart';
import '../../services/tts_service.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});
  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final TranslationService _translationService = TranslationService();
  final TTSService _ttsService = TTSService();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _sourceLang = 'en';
  String _targetLang = 'ar';
  final List<String> _languages = ['ar','en','fr','es','de','it','pt','ru','zh','ja','ko','tr','ur','fa','hi','bn','id','ms'];
  final Map<String, String> _names = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'de': 'Deutsch', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
    'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'tr': 'Türkçe',
    'ur': 'اردو', 'fa': 'فارسی', 'hi': 'हिन्दी', 'bn': 'বাংলা',
    'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu',
  };
  String _getLangName(String code) => _names[code] ?? code;

  void _swapLanguages() {
    setState(() {
      final t = _sourceLang; _sourceLang = _targetLang; _targetLang = t;
      final tt = _sourceController.text;
      _sourceController.text = _targetController.text;
      _targetController.text = tt;
    });
  }

  Future<void> _startListening() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('❌ يرجى منح إذن الميكروفون')));
      return;
    }
    final available = await _speech.initialize();
    if (!available) return;
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (r) => _sourceController.text = r.recognizedWords,
      listenFor: const Duration(seconds: 20),
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    if (_sourceController.text.trim().isNotEmpty) _translateDialog();
  }

  Future<void> _translateDialog() async {
    if (_sourceController.text.trim().isEmpty) return;
    final r = await _translationService.translate(text: _sourceController.text, targetLang: _targetLang, sourceLang: _sourceLang);
    if (mounted) setState(() => _targetController.text = r['translated'] ?? '');
  }

  void _speakTranslation() {
    if (_targetController.text.isNotEmpty) _ttsService.speak(_targetController.text, language: _targetLang);
  }

  @override
  void initState() { super.initState(); _speech = stt.SpeechToText(); }

  @override
  void dispose() { _speech.stop(); _sourceController.dispose(); _targetController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('🦂 حوار مترجم')),
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)])),
      child: SafeArea(child: Column(children: [
        const SizedBox(height: 16),
        Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withValues(alpha: 0.3))),
          child: Padding(padding: const EdgeInsets.all(12), child: TextField(
            controller: _sourceController, style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(hintText: 'النص الأصلي...', hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)), border: InputBorder.none),
            maxLines: null, expands: true, textAlign: TextAlign.right
          ))
        ))),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          Expanded(child: _buildLangSelector(_sourceLang, (v) => setState(() => _sourceLang = v!))),
          const SizedBox(width: 8),
          GestureDetector(onTap: _swapLanguages, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.amber.shade700.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.swap_horiz, color: Colors.amber, size: 28))),
          const SizedBox(width: 8),
          GestureDetector(
            onTapDown: (_) => _startListening(), onTapUp: (_) => _stopListening(),
            child: Container(width: 56, height: 56,
              decoration: BoxDecoration(color: _isListening ? Colors.red.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.08), shape: BoxShape.circle, border: Border.all(color: _isListening ? Colors.red : Colors.white38, width: 2)),
              child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.white70, size: 28))
          ),
          const SizedBox(width: 8),
          Expanded(child: _buildLangSelector(_targetLang, (v) => setState(() => _targetLang = v!))),
        ])),
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: ElevatedButton.icon(
          onPressed: _translateDialog, icon: const Icon(Icons.translate), label: const Text('ترجمة المحادثة'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12))
        )),
        Expanded(flex: 3, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Container(
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.green.withValues(alpha: 0.3))),
          child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
            Expanded(child: TextField(
              controller: _targetController,
              style: TextStyle(color: Colors.green.shade300, fontSize: 16),
              decoration: InputDecoration(hintText: 'الترجمة...', hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)), border: InputBorder.none),
              maxLines: null, expands: true, textAlign: TextAlign.right, readOnly: true
            )),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              IconButton(icon: const Icon(Icons.volume_up, color: Colors.green), onPressed: _speakTranslation),
            ]),
          ]))
        ))),
        const SizedBox(height: 16),
      ]))
    )
  );

  Widget _buildLangSelector(String value, ValueChanged<String?> onChanged) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white24)),
    child: DropdownButtonHideUnderline(child: DropdownButton<String>(
      value: value, dropdownColor: const Color(0xFF1B2838), style: const TextStyle(color: Colors.white, fontSize: 12),
      isExpanded: true,
      items: _languages.map((code) => DropdownMenuItem(value: code, child: Text(_getLangName(code), style: const TextStyle(fontSize: 11)))).toList(),
      onChanged: onChanged,
    ))
  );
}
