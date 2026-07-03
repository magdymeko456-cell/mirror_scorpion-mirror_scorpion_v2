import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import '../../services/translation_service.dart';
import '../../core/widgets/shared_widgets.dart';

class DialogueTranslationScreen extends StatefulWidget {
  const DialogueTranslationScreen({super.key});
  @override
  State<DialogueTranslationScreen> createState() => _DialogueTranslationScreenState();
}

class _DialogueTranslationScreenState extends State<DialogueTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  stt.SpeechToText? _speech;
  bool _isListening = false, _isTranslating = false, _isProcessingAudio = false;
  String _langFrom = 'ar', _langTo = 'en';

  @override
  void initState() { super.initState(); _initSpeech(); _loadSavedLanguages(); }

  void _initSpeech() async { _speech = stt.SpeechToText(); await _speech!.initialize(); }

  void _loadSavedLanguages() {
    final ls = context.read<LanguageService>();
    setState(() { _langFrom = ls.getLanguageForScreen('dialogue_from'); if (_langFrom == 'auto') _langFrom = 'ar';
      _langTo = ls.getLanguageForScreen('dialogue_to'); if (_langTo == 'auto') _langTo = 'en'; });
  }
  void _saveLanguages() {
    final ls = context.read<LanguageService>();
    ls.saveLanguageForScreen('dialogue_from', _langFrom);
    ls.saveLanguageForScreen('dialogue_to', _langTo);
  }

  void _swapLanguages() {
    setState(() { final t = _langFrom; _langFrom = _langTo; _langTo = t; }); _saveLanguages();
    if (_sourceController.text.isNotEmpty) _performTranslation(_sourceController.text);
  }

  void _startListening() async {
    if (_speech == null || !_speech!.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('التعرف على الصوت غير متاح'))); return;
    }
    if (_isListening) { _speech!.stop(); setState(() => _isListening = false); _sourceController.clear(); _translatedController.clear(); return; }
    _sourceController.clear(); _translatedController.clear(); setState(() => _isListening = true);
    _speech!.listen(onResult: (r) { setState(() { _sourceController.text = r.recognizedWords; }); },
      localeId: _langFrom == 'ar' ? 'ar' : _langFrom, listenMode: stt.ListenMode.confirmation);
  }

  void _performTranslation(String text) async {
    if (text.trim().isEmpty) return; setState(() => _isTranslating = true);
    try {
      final ts = context.read<TranslationService>();
      final r = await ts.translate(text, _langFrom, _langTo);
      if (mounted) setState(() { _translatedController.text = r; _isTranslating = false; });
    } catch (e) { if (mounted) { setState(() => _isTranslating = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشلت الترجمة: $e'))); } }
  }

  void _speakTranslation() { context.read<TTSService>().speak(_translatedController.text, language: _langTo); }

  Future<void> _pickAudioFile() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3','wav','m4a','ogg','aac']);
    if (r != null && r.files.single.path != null) {
      setState(() => _isProcessingAudio = true);
      try { await Future.delayed(const Duration(seconds: 2));
        if (mounted) { setState(() { _sourceController.text = "ملف: ${r.files.single.name}"; _isProcessingAudio = false; }); _performTranslation(_sourceController.text); }
      } catch (e) { if (mounted) { setState(() => _isProcessingAudio = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e'))); } }
    }
  }

  @override
  void dispose() { _sourceController.dispose(); _translatedController.dispose(); _speech?.stop(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ls = context.watch<LanguageService>();
    final codes = ls.getAvailableLanguages();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: const Text('حوار مترجم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        // شريط اللغات: أيمن = _langFrom (للمحرر العلوي)
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))),
          child: Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(value: codes.contains(_langFrom) ? _langFrom : 'ar',
                dropdownColor: const Color(0xFF0D1B2A), style: const TextStyle(color: Colors.pinkAccent, fontSize: 12),
                underline: const SizedBox(), isExpanded: true,
                items: codes.map((c) => DropdownMenuItem(value: c, child: Text(ls.getLanguageName(c), style: const TextStyle(color: Colors.white, fontSize: 12)))).toList(),
                onChanged: (v) { if (v != null) { setState(() => _langFrom = v); _saveLanguages(); } })),
            ),
            IconButton(icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.swap_horiz, color: Colors.pinkAccent, size: 22)), onPressed: _swapLanguages, tooltip: 'تبديل'),
            Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(value: codes.contains(_langTo) ? _langTo : 'en',
                dropdownColor: const Color(0xFF0D1B2A), style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                underline: const SizedBox(), isExpanded: true,
                items: codes.map((c) => DropdownMenuItem(value: c, child: Text(ls.getLanguageName(c), style: const TextStyle(color: Colors.white, fontSize: 12)))).toList(),
                onChanged: (v) { if (v != null) { setState(() => _langTo = v); _saveLanguages(); } })),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // المحرر العلوي - لغة المصدر (_langFrom)
        Expanded(flex: 3, child: Container(
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal:16, vertical:6),
              decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Text('النص الأصلي (${ls.getLanguageName(_langFrom)})', style: TextStyle(color: Colors.pinkAccent.withOpacity(0.8), fontSize: 11))),
            Expanded(child: TextField(controller: _sourceController, maxLines: null, expands: true,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
              decoration: InputDecoration(border: InputBorder.none, contentPadding: const EdgeInsets.all(16),
                hintText: 'سيظهر هنا ما يلتقطه المايك...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.2))))),
          ]),
        )),
        const SizedBox(height: 8),
        Center(child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_downward, color: Colors.amberAccent, size: 18))),
        const SizedBox(height: 8),
        // المحرر السفلي - لغة الهدف (_langTo)
        Expanded(flex: 3, child: Container(
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amberAccent.withOpacity(0.3))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal:16, vertical:6),
              decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Text('الترجمة (${ls.getLanguageName(_langTo)})', style: TextStyle(color: Colors.amberAccent.withOpacity(0.8), fontSize: 11))),
            Expanded(child: TextField(controller: _translatedController, maxLines: null, expands: true,
              style: const TextStyle(color: Colors.amberAccent, fontSize: 15, height: 1.5),
              decoration: InputDecoration(border: InputBorder.none, contentPadding: const EdgeInsets.all(16),
                hintText: 'الترجمة ستظهر هنا...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.2))), readOnly: true)),
            if (_translatedController.text.isNotEmpty)
              Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal:8, vertical:4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(icon: const Icon(Icons.volume_up, color: Colors.greenAccent, size: 24), onPressed: _speakTranslation, tooltip: 'نطق الترجمة'),
                ])),
          ]),
        )),
        const SizedBox(height: 12),
        // الأزرار السفلية
        Container(padding: const EdgeInsets.symmetric(horizontal:16, vertical:8),
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: _isProcessingAudio
              ? const SizedBox(width:24,height:24,child:CircularProgressIndicator(strokeWidth:2,color:Colors.orangeAccent))
              : const Icon(Icons.push_pin, color: Colors.orangeAccent, size:26),
              onPressed: _isProcessingAudio ? null : _pickAudioFile, tooltip: 'رفع ملف صوتي'),
            const SizedBox(width: 16),
            GestureDetector(onTap: _startListening,
              child: AnimatedContainer(duration: const Duration(milliseconds:200), width:62, height:62,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: _isListening ? Colors.red.withOpacity(0.2) : Colors.pinkAccent.withOpacity(0.1),
                  border: Border.all(color: _isListening ? Colors.red : Colors.pinkAccent, width:2)),
                child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.pinkAccent, size:28))),
          ]),
        ),
      ])),
    );
  }
}
