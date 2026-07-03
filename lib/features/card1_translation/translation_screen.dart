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
    }
  }

  void _speakTranslation() { context.read<TTSService>().speak(_translatedController.text, language: _targetLang); }
  void _shareTranslation() {
    final t = _translatedController.text.trim();
    if (t.isEmpty) return;
    Share.share("ترجم هذا النص بواسطة Mirror Scorpion 🦂

$t");

$t");

$t");

$t")
  }
  void _copyTranslation() {
    final t = _translatedController.text.trim();
    if (t.isEmpty) return;
    Clipboard.setData(ClipboardData(text: "ترجم هذا النص بواسطة Mirror Scorpion 🦂

$t"));

$t"));

$t"));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ مع توقيع Mirror Scorpion'))))))))
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['mp3','wav','m4a','ogg','aac']);
    if (result != null && result.files.single.path != null) {
      setState(() => _isProcessingAudio = true);
      try {
      } catch (e) {
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
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      ])),
    );
  }
}
