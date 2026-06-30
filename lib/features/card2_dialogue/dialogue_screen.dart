import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import 'dart:math';

class DialogueTranslationScreen extends StatefulWidget {
  const DialogueTranslationScreen({super.key});

  @override
  State<DialogueTranslationScreen> createState() => _DialogueTranslationScreenState();
}

class _DialogueTranslationScreenState extends State<DialogueTranslationScreen>
    with TickerProviderStateMixin {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _langFrom = 'ar';
  String _langTo = 'en';
  bool _isTranslating = false;
  bool _isProcessingAudio = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
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
      if (_langFrom == 'auto' || _langFrom.isEmpty) _langFrom = 'ar';
      if (_langTo == 'auto' || _langTo.isEmpty) _langTo = 'en';
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
    if (_speech == null || !(await _speech!.initialize())) {
      return;
    }

    if (_isListening) {
      _speech!.stop();
      setState(() => _isListening = false);
      return;
    }

    // امسح المحررين عند بدء استماع جديد
    _sourceController.clear();
    _translatedController.clear();
    setState(() => _isListening = true);

    // المحرر العلوي يفهم اللغة الموجودة في الزر الذي بجانبه (جهة اليمين)
    _speech!.listen(
      onResult: (result) {
        setState(() {
          _sourceController.text = result.recognizedWords;
        });
      },
      localeId: '${_langFrom}_${_langFrom.toUpperCase()}',
      listenMode: stt.ListenMode.dictation,
    );

    // محاكاة ترجمة تلقائية أثناء الاستماع
    while (_isListening) {
      await Future.delayed(const Duration(milliseconds: 1500));
      if (_sourceController.text.isNotEmpty && mounted) {
        _performTranslation();
      }
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      setState(() => _isProcessingAudio = true);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
      );
      if (result != null && result.files.single.path != null) {
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) {
          _sourceController.text = 'ملف صوتي: ${result.files.single.name}';
        }
      }
    } finally {
      if (mounted) setState(() => _isProcessingAudio = false);
    }
  }

  void _performTranslation() async {
    if (_sourceController.text.isEmpty) return;

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      final text = _sourceController.text;
      String translated;

      // محاكاة الترجمة
      if (_langTo == 'ar') {
        if (text.contains('Hello')) translated = 'مرحباً';
        else if (text.contains('How are')) translated = 'كيف حالك؟';
        else if (text.contains('Thank')) translated = 'شكراً';
        else if (text.contains('Good')) translated = 'جيد';
        else if (text.contains('Peace')) translated = 'سلام';
        else if (text.contains('مرحباً')) translated = 'Hello';
        else if (text.contains('كيف حالك')) translated = 'How are you?';
        else if (text.contains('شكراً')) translated = 'Thank you';
        else if (text.contains('الحمد')) translated = 'Praise be to Allah';
        else if (text.contains('بسم')) translated = 'In the name of Allah';
        else translated = '[$_langTo] $text';
      } else {
        translated = '[$_langTo] $text';
      }

      setState(() {
        _translatedController.text = translated;
      });
    } catch (_) {}
  }

  void _speakTranslation() {
    final tts = Provider.of<TTSService>(context, listen: false);
    if (_translatedController.text.isNotEmpty) {
      tts.speak(_translatedController.text);
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    _speech?.stop();
    _pulseController.dispose();
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
            // --- صف اللغات: اليمين (من) | تبديل | اليسار (إلى) ---
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: langCodes.contains(_langFrom) ? _langFrom : 'ar',
                        dropdownColor: const Color(0xFF0D1B2A),
                        style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                        isExpanded: true,
                        items: langCodes.map((code) => DropdownMenuItem(
                          value: code,
                          child: Text(langService.getLanguageName(code),
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                        )).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _langFrom = v);
                            _saveLanguages();
                          }
                        },
                      ),
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
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: langCodes.contains(_langTo) ? _langTo : 'en',
                        dropdownColor: const Color(0xFF0D1B2A),
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                        isExpanded: true,
                        items: langCodes.map((code) => DropdownMenuItem(
                          value: code,
                          child: Text(langService.getLanguageName(code),
                            style: const TextStyle(color: Colors.white, fontSize: 12)),
                        )).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _langTo = v);
                            _saveLanguages();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- المايك الكبير في المنتصف ---
            GestureDetector(
              onTap: _startListening,
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: _isListening
                          ? [Colors.redAccent, Colors.red.shade900]
                          : [Colors.greenAccent, Colors.green.shade900],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? Colors.redAccent : Colors.greenAccent)
                              .withOpacity(0.3 + _pulseController.value * 0.3),
                          blurRadius: 20 + _pulseController.value * 15,
                          spreadRadius: 3 + _pulseController.value * 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 40,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _isListening ? '🟢 جارٍ الاستماع (اضغط للإيقاف)' : '🎤 اضغط للبدء',
              style: TextStyle(
                color: _isListening ? Colors.greenAccent : Colors.white38,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 14),

            // --- المحرر العلوي (النص المصدر) ---
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: TextField(
                      controller: _sourceController,
                      maxLines: null,
                      style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'النص الأصلي يظهر هنا...',
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.redAccent : Colors.greenAccent,
                            size: 22),
                          onPressed: _startListening,
                        ),
                        PopupMenuButton<String>(
                          icon: _isProcessingAudio
                            ? const SizedBox(width: 18, height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent))
                            : const Icon(Icons.push_pin, color: Colors.orangeAccent, size: 22),
                          color: const Color(0xFF1B2838),
                          onSelected: (v) {
                            if (v == 'file') _pickAudioFile();
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(
                              value: 'file',
                              child: ListTile(
                                leading: Icon(Icons.audio_file, color: Colors.cyanAccent),
                                title: Text('📂 ملف صوتي', style: TextStyle(color: Colors.white, fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (_sourceController.text.isNotEmpty)
                          TextButton.icon(
                            onPressed: _isTranslating ? null : _performTranslation,
                            icon: _isTranslating
                              ? const SizedBox(width: 14, height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.translate, size: 16),
                            label: const Text('ترجمة'),
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
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 150),
                    child: TextField(
                      controller: _translatedController,
                      maxLines: null,
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 15, height: 1.5),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        hintText: 'الترجمة ستظهر هنا...',
                        hintStyle: TextStyle(color: Colors.white24),
                      ),
                      readOnly: true,
                    ),
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
                          // 🔊 سبيكر
                          IconButton(
                            icon: Icon(Icons.volume_up,
                              color: tts.isSpeaking ? Colors.cyanAccent : Colors.greenAccent,
                              size: 22),
                            onPressed: _speakTranslation,
                          ),
                          // 📋 نسخ
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: _translatedController.text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('✅ تم النسخ')),
                              );
                            },
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
