import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
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
      setState(() => _isListening = false);
      _sourceController.clear();
      _translatedController.clear();
      return;
    }
    _sourceController.clear();
    _translatedController.clear();
    setState(() => _isListening = true);

    _speech!.listen(
      onResult: (result) {
        setState(() {
          _sourceController.text = result.recognizedWords;
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
    );
  }

  void _onSourceChanged(String value) {
    setState(() {});
    if (_translatedController.text.isNotEmpty && value.isNotEmpty) {
      _translatedController.clear();
    }
  }

  Future<void> _performTranslation() async {
    final text = _sourceController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final result = await TranslationService().translate(
        text, from: _sourceLang, to: _targetLang,
      );
      _translatedController.text = result;
    } catch (e) {
      _translatedController.text = 'خطأ في الترجمة: $e';
    }
    setState(() => _isTranslating = false);
    _saveLanguages();
  }

  void _speakTranslation() {
    context.read<TTSService>().speak(
      _translatedController.text, language: _targetLang,
    );
  }

  void _shareTranslation() {
    if (_translatedController.text.isEmpty) return;
    final signedText = '${_translatedController.text}\n\nترجم هذا النص بواسطة Mirror Scorpion \u{1F982}';
    Share.share(signedText, subject: 'ترجمة - Mirror Scorpion');
  }

  void _copyTranslation() {
    if (_translatedController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم النسخ بنجاح'), duration: Duration(seconds: 1)),
    );
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _isProcessingAudio = true;
          _sourceController.text = 'ملف صوتي: ${result.files.single.name}\n(جاري المعالجة...)';
        });
        await Future.delayed(const Duration(seconds: 2));
        _sourceController.text = 'ملف صوتي: ${result.files.single.name}\n(خدمة استخراج النص قيد التفعيل)';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      setState(() => _isProcessingAudio = false);
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    _speech?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langService = context.watch<LanguageService>();
    final tts = context.watch<TTSService>();
    final List<String> langCodes = langService.getLanguageCodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('ترجمة نصية',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // زر تحديد اللغة - منتصف الشاشة العلوي
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.translate, color: Colors.cyanAccent, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: langCodes.contains(_sourceLang) ? _sourceLang : 'auto',
                      dropdownColor: const Color(0xFF0D1B2A),
                      style: const TextStyle(color: Colors.cyanAccent, fontSize: 13),
                      underline: const SizedBox(),
                      isExpanded: true,
                      items: langCodes.map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(langService.getLanguageName(code),
                          style: const TextStyle(color: Colors.white, fontSize: 13)),
                      )).toList(),
                      onChanged: (v) { if (v != null) { setState(() => _sourceLang = v); _saveLanguages(); } },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.cyanAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.cyanAccent, size: 16),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: langCodes.contains(_targetLang) ? _targetLang : 'en',
                      dropdownColor: const Color(0xFF0D1B2A),
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
                      underline: const SizedBox(),
                      isExpanded: true,
                      items: langCodes.map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(langService.getLanguageName(code),
                          style: const TextStyle(color: Colors.white, fontSize: 13)),
                      )).toList(),
                      onChanged: (v) { if (v != null) { setState(() => _targetLang = v); _saveLanguages(); } },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // المحرر العلوي
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Text('النص الأصلي',
                      style: TextStyle(color: Colors.blueAccent, fontSize: 12)),
                  ),
                  TextField(
                    controller: _sourceController,
                    maxLines: 5,
                    minLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: 'اكتب النص هنا أو استخدم المايك...',
                      hintStyle: TextStyle(color: Colors.white24),
                    ),
                    onChanged: _onSourceChanged,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.redAccent : Colors.blueAccent, size: 28),
                          onPressed: _startListening,
                          tooltip: 'التقاط الكلام',
                        ),
                        IconButton(
                          icon: _isProcessingAudio
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent))
                            : const Icon(Icons.push_pin, color: Colors.orangeAccent, size: 22),
                          onPressed: _isProcessingAudio ? null : _pickAudioFile,
                          tooltip: 'رفع ملف صوتي للترجمة',
                        ),
                        const Spacer(),
                        if (_sourceController.text.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: _isTranslating ? null : _performTranslation,
                            icon: _isTranslating
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.translate, size: 18),
                            label: Text(_isTranslating ? 'جار...' : 'ترجمة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // المحرر السفلي
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Text('الترجمة',
                      style: TextStyle(color: Colors.amberAccent, fontSize: 12)),
                  ),
                  TextField(
                    controller: _translatedController,
                    maxLines: 5,
                    minLines: 3,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 16, height: 1.5),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: 'الترجمة ستظهر هنا...',
                      hintStyle: TextStyle(color: Colors.white24),
                    ),
                    readOnly: true,
                  ),
                  if (_translatedController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.volume_up,
                              color: tts.isSpeaking ? Colors.cyanAccent : Colors.greenAccent, size: 24),
                            onPressed: _speakTranslation,
                            tooltip: 'نطق الترجمة',
                          ),
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.blueAccent, size: 22),
                            onPressed: _shareTranslation,
                            tooltip: 'مشاركة مع توقيع Mirror Scorpion',
                          ),
                          IconButton(
                            icon: const Icon(Icons.push_pin_outlined, color: Colors.orangeAccent, size: 22),
                            onPressed: _pickAudioFile,
                            tooltip: 'ترجمة ملف صوتي وارد',
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 22),
                            onPressed: _copyTranslation,
                            tooltip: 'نسخ النص المترجم',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.center,
              child: WatermarkText(text: 'Mirror Scorpion'),
            ),
          ],
        ),
      ),
    );
  }
}
