import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import '../../services/translation_service.dart';
import '../../core/widgets/shared_widgets.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});
  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _sourceLang = 'auto';
  String _targetLang = 'en';
  bool _isTranslating = false;
  bool _isProcessingAudio = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadSavedLanguages();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    await _speech!.initialize();
  }

  void _loadSavedLanguages() {
    final langService = context.read<LanguageService>();
    setState(() {
      _sourceLang = langService.getLanguageForScreen('text_translation_source');
      if (_sourceLang == 'auto') _sourceLang = 'auto';
      _targetLang = langService.getLanguageForScreen('text_translation_target');
      if (_targetLang == 'auto') _targetLang = 'en';
    });
  }

  void _saveLanguages() {
    final langService = context.read<LanguageService>();
    langService.saveLanguageForScreen('text_translation_source', _sourceLang);
    langService.saveLanguageForScreen('text_translation_target', _targetLang);
  }

  void _startListening() async {
    if (_speech == null || !_speech!.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('التعرف على الصوت غير متاح')),
      );
      return;
    }
    if (_isListening) {
      _speech!.stop();
      _sourceController.clear();
      _translatedController.clear();
      setState(() => _isListening = false);
      return;
    }
    _sourceController.clear();
    _translatedController.clear();
    setState(() => _isListening = true);
    _speech!.listen(
      onResult: (result) {
        setState(() { _sourceController.text = result.recognizedWords; });
      },
      localeId: 'ar',
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void _onSourceChanged(String value) {
    if (value.isEmpty) _translatedController.clear();
  }

  Future<void> _performTranslation() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final ts = context.read<TranslationService>();
      final result = await ts.translate(_sourceController.text, from: _sourceLang, to: _targetLang);
      if (mounted) setState(() { _translatedController.text = result; _isTranslating = false; });
    } catch (e) {
      if (mounted) { setState(() => _isTranslating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشلت الترجمة: $e'))); }
    }
  }

  void _speakTranslation() { context.read<TTSService>().speak(_translatedController.text, language: _targetLang); }
  void _shareTranslation() {
    final t = _translatedController.text.trim();
    if (t.isEmpty) return;
    Share.share("ترجم هذا النص بواسطة Mirror Scorpion 🦂

$t");

$t")
  }
  void _copyTranslation() {
    final t = _translatedController.text.trim();
    if (t.isEmpty) return;
    Clipboard.setData(ClipboardData(text: "ترجم هذا النص بواسطة Mirror Scorpion 🦂

$t"));

$t"))
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ مع توقيع Mirror Scorpion'))))
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['mp3','wav','m4a','ogg','aac']);
    if (result != null && result.files.single.path != null) {
      setState(() => _isProcessingAudio = true);
      try {
        await Future.delayed(const Duration(seconds: 2));)
        if (mounted) {
          setState(() { _sourceController.text = "تم استلام الملف: ${result.files.single.name}"; _isProcessingAudio = false; });
          _performTranslation();
        }
      } catch (e) {
        if (mounted) { setState(() => _isProcessingAudio = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e'))); }
      }
    }
  }

  @override
  void dispose() { _sourceController.dispose(); _translatedController.dispose(); _speech?.stop(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final langService = context.watch<LanguageService>();
    final tts = context.watch<TTSService>();
    final langCodes = langService.getLanguageCodes();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // شريط اللغات
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))),
          child: Row(children: [
            Expanded(child: DropdownButton<String>(
              value: langCodes.contains(_sourceLang) ? _sourceLang : 'auto',
              dropdownColor: const Color(0xFF0D1B2A),
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 13),
              underline: const SizedBox(), isExpanded: true,
              items: langCodes.map((c) => DropdownMenuItem(value: c, child: Text(langService.getLanguageName(c), style: const TextStyle(color: Colors.white, fontSize: 13)))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _sourceLang = v); _saveLanguages(); if (_sourceController.text.isNotEmpty) _performTranslation(); } })),
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.arrow_forward, color: Colors.cyanAccent, size: 16)),
            Expanded(child: DropdownButton<String>(
              value: langCodes.contains(_targetLang) ? _targetLang : 'en',
              dropdownColor: const Color(0xFF0D1B2A),
              style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
              underline: const SizedBox(), isExpanded: true,
              items: langCodes.map((c) => DropdownMenuItem(value: c, child: Text(langService.getLanguageName(c), style: const TextStyle(color: Colors.white, fontSize: 13)))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _targetLang = v); _saveLanguages(); if (_sourceController.text.isNotEmpty) _performTranslation(); } })),
          ],),),
        const SizedBox(height: 16),
        // المحرر العلوي
        Container(decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withOpacity(0.4))),
          child: Column(children: [
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: const Text('النص الأصلي', style: TextStyle(color: Colors.blueAccent, fontSize: 12))),
            TextField(controller: _sourceController, maxLines: 5, minLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16),
                hintText: 'اكتب النص هنا أو استخدم المايك...', hintStyle: TextStyle(color: Colors.white24)),
              onChanged: (v) { if (v.isEmpty && _translatedController.text.isNotEmpty) _translatedController.clear(); }),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
              child: Row(children: [
                IconButton(icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.redAccent : Colors.blueAccent, size: 28), onPressed: _startListening, tooltip: 'التقاط الكلام'),
                IconButton(icon: _isProcessingAudio ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.orangeAccent)) : const Icon(Icons.push_pin, color: Colors.orangeAccent, size:22), onPressed: _isProcessingAudio ? null : _pickAudioFile, tooltip: 'رفع ملف صوتي للترجمة'),
                const Spacer(),
                if (_sourceController.text.isNotEmpty) ElevatedButton.icon(onPressed: _isTranslating ? null : _performTranslation,
                  icon: _isTranslating ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Icon(Icons.translate, size:18),
                  label: Text(_isTranslating ? 'جار...' : 'ترجمة'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
              ])),
          ],),),
        const SizedBox(height: 16),
        // المحرر السفلي
        Container(decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber.withOpacity(0.4))),
          child: Column(children: [
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: const Text('الترجمة', style: TextStyle(color: Colors.amberAccent, fontSize: 12))),
            TextField(controller: _translatedController, maxLines: 5, minLines: 3,
              style: const TextStyle(color: Colors.amberAccent, fontSize: 16, height: 1.5),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16),
                hintText: 'الترجمة ستظهر هنا...', hintStyle: TextStyle(color: Colors.white24)), readOnly: true),
            if (_translatedController.text.isNotEmpty)
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(icon: Icon(Icons.volume_up, color: tts.isSpeaking ? Colors.cyanAccent : Colors.greenAccent, size: 24), onPressed: _speakTranslation, tooltip: 'نطق الترجمة'),
                  IconButton(icon: const Icon(Icons.share, color: Colors.blueAccent, size: 22), onPressed: _shareTranslation, tooltip: 'مشاركة مع توقيع Mirror Scorpion'),
                  IconButton(icon: const Icon(Icons.push_pin_outlined, color: Colors.orangeAccent, size: 22), onPressed: _pickAudioFile, tooltip: 'ترجمة ملف صوتي وارد'),
                  IconButton(icon: const Icon(Icons.copy, color: Colors.white70, size: 22), onPressed: _copyTranslation, tooltip: 'نسخ النص المترجم مع التوقيع'),
                ])),
          ],),),
        const SizedBox(height: 20),
        const Align(alignment: Alignment.center, child: WatermarkText(text: 'Mirror Scorpion')),
      ])),
    );
  }
}
