import "package:share_plus/share_plus.dart";
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';

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
        const SnackBar(content: Text('⚠️ التعرف على الصوت غير متاح على هذا الجهاز')),
      );
      return;
    }

    if (_isListening) {
      _speech!.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() {
      _isListening = true;
      _sourceController.clear();
      _translatedController.clear();
    });

    _speech!.listen(
      onResult: (result) {
        setState(() {
          _sourceController.text = result.recognizedWords;
        });
      },
      localeId: _sourceLang == 'auto' ? 'ar_SA' : _sourceLang,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
    );
  }

  void _performTranslation() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    // محاكاة الترجمة (في الإصدار القادم سيتم ربط API حقيقي)
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _translatedController.text = '[${_targetLang.toUpperCase()}] ${_sourceController.text}';
      _isTranslating = false;
    });
    _saveLanguages();
  }

  void _speakTranslation() {
    final tts = context.read<TTSService>();
    tts.speak(_translatedController.text, language: _targetLang);
  }

  void _shareTranslation() {
    final text = '${_translatedController.text}\n\n— — — — — — — — — —\n🌐 تُرجم بواسطة ميرور سكربيون 🦂';
    Clipboard.setData(ClipboardData(text: text));
    Share.share(text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم النسخ مع التوقيع - يمكنك المشاركة')),
    );
  }

  void _copyTranslation() {
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ النص المترجم')),
    );
  }

  void _pickAudioFile() async {
    try {
      setState(() => _isProcessingAudio = true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      if (result != null) {
        setState(() {
          _sourceController.text = '🎵 ملف صوتي: ${result.files.single.name}\n(سيتم استخراج النص في النسخة القادمة)';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ $e')),
      );
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
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- زر اختيار اللغة (100+ لغة) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language, color: Colors.cyanAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: langCodes.contains(_sourceLang) ? _sourceLang : 'auto',
                      dropdownColor: const Color(0xFF0D1B2A),
                      style: const TextStyle(color: Colors.cyanAccent, fontSize: 13),
                      underline: const SizedBox(),
                      isExpanded: true,
                      items: langCodes.map((code) {
                        return DropdownMenuItem(
                          value: code,
                          child: Text(langService.getLanguageName(code),
                              style: const TextStyle(color: Colors.white, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _sourceLang = v);
                      },
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(Icons.arrow_forward, color: Colors.white38, size: 16),
                  ),
                  Expanded(
                    child: DropdownButton<String>(
                      value: langCodes.contains(_targetLang) ? _targetLang : 'en',
                      dropdownColor: const Color(0xFF0D1B2A),
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
                      underline: const SizedBox(),
                      isExpanded: true,
                      items: langCodes.map((code) {
                        return DropdownMenuItem(
                          value: code,
                          child: Text(langService.getLanguageName(code),
                              style: const TextStyle(color: Colors.white, fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _targetLang = v);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- المحرر العلوي ---
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _sourceController,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: 'اكتب النص هنا أو استخدم المايك...',
                      hintStyle: TextStyle(color: Colors.white24),
                    ),
                    onChanged: (_) => setState(() {}),
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
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.redAccent : Colors.blueAccent,
                            size: 28,
                          ),
                          onPressed: _startListening,
                          tooltip: 'التقاط الصوت',
                        ),
                        IconButton(
                          icon: _isProcessingAudio
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent))
                              : const Icon(Icons.push_pin, color: Colors.orangeAccent, size: 22),
                          onPressed: _isProcessingAudio ? null : _pickAudioFile,
                          tooltip: 'رفع ملف صوتي',
                        ),
                        const Spacer(),
                        if (_sourceController.text.isNotEmpty)
                          ElevatedButton.icon(
                            onPressed: _isTranslating ? null : _performTranslation,
                            icon: _isTranslating
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                : const Icon(Icons.translate, size: 18),
                            label: Text(_isTranslating ? 'جارٍ...' : 'ترجمة'),
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

            // --- المحرر السفلي ---
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _translatedController,
                    maxLines: 6,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 16),
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
                            tooltip: 'مشاركة مع توقيع التطبيق',
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 22),
                            onPressed: _copyTranslation,
                            tooltip: 'نسخ النص',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
