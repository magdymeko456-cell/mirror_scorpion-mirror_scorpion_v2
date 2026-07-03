import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
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
  bool _isTranslating = false;
  bool _isProcessingAudio = false;
  String _sourceLang = 'auto';
  String _targetLang = 'en';
  bool _showTargetLang = false; // للتحكم في إظهار قائمة اللغات المستهدفة
  final FocusNode _sourceFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadSavedLanguages();
    _sourceController.addListener(_onSourceChanged);
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    _sourceFocus.dispose();
    _speech?.stop();
    super.dispose();
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

  void _onSourceChanged() {
    if (_sourceController.text.isNotEmpty && !_isTranslating) {
      _performTranslation();
    }
  }

  void _startListening() async {
    if (_speech == null || !_speech!.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('التعرف على الصوت غير متاح')),
      );
      return;
    }

    // إذا كان المستخدم يضغط على المايك بعد ترجمة -> مسح وبدء جديد
    if (_translatedController.text.isNotEmpty) {
      _sourceController.clear();
      _translatedController.clear();
    }

    if (_isListening) {
      _speech!.stop();
      setState(() => _isListening = false);
      return;
    }

    setState(() => _isListening = true);
    _speech!.listen(
      onResult: (result) {
        setState(() {
          _sourceController.text = result.recognizedWords;
          _sourceController.selection = TextSelection.fromPosition(
            TextPosition(offset: _sourceController.text.length),
          );
        });
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      localeId: _sourceLang == 'auto' ? 'ar' : _sourceLang,
    );
  }

  void _performTranslation() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);

    try {
      final translationService = context.read<TranslationService>();
      final result = await translationService.translate(
        _sourceController.text,
        from: _sourceLang,
        to: _targetLang,
      );
      if (mounted) {
        setState(() {
          _translatedController.text = result;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isTranslating = false);
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac', 'amr', '3gp'],
      );
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        setState(() => _isProcessingAudio = true);

        // محاولة فتح الملف الصوتي لتفريغه (استخدام speech_to_text على ملف)
        // حاليًا: استخراج اسم الملف كـ "نص" مؤقت
        // في الإصدار القادم: ربط مع Google Speech-to-Text API لتفريغ الملفات
        _sourceController.text = '📂 ملف صوتي: $fileName\nجارِ تفريغ الصوت إلى نص...';

        try {
          // الواجهة المؤقتة: نستخدم اسم الملف
          final cleanName = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
          _sourceController.text = cleanName;
          _performTranslation();
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('خطأ في معالجة الملف: $e')),
            );
          }
        }

        if (mounted) setState(() => _isProcessingAudio = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessingAudio = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم اختيار ملف')),
        );
      }
    }
  }

  void _speakTranslation() {
    final tts = context.read<TTSService>();
    tts.speak(_translatedController.text, language: _targetLang == 'auto' ? 'ar' : _targetLang);
  }

  void _shareTranslation() {
    if (_translatedController.text.isEmpty) return;
    final textWithSignature = '$_translatedController\n\n— Mirror Scorpion 🦂';
    Share.share(textWithSignature, subject: 'ترجمة بواسطة Mirror Scorpion');
  }

  void _copyTranslation() {
    if (_translatedController.text.isEmpty) return;
    final textWithSignature = '$_translatedController\n\n— Mirror Scorpion 🦂';
    Clipboard.setData(ClipboardData(text: textWithSignature));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم النسخ مع توقيع Mirror Scorpion')),
    );
  }

  void _clearAll() {
    _sourceController.clear();
    _translatedController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final langService = context.watch<LanguageService>();
    final tts = context.watch<TTSService>();
    final langCodes = langService.getLanguageCodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_translatedController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              onPressed: _clearAll,
              tooltip: 'بدء ترجمة جديدة',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== زر اللغات في منتصف الشاشة العلوي =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // لغة المصدر
                  SizedBox(
                    width: 110,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: langCodes.contains(_sourceLang) ? _sourceLang : 'auto',
                        dropdownColor: const Color(0xFF0D1B2A),
                        style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent, size: 18),
                        isExpanded: true,
                        items: langCodes.map((code) {
                          return DropdownMenuItem(
                            value: code,
                            child: Text(
                              langService.getLanguageName(code),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _sourceLang = v);
                            _saveLanguages();
                            if (_sourceController.text.isNotEmpty) _performTranslation();
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.arrow_forward, color: Colors.blueAccent, size: 18),
                  ),
                  const SizedBox(width: 8),
                  // لغة الهدف
                  SizedBox(
                    width: 110,
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: langCodes.contains(_targetLang) ? _targetLang : 'en',
                        dropdownColor: const Color(0xFF0D1B2A),
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.amberAccent, size: 18),
                        isExpanded: true,
                        items: langCodes.map((code) {
                          return DropdownMenuItem(
                            value: code,
                            child: Text(
                              langService.getLanguageName(code),
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (v) {
                          if (v != null) {
                            setState(() => _targetLang = v);
                            _saveLanguages();
                            if (_sourceController.text.isNotEmpty) _performTranslation();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== المحرر العلوي — النص الأصلي =====
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Text(
                      'النص الأصلي (${langService.getLanguageName(_sourceLang)})',
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 12),
                    ),
                  ),
                  // حقل الإدخال
                  TextField(
                    controller: _sourceController,
                    focusNode: _sourceFocus,
                    maxLines: 5,
                    minLines: 3,
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                      hintText: 'اكتب النص هنا أو استخدم المايك للتحدث...',
                      hintStyle: TextStyle(color: Colors.white24),
                    ),
                  ),
                  // الأزرار السفلية للمحرر العلوي
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        // مايك لالتقاط الكلام — أسفل يسار
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.redAccent : Colors.blueAccent,
                            size: 28,
                          ),
                          onPressed: _startListening,
                          tooltip: 'التقاط الكلام',
                        ),
                        // دبوس مشبك 📎 (وليس دبوس عادي)
                        IconButton(
                          icon: _isProcessingAudio
                              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent))
                              : const Icon(Icons.attach_file, color: Colors.orangeAccent, size: 22),
                          onPressed: _isProcessingAudio ? null : _pickAudioFile,
                          tooltip: 'رفع ملف صوتي لتفريغه وترجمته',
                        ),
                        const Spacer(),
                        // زر الترجمة إذا كان هناك نص
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
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== المحرر السفلي — الترجمة =====
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.withOpacity(0.4)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Text(
                      'الترجمة (${langService.getLanguageName(_targetLang)})',
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                    ),
                  ),
                  // محرر الترجمة
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
                  // الأزرار السفلية للمحرر السفلي
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
                          // سبيكر — نطق الترجمة (أقصى اليمين)
                          IconButton(
                            icon: Icon(Icons.volume_up,
                                color: tts.isSpeaking ? Colors.cyanAccent : Colors.greenAccent,
                                size: 24),
                            onPressed: _speakTranslation,
                            tooltip: 'نطق الترجمة',
                          ),
                          // مشاركة — ملف صوتي + توقيع
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.blueAccent, size: 22),
                            onPressed: _shareTranslation,
                            tooltip: 'مشاركة مع توقيع Mirror Scorpion',
                          ),
                          // دبوس مشبك — رفع ملف صوتي لترجمته
                          IconButton(
                            icon: const Icon(Icons.attach_file, color: Colors.orangeAccent, size: 22),
                            onPressed: _pickAudioFile,
                            tooltip: 'ترجمة ملف صوتي وارد',
                          ),
                          // نسخ — مع توقيع
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 22),
                            onPressed: _copyTranslation,
                            tooltip: 'نسخ الترجمة مع توقيع Mirror Scorpion',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ===== توقيع التطبيق =====
            const Align(
              alignment: Alignment.center,
              child: WatermarkText(text: 'Mirror Scorpion'),
            ),

            const SizedBox(height: 8),

            // ===== نبذة =====
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'ميرور سكربيون: حيث تُصنع البدايات',
                    style: TextStyle(
                      color: Colors.blueAccent.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'الوقت هو العملة الأغلى. هنا، نحن لا نقيس أعمارنا بالسنوات، بل بكل ثانية نصنع فيها إنجازاً حقيقياً.',
                    style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                    textAlign: TextAlign.center,
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
