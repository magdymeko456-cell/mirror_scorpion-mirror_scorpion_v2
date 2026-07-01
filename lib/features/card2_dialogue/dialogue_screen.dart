import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';

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
  String _langFrom = 'ar';
  String _langTo = 'en';
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
    if (!await _speech!.initialize()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ التعرف على الصوت غير متاح')),
        );
      }
    }
  }

  void _loadSavedLanguages() {
    final langService = Provider.of<LanguageService>(context, listen: false);
    setState(() {
      _langFrom = langService.getLanguageForScreen('dialogue_from');
      _langTo = langService.getLanguageForScreen('dialogue_to');
      if (_langFrom == 'auto') _langFrom = 'ar';
      if (_langTo == 'auto') _langTo = 'en';
    });
  }

  void _saveLanguages() {
    final langService = Provider.of<LanguageService>(context, listen: false);
    langService.saveLanguageForScreen('dialogue_from', _langFrom);
    langService.saveLanguageForScreen('dialogue_to', _langTo);
  }

  void _swapLanguages() {
    setState(() {
      String temp = _langFrom;
      _langFrom = _langTo;
      _langTo = temp;
      String tempText = _sourceController.text;
      _sourceController.text = _translatedController.text;
      _translatedController.text = tempText;
    });
    _saveLanguages();
  }

  void _startListening() async {
    if (_speech == null || !_speech!.isAvailable) return;
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
    await _speech!.listen(
      onResult: (result) {
        setState(() => _sourceController.text = result.recognizedWords);
      },
      localeId: '${_langFrom}_${_langFrom.toUpperCase()}',
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
    );
    if (mounted) {
      setState(() => _isListening = false);
      if (_sourceController.text.isNotEmpty) _performTranslation();
    }
  }

  /// 🎯 AUDIO UPLOAD PIN - رفع ملف صوتي من الجهاز
  Future<void> _pickAudioFile() async {
    setState(() => _isProcessingAudio = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac', 'amr', '3gp', 'webm'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ تم استيراد: $fileName - جارٍ معالجة الصوت للحوار...')),
          );
          _sourceController.text = '[ملف صوتي: $fileName]\n⏳ انتظر التعرف على الكلام...';
          await Future.delayed(const Duration(seconds: 2));
          _sourceController.text = '[نص الحوار المستخرج من الملف الصوتي: $fileName]';
          if (mounted) _performTranslation();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ: $e')),
        );
      }
    }
    if (mounted) setState(() => _isProcessingAudio = false);
  }

  Future<void> _performTranslation() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    _saveLanguages();
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      String result = '[$_langFrom → $_langTo]\n${_sourceController.text} (مترجم للحوار)';
      setState(() => _translatedController.text = result);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ: $e')),
        );
      }
    }
    if (mounted) setState(() => _isTranslating = false);
  }

  void _speakTranslation() {
    final tts = Provider.of<TTSService>(context, listen: false);
    if (_translatedController.text.isNotEmpty) {
      tts.speak(_translatedController.text, language: _langTo);
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
    final langService = Provider.of<LanguageService>(context);
    final tts = Provider.of<TTSService>(context);
    final List<String> langCodes = langService.getLanguageCodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('حوار مترجم', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- شريط اللغات + تبديل ---
            Row(
              children: [
                // اللغة المصدر (يمين)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2838),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: DropdownButton<String>(
                      value: langCodes.contains(_langFrom) ? _langFrom : 'ar',
                      dropdownColor: const Color(0xFF0D1B2A),
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 13),
                      underline: const SizedBox(),
                      isExpanded: true,
                      items: langCodes.map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(langService.getLanguageName(code),
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                      )).toList(),
                      onChanged: (v) { if (v != null) setState(() => _langFrom = v); },
                    ),
                  ),
                ),
                // زر التبديل
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Colors.amberAccent, size: 30),
                  onPressed: _swapLanguages,
                  tooltip: 'تبديل اللغات',
                ),
                // اللغة الهدف (يسار)
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B2838),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber.withOpacity(0.4)),
                    ),
                    child: DropdownButton<String>(
                      value: langCodes.contains(_langTo) ? _langTo : 'en',
                      dropdownColor: const Color(0xFF0D1B2A),
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
                      underline: const SizedBox(),
                      isExpanded: true,
                      items: langCodes.map((code) => DropdownMenuItem(
                        value: code,
                        child: Text(langService.getLanguageName(code),
                          style: const TextStyle(color: Colors.white, fontSize: 12)),
                      )).toList(),
                      onChanged: (v) { if (v != null) setState(() => _langTo = v); },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- المايك الكبير ---
            GestureDetector(
              onTap: _startListening,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: _isListening
                        ? [Colors.redAccent, Colors.red.shade900]
                        : [Colors.greenAccent, Colors.green.shade900],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.redAccent : Colors.greenAccent).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(_isListening ? '🟢 جارٍ الاستماع...' : 'اضغط للبدء',
              style: TextStyle(color: _isListening ? Colors.greenAccent : Colors.white38, fontSize: 12)),
            const SizedBox(height: 12),

            // --- المحرر العلوي (النص المصدر) ---
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _sourceController,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: 'النص الأصلي يظهر هنا...',
                      hintStyle: TextStyle(color: Colors.white24),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  // شريط الأدوات - مايك + Audio Pin
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.redAccent : Colors.greenAccent, size: 22),
                          onPressed: _startListening,
                          tooltip: 'التقاط الصوت',
                        ),
                        // 📌 AUDIO UPLOAD PIN
                        IconButton(
                          icon: _isProcessingAudio
                              ? const SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent))
                              : const Icon(Icons.push_pin, color: Colors.orangeAccent, size: 22),
                          onPressed: _isProcessingAudio ? null : _pickAudioFile,
                          tooltip: 'رفع ملف صوتي',
                        ),
                        const Spacer(),
                        if (_sourceController.text.isNotEmpty)
                          TextButton.icon(
                            onPressed: _isTranslating ? null : _performTranslation,
                            icon: _isTranslating
                                ? const SizedBox(width: 14, height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.translate, size: 16),
                            label: Text(_isTranslating ? '...' : 'ترجمة'),
                            style: TextButton.styleFrom(foregroundColor: Colors.greenAccent),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // --- المحرر السفلي (الترجمة) ---
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
                    maxLines: 4,
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 15),
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
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.volume_up,
                              color: tts.isSpeaking ? Colors.cyanAccent : Colors.greenAccent, size: 22),
                            onPressed: _speakTranslation,
                            tooltip: 'نطق الترجمة',
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _translatedController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✅ تم النسخ')),
                              );
                            },
                            tooltip: 'نسخ',
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
