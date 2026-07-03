import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import '../../services/translation_service.dart';
import '../../core/widgets/shared_widgets.dart';
import 'dart:async';

class DialogueTranslationScreen extends StatefulWidget {
  const DialogueTranslationScreen({super.key});
  @override
  State<DialogueTranslationScreen> createState() => _DialogueTranslationScreenState();
}

class _DialogueTranslationScreenState extends State<DialogueTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  stt.SpeechToText? _speech;
  bool _isListening = false;
  bool _isTranslating = false;
  bool _isProcessingAudio = false;
  String _langFrom = 'ar';
  String _langTo = 'en';

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
      _langFrom = langService.getLanguageForScreen('dialogue_from');
      if (_langFrom == 'auto') _langFrom = 'ar';
      _langTo = langService.getLanguageForScreen('dialogue_to');
      if (_langTo == 'auto') _langTo = 'en';
    });
  }

  void _saveLanguages() {
    final langService = context.read<LanguageService>();
    langService.saveLanguageForScreen('dialogue_from', _langFrom);
    langService.saveLanguageForScreen('dialogue_to', _langTo);
  }

  void _swapLanguages() {
    setState(() {
      final temp = _langFrom;
      _langFrom = _langTo;
      _langTo = temp;
    });
    _saveLanguages();
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
      return;
    }
    // مسح المحررين عند بدء استماع جديد
    _sourceController.clear();
    _translatedController.clear();
    setState(() => _isListening = true);

    _speech!.listen(
      onResult: (result) {
        setState(() {
          _sourceController.text = result.recognizedWords;
        });
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          _performTranslation(result.recognizedWords);
        }
      },
      listenFor: const Duration(seconds: 45),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
    );
  }

  Future<void> _performTranslation(String text) async {
    if (text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final result = await TranslationService().translate(
        text, from: _langFrom, to: _langTo,
      );
      _translatedController.text = result;
    } catch (e) {
      _translatedController.text = 'خطأ: $e';
    }
    setState(() => _isTranslating = false);
  }

  void _speakTranslation() {
    final tts = context.read<TTSService>();
    if (_translatedController.text.isNotEmpty) {
      tts.speak(_translatedController.text, language: _langTo);
    }
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
          _sourceController.text = 'معالجة الملف: ${result.files.single.name}';
        });
        await Future.delayed(const Duration(seconds: 2));
        _sourceController.text = 'ملف صوتي: ${result.files.single.name}';
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
    final List<String> langCodes = langService.getLanguageCodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('حوار مترجم',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.pinkAccent),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // صف اختيار اللغات والتبديل
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: langCodes.contains(_langFrom) ? _langFrom : 'ar',
                        dropdownColor: const Color(0xFF0D1B2A),
                        style: const TextStyle(color: Colors.pinkAccent, fontSize: 12),
                        underline: const SizedBox(),
                        isExpanded: true,
                        items: langCodes.map((code) => DropdownMenuItem(
                          value: code,
                          child: Text(langService.getLanguageName(code),
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                        )).toList(),
                        onChanged: (v) {
                          if (v != null) { setState(() => _langFrom = v); _saveLanguages(); }
                        },
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.swap_horiz, color: Colors.pinkAccent, size: 22),
                    ),
                    onPressed: _swapLanguages,
                    tooltip: 'تبديل اللغات',
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amberAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButton<String>(
                        value: langCodes.contains(_langTo) ? _langTo : 'en',
                        dropdownColor: const Color(0xFF0D1B2A),
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                        underline: const SizedBox(),
                        isExpanded: true,
                        items: langCodes.map((code) => DropdownMenuItem(
                          value: code,
                          child: Text(langService.getLanguageName(code),
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                        )).toList(),
                        onChanged: (v) {
                          if (v != null) { setState(() => _langTo = v); _saveLanguages(); }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // المحرر العلوي (مصدر النص)
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _sourceController,
                  maxLines: 8,
                  minLines: 4,
                  style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    hintText: 'سيظهر هنا ما تلتقطه...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // المحرر السفلي (الترجمة)
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _translatedController,
                        maxLines: 8,
                        minLines: 4,
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 15, height: 1.5),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          hintText: 'الترجمة ستظهر هنا...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                        ),
                        readOnly: true,
                      ),
                    ),
                    if (_translatedController.text.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.volume_up, color: Colors.greenAccent, size: 24),
                              onPressed: _speakTranslation,
                              tooltip: 'نطق الترجمة',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // الأزرار السفلية
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: _isProcessingAudio
                      ? const SizedBox(width: 24, height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent))
                      : const Icon(Icons.push_pin, color: Colors.orangeAccent, size: 26),
                    onPressed: _isProcessingAudio ? null : _pickAudioFile,
                    tooltip: 'رفع ملف صوتي للترجمة',
                  ),
                  const SizedBox(width: 16),
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isListening ? Colors.red.withOpacity(0.2) : Colors.pinkAccent.withOpacity(0.1),
                      border: Border.all(
                        color: _isListening ? Colors.red : Colors.pinkAccent,
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : Colors.pinkAccent,
                        size: 28,
                      ),
                      onPressed: _startListening,
                      tooltip: 'اضغط للتحدث',
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
