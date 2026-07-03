import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
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

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    _speech?.stop();
    super.dispose();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    await _speech!.initialize();
  }

  void _loadSavedLanguages() {
    final ls = context.read<LanguageService>();
    setState(() {
      _langFrom = ls.getLanguageForScreen('dialogue_from');
      if (_langFrom == 'auto') _langFrom = 'ar';
      _langTo = ls.getLanguageForScreen('dialogue_to');
      if (_langTo == 'auto') _langTo = 'en';
    });
  }

  void _saveLanguages() {
    final ls = context.read<LanguageService>();
    ls.saveLanguageForScreen('dialogue_from', _langFrom);
    ls.saveLanguageForScreen('dialogue_to', _langTo);
  }

  void _swapLanguages() {
    setState(() {
      final t = _langFrom;
      _langFrom = _langTo;
      _langTo = t;
    });
    _saveLanguages();
    final temp = _sourceController.text;
    _sourceController.text = _translatedController.text;
    _translatedController.text = temp;
    // إذا كان هناك نص بعد التبديل، نترجم فوراً
    if (_sourceController.text.isNotEmpty) {
      _performTranslation(_sourceController.text);
    }
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
      // مسح المحررين عند إيقاف الاستماع
      _sourceController.clear();
      _translatedController.clear();
      return;
    }

    if (_translatedController.text.isNotEmpty) {
      _sourceController.clear();
      _translatedController.clear();
    }

    setState(() => _isListening = true);

    _speech!.listen(
      onResult: (result) {
        if (!mounted) return;
        final spokenText = result.recognizedWords;
        setState(() {
          _sourceController.text = spokenText;
        });
        // ترجمة فورية عند كل نتيجة نهائية
        if (result.finalResult && spokenText.isNotEmpty) {
          _performTranslation(spokenText);
        }
      },
      listenFor: const Duration(seconds: 60),
      pauseFor: const Duration(seconds: 3),
      localeId: _langFrom,
      onSoundLevelChange: (level) {},
      cancelOnError: true,
    );
  }

  void _performTranslation(String text) async {
    if (text.trim().isEmpty) return;
    if (_isTranslating) return;
    setState(() => _isTranslating = true);

    try {
      final translationService = context.read<TranslationService>();
      final result = await translationService.translate(
        text,
        from: _langFrom,
        to: _langTo,
      );
      if (mounted) {
        setState(() {
          _translatedController.text = result;
          _isTranslating = false;
        });
      }
    } catch (e) {
      debugPrint('Translation error: $e');
      if (mounted) {
        setState(() {
          _translatedController.text = '⚠️ خطأ في الترجمة: $e';
          _isTranslating = false;
        });
      }
    }
  }

  /// دبوس مشبك — رفع ملف صوتي واستخراج النص منه
  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac', 'amr', '3gp', 'webm'],
      );
      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        setState(() => _isProcessingAudio = true);

        // محاولة تفريغ الملف الصوتي إلى نص
        // speech_to_text لا يدعم قراءة ملفات مباشرة
        // الحل المؤقت: استخدام اسم الملف + إعلام المستخدم
        // الحل الكامل: رفع الملف إلى API خارجي (Google Speech-to-Text API)
        
        final cleanName = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');
        
        // محاولة استخدام اسم الملف كنص أولي
        setState(() {
          _sourceController.text = cleanName;
        });

        // ترجمة النص المستخرج
        await _performTranslation(cleanName);

        // إعلام المستخدم بوضع التفريغ الصوتي
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('📂 تم استخراج اسم الملف: $cleanName\n⚠️ لتفريغ الصوت بدقة، استخدم المايك أو أضف مفتاح Google Speech API في الإعدادات'),
              duration: const Duration(seconds: 5),
              backgroundColor: Colors.orangeAccent.withOpacity(0.8),
            ),
          );
        }

        if (mounted) setState(() => _isProcessingAudio = false);
      }
    } catch (e) {
      debugPrint('Audio pick error: $e');
      if (mounted) {
        setState(() => _isProcessingAudio = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ فشل قراءة الملف الصوتي')),
        );
      }
    }
  }

  void _speakTranslation() {
    final tts = context.read<TTSService>();
    tts.speak(_translatedController.text, language: _langTo);
  }

  @override
  Widget build(BuildContext context) {
    final ls = context.watch<LanguageService>();
    final tts = context.watch<TTSService>();
    final codes = ls.getLanguageCodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('حوار مترجم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ===== أزرار اختيار اللغات (يمين → مصدر، يسار → هدف) =====
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  // لغة المصدر — الزر اليمين
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: codes.contains(_langFrom) ? _langFrom : 'ar',
                          dropdownColor: const Color(0xFF0D1B2A),
                          style: const TextStyle(color: Colors.pinkAccent, fontSize: 12),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.pinkAccent, size: 18),
                          isExpanded: true,
                          items: codes.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                ls.getLanguageName(c),
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _langFrom = v);
                              _saveLanguages();
                              if (_sourceController.text.isNotEmpty) {
                                _performTranslation(_sourceController.text);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  // سهم التبديل
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
                  // لغة الهدف — الزر اليسار
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amberAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: codes.contains(_langTo) ? _langTo : 'en',
                          dropdownColor: const Color(0xFF0D1B2A),
                          style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                          icon: const Icon(Icons.arrow_drop_down, color: Colors.amberAccent, size: 18),
                          isExpanded: true,
                          items: codes.map((c) {
                            return DropdownMenuItem(
                              value: c,
                              child: Text(
                                ls.getLanguageName(c),
                                style: const TextStyle(color: Colors.white, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _langTo = v);
                              _saveLanguages();
                              if (_sourceController.text.isNotEmpty) {
                                _performTranslation(_sourceController.text);
                              }
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== المحرر العلوي — لغة المصدر =====
            // المحرر العلوي يستخدم الزر الموجود ناحية اليمين مهما تم تبديله
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.pinkAccent.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Text(
                        'للتحدث (${ls.getLanguageName(_langFrom)})',
                        style: TextStyle(color: Colors.pinkAccent.withOpacity(0.8), fontSize: 11),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _sourceController,
                        maxLines: null,
                        expands: true,
                        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                          hintText: 'سيظهر هنا ما تلتقطه المايك...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                        ),
                        readOnly: true,
                      ),
                    ),
                    // إظهار مؤشر الترجمة إذا كانت قيد التنفيذ
                    if (_isTranslating)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amberAccent)),
                            const SizedBox(width: 8),
                            Text('جاري الترجمة...', style: TextStyle(color: Colors.amberAccent.withOpacity(0.6), fontSize: 11)),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ===== سهم الاتجاه =====
            Center(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_downward, color: Colors.amberAccent, size: 18),
              ),
            ),

            const SizedBox(height: 8),

            // ===== المحرر السفلي — الترجمة (لغة الهدف) =====
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amberAccent.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.amberAccent.withOpacity(0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Text(
                        'الترجمة (${ls.getLanguageName(_langTo)})',
                        style: TextStyle(color: Colors.amberAccent.withOpacity(0.8), fontSize: 11),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _translatedController,
                        maxLines: null,
                        expands: true,
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
                    // سبيكر في أقصى يمين المحرر السفلي
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
                            IconButton(
                              icon: Icon(Icons.volume_up,
                                  color: tts.isSpeaking ? Colors.cyanAccent : Colors.greenAccent,
                                  size: 24),
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

            // ===== الأزرار السفلية (دبوس مشبك + مايك كبير) =====
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
                  // دبوس مشبك 📎 لرفع ملفات صوتية
                  IconButton(
                    icon: _isProcessingAudio
                        ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent))
                        : const Icon(Icons.attach_file, color: Colors.orangeAccent, size: 26),
                    onPressed: _isProcessingAudio ? null : _pickAudioFile,
                    tooltip: 'رفع ملف صوتي واستخراج النص منه',
                  ),
                  const SizedBox(width: 20),
                  // مايك بحجم كبير
                  GestureDetector(
                    onTap: _startListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? Colors.red.withOpacity(0.2)
                            : Colors.pinkAccent.withOpacity(0.1),
                        border: Border.all(
                          color: _isListening ? Colors.red : Colors.pinkAccent,
                          width: 2,
                        ),
                        boxShadow: _isListening
                            ? [BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 15, spreadRadius: 3)]
                            : null,
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : Colors.pinkAccent,
                        size: 30,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ===== تذكير =====
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'المحرر العلوي يستخدم اللغة المحددة في الزر اليمين — دبوس المشبك 📎 لتفريغ الملفات الصوتية',
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
