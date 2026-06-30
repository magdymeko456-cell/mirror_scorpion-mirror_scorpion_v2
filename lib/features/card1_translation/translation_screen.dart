import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import '../../services/ai_service.dart';
import '../../services/database_service.dart';

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
    final langService = Provider.of<LanguageService>(context, listen: false);
    setState(() {
      _sourceLang = langService.getLanguageForScreen('text_translation_source');
      if (_sourceLang == 'auto') _sourceLang = 'auto';
      _targetLang = langService.getLanguageForScreen('text_translation_target');
      if (_targetLang == 'auto') _targetLang = 'en';
    });
  }

  void _saveLanguages() {
    final langService = Provider.of<LanguageService>(context, listen: false);
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
    await _speech!.listen(
      onResult: (result) {
        setState(() {
          _sourceController.text = result.recognizedWords;
        });
      },
      localeId: _sourceLang == 'auto' ? 'ar_SA' : '${_sourceLang}_${_sourceLang.toUpperCase()}',
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
    );
    await _speech!.stop();
    if (mounted) {
      setState(() => _isListening = false);
      if (_sourceController.text.isNotEmpty) _performTranslation();
    }
  }

  /// 🎯 AUDIO UPLOAD PIN - رفع ملف صوتي من الجهاز أو التطبيقات
  Future<void> _pickAudioFile() async {
    setState(() => _isProcessingAudio = true);
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac', 'amr', '3gp'],
        allowMultiple: false,
      );
      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ تم اختيار الملف: $fileName\nجارٍ معالجة الصوت...')),
          );
          // محاكاة التعرف على الصوت من الملف
          _sourceController.text = '📂 تم استيراد الملف الصوتي: $fileName\n⏳ جارٍ التعرف على الكلام...';
          await Future.delayed(const Duration(seconds: 2));
          _sourceController.text = '[نص تم التعرف عليه من الملف الصوتي: $fileName]';
          if (mounted) _performTranslation();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ في فتح الملف: $e')),
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
      // استخدام AI لتحسين الترجمة
      String text = _sourceController.text;
      String apiKey = ''; // المستخدم يدخل API key لاحقاً
      String improvedText = text;
      if (apiKey.isNotEmpty) {
        improvedText = await AIService.callOpenAIAPI(
          prompt: 'حسن النص التالي:\n$text',
          apiKey: apiKey,
        );
      }
      // محاكاة الترجمة (في الإصدار الحقيقي نستخدم Google Translate API)
      await Future.delayed(const Duration(milliseconds: 800));
      String translated = '[$_sourceLang → $_targetLang]\n$improvedText';
      
      // حفظ الترجمة في التاريخ
      final db = Provider.of<DatabaseService>(context, listen: false);
      db.saveTranslation(text, translated, sourceLang: _sourceLang, targetLang: _targetLang);
      
      setState(() => _translatedController.text = translated);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ في الترجمة: $e')),
        );
      }
    }
    if (mounted) setState(() => _isTranslating = false);
  }

  void _speakTranslation() {
    final tts = Provider.of<TTSService>(context, listen: false);
    if (_translatedController.text.isNotEmpty) {
      tts.speak(_translatedController.text, language: _targetLang);
    }
  }

  void _shareTranslation() {
    String watermark = '\n\n— — — — — — — — — —\n🌐 تُرجم بواسطة ميرور سكربيون 🦂\nحيث تُصنع البدايات';
    Clipboard.setData(ClipboardData(text: _translatedController.text + watermark));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم النسخ مع توقيع التطبيق للمشاركة')),
    );
  }

  void _copyTranslation() {
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ النص المترجم')),
    );
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
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- زر اختيار اللغة (100+ لغة) في وسط الأعلى ---
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
                  DropdownButton<String>(
                    value: langCodes.contains(_sourceLang) ? _sourceLang : 'auto',
                    dropdownColor: const Color(0xFF0D1B2A),
                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 14),
                    underline: const SizedBox(),
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
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.arrow_forward, color: Colors.white38, size: 18),
                  ),
                  DropdownButton<String>(
                    value: langCodes.contains(_targetLang) ? _targetLang : 'en',
                    dropdownColor: const Color(0xFF0D1B2A),
                    style: const TextStyle(color: Colors.amberAccent, fontSize: 14),
                    underline: const SizedBox(),
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
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- المحرر العلوي (النص المصدر) ---
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
                  // شريط الأدوات السفلي للمحرر العلوي
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        // 🎤 مايك
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.redAccent : Colors.blueAccent,
                            size: 28,
                          ),
                          onPressed: _startListening,
                          tooltip: 'التقاط الصوت',
                        ),
                        // 📌 AUDIO UPLOAD PIN - رفع ملف صوتي
                        IconButton(
                          icon: _isProcessingAudio
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent))
                              : const Icon(Icons.push_pin, color: Colors.orangeAccent, size: 22),
                          onPressed: _isProcessingAudio ? null : _pickAudioFile,
                          tooltip: 'رفع ملف صوتي',
                        ),
                        const Spacer(),
                        // زر الترجمة
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

            // --- المحرر السفلي (نص الترجمة) ---
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
                  // شريط الأدوات السفلي للمحرر السفلي
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_translatedController.text.isNotEmpty) ...[
                          // 🔊 سبيكر
                          IconButton(
                            icon: Icon(Icons.volume_up, 
                              color: tts.isSpeaking ? Colors.cyanAccent : Colors.greenAccent, size: 24),
                            onPressed: _speakTranslation,
                            tooltip: 'نطق الترجمة',
                          ),
                          // 🔗 مشاركة مع توقيع
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.blueAccent, size: 22),
                            onPressed: _shareTranslation,
                            tooltip: 'مشاركة مع توقيع التطبيق',
                          ),
                          // 📋 نسخ
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 22),
                            onPressed: _copyTranslation,
                            tooltip: 'نسخ النص',
                          ),
                        ],
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
