import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import '../../services/ai_service.dart';
import '../../services/database_service.dart';
import 'dart:math';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> with TickerProviderStateMixin {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _sourceLang = 'auto';
  String _targetLang = 'en';
  bool _isTranslating = false;
  bool _isProcessingAudio = false;
  bool _hasTranslated = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
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
      if (_sourceLang == 'auto' || _sourceLang.isEmpty) _sourceLang = 'auto';
      _targetLang = langService.getLanguageForScreen('text_translation_target');
      if (_targetLang == 'auto' || _targetLang.isEmpty) _targetLang = 'en';
    });
  }

  void _saveLanguages() {
    final langService = Provider.of<LanguageService>(context, listen: false);
    langService.saveLanguageForScreen('text_translation_source', _sourceLang);
    langService.saveLanguageForScreen('text_translation_target', _targetLang);
  }

  void _startListening() async {
    if (_speech == null || !(await _speech!.initialize())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ التعرف على الصوت غير متاح')),
      );
      return;
    }

    if (_isListening) {
      _speech!.stop();
      setState(() => _isListening = false);
      return;
    }

    // إذا كانت هناك ترجمة سابقة، امسح المحررين
    if (_hasTranslated) {
      _sourceController.clear();
      _translatedController.clear();
      setState(() => _hasTranslated = false);
    }

    setState(() => _isListening = true);

    _speech!.listen(
      onResult: (result) {
        setState(() {
          _sourceController.text = result.recognizedWords;
        });
      },
      localeId: _sourceLang == 'auto' ? 'ar_SA' : '${_sourceLang}_${_sourceLang.toUpperCase()}',
      listenMode: stt.ListenMode.dictation,
    );
  }

  Future<void> _pickAudioFile() async {
    try {
      setState(() => _isProcessingAudio = true);

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac', 'flac', '3gp', 'amr'],
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ تم رفع: $fileName - جارٍ معالجة الصوت...')),
        );

        // محاكاة تحويل الصوت إلى نص باستخدام AI (في الإصدار الكامل سيتم استخدام API)
        await Future.delayed(const Duration(seconds: 2));

        // محاكاة التعرف على الصوت من الملف
        final random = Random();
        final mockTexts = [
          'مرحباً بكم في تطبيق ميرور سكربيون',
          'هذا نص تجريبي من ملف صوتي',
          'الترجمة أصبحت سهلة مع الذكاء الاصطناعي',
          'بسم الله الرحمن الرحيم',
          'الحمد لله رب العالمين',
        ];
        
        setState(() {
          _sourceController.text = mockTexts[random.nextInt(mockTexts.length)];
          _hasTranslated = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('🎤 تم التعرف على النص من: $fileName')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ في رفع الملف: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessingAudio = false);
    }
  }

  Future<void> _pickFromSocialMedia() async {
    try {
      setState(() => _isProcessingAudio = true);
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String fileName = result.files.single.name;

        await Future.delayed(const Duration(seconds: 1));
        
        _sourceController.text = 'ملف تم استيراده: $fileName\n(سيتم تحويل الصوت إلى نص في النسخة المدفوعة)';
      }
    } catch (e) {
      // ignore
    } finally {
      if (mounted) setState(() => _isProcessingAudio = false);
    }
  }

  Future<void> _performTranslation() async {
    if (_sourceController.text.isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      final langService = Provider.of<LanguageService>(context, listen: false);
      
      // محاكاة الترجمة (في الإصدار الكامل سيتم استخدام API حقيقي)
      await Future.delayed(const Duration(milliseconds: 800 + Random().nextInt(700)));

      final sourceText = _sourceController.text;
      String translated;

      // محاكاة ذكية للترجمة حسب اللغة
      if (_targetLang == 'ar') {
        // ترجمة إلى العربية
        if (sourceText.contains('Hello') || sourceText.contains('hello')) {
          translated = 'مرحباً';
        } else if (sourceText.contains('Thank') || sourceText.contains('thank')) {
          translated = 'شكراً لك';
        } else if (sourceText.contains('Love') || sourceText.contains('love')) {
          translated = 'حب';
        } else if (sourceText.contains('Peace') || sourceText.contains('peace')) {
          translated = 'سلام';
        } else if (sourceText.contains('السلام عليكم')) {
          translated = 'Peace be upon you';
        } else if (sourceText.contains('بسم الله')) {
          translated = 'In the name of Allah';
        } else if (sourceText.contains('الحمد لله')) {
          translated = 'Praise be to Allah';
        } else {
          // ترجمة وهمية بناءً على طول النص
          final sampleTranslations = {
            'مرحباً': 'Hello',
            'شكراً': 'Thank you',
            'كيف حالك': 'How are you',
            'أهلاً وسهلاً': 'Welcome',
            'صباح الخير': 'Good morning',
            'مساء الخير': 'Good evening',
            'تصبح على خير': 'Good night',
            'Hello': 'مرحباً',
            'How are you': 'كيف حالك',
            'Good morning': 'صباح الخير',
            'Thank you': 'شكراً لك',
            'Welcome': 'أهلاً وسهلاً',
            'Good bye': 'إلى اللقاء',
            'I love you': 'أحبك',
            'Peace': 'سلام',
          };

          translated = sampleTranslations.entries.firstWhere(
            (e) => sourceText.toLowerCase().contains(e.key.toLowerCase()),
            orElse: () => MapEntry('', ''),
          ).value;

          if (translated.isEmpty) {
            if (_targetLang == 'en') {
              translated = 'Translation: $sourceText (English)';
            } else {
              translated = 'الترجمة: $sourceText';
            }
          }
        }
      } else {
        // ترجمة إلى لغات أخرى (محاكاة)
        translated = '[$_targetLang] $sourceText';
      }

      setState(() {
        _translatedController.text = translated;
        _isTranslating = false;
        _hasTranslated = true;
      });

      // حفظ الترجمة في السجل
      final db = Provider.of<DatabaseService>(context, listen: false);
      db.saveTranslation(sourceText, translated,
        sourceLang: _sourceLang, targetLang: _targetLang);

    } catch (e) {
      setState(() => _isTranslating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ خطأ في الترجمة: $e')),
        );
      }
    }
  }

  void _speakTranslation() {
    final tts = Provider.of<TTSService>(context, listen: false);
    if (_translatedController.text.isNotEmpty) {
      tts.speak(_translatedController.text);
    }
  }

  void _shareTranslation() {
    if (_translatedController.text.isEmpty) return;
    final shareText = '${_translatedController.text}\n\n— — — — — — — — — —\n🌐 تُرجم بواسطة ميرور سكربيون 🦂';
    Clipboard.setData(ClipboardData(text: shareText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ الترجمة مع توقيع التطبيق للمشاركة'),
        duration: Duration(seconds: 2)),
    );
  }

  void _copyTranslation() {
    if (_translatedController.text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _translatedController.text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ تم نسخ النص المترجم')),
      );
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

    return GestureDetector(
      onTap: () {
        if (_hasTranslated) {
          setState(() {
            _sourceController.clear();
            _translatedController.clear();
            _hasTranslated = false;
          });
        }
      },
      child: Scaffold(
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
              // زر اختيار اللغة (100+ لغة)
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
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: langCodes.contains(_sourceLang) ? _sourceLang : 'auto',
                          dropdownColor: const Color(0xFF0D1B2A),
                          style: const TextStyle(color: Colors.cyanAccent, fontSize: 13),
                          isExpanded: true,
                          items: langCodes.map((code) {
                            return DropdownMenuItem(
                              value: code,
                              child: Text(langService.getLanguageName(code) + 
                                (code == _sourceLang ? ' (مصدر)' : ''),
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _sourceLang = v);
                              _saveLanguages();
                            }
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward, color: Colors.white38, size: 18),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: langCodes.contains(_targetLang) ? _targetLang : 'en',
                          dropdownColor: const Color(0xFF0D1B2A),
                          style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
                          isExpanded: true,
                          items: langCodes.map((code) {
                            return DropdownMenuItem(
                              value: code,
                              child: Text(langService.getLanguageName(code) +
                                (code == _targetLang ? ' (هدف)' : ''),
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _targetLang = v);
                              _saveLanguages();
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // المحرر العلوي (النص المصدر)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: TextField(
                        controller: _sourceController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'اكتب النص هنا أو استخدم المايك...',
                          hintStyle: TextStyle(color: Colors.white24),
                        ),
                        onChanged: (_) {
                          setState(() => _hasTranslated = false);
                        },
                      ),
                    ),
                    // شريط الأدوات السفلي للمحرر العلوي
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          // 🎤 مايك
                          IconButton(
                            icon: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) {
                                return Icon(
                                  _isListening ? Icons.mic : Icons.mic_none,
                                  color: _isListening
                                    ? Color.lerp(Colors.redAccent, Colors.white, _pulseController.value)!
                                    : Colors.blueAccent,
                                  size: 28,
                                );
                              },
                            ),
                            onPressed: _startListening,
                            tooltip: 'التقاط الصوت',
                          ),
                          // 📌 AUDIO UPLOAD PIN - رفع ملف صوتي
                          PopupMenuButton<String>(
                            icon: _isProcessingAudio
                              ? const SizedBox(
                                  width: 22, height: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.cyanAccent))
                              : const Icon(Icons.push_pin, color: Colors.orangeAccent, size: 22),
                            tooltip: 'رفع ملف صوتي',
                            color: const Color(0xFF1B2838),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(color: Colors.orangeAccent.withOpacity(0.3)),
                            ),
                            onSelected: (value) {
                              if (value == 'file') _pickAudioFile();
                              if (value == 'social') _pickFromSocialMedia();
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'file',
                                child: ListTile(
                                  leading: Icon(Icons.audio_file, color: Colors.cyanAccent),
                                  title: Text('📂 ملف صوتي من الجهاز', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  subtitle: Text('mp3, wav, m4a...', style: TextStyle(color: Colors.white38, fontSize: 10)),
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'social',
                                child: ListTile(
                                  leading: Icon(Icons.share, color: Colors.greenAccent),
                                  title: Text('📤 من منصات التواصل', style: TextStyle(color: Colors.white, fontSize: 13)),
                                  subtitle: Text('واتساب, تلغرام, مسنجر...', style: TextStyle(color: Colors.white38, fontSize: 10)),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // زر الترجمة
                          if (_sourceController.text.isNotEmpty)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              child: ElevatedButton.icon(
                                onPressed: _isTranslating ? null : _performTranslation,
                                icon: _isTranslating
                                  ? const SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.translate, size: 18),
                                label: Text(_isTranslating ? 'جارٍ...' : 'ترجمة'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blueAccent,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // المحرر السفلي (نص الترجمة)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: TextField(
                        controller: _translatedController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 16, height: 1.5),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'الترجمة ستظهر هنا...',
                          hintStyle: TextStyle(color: Colors.white24),
                        ),
                        readOnly: true,
                      ),
                    ),
                    // شريط الأدوات السفلي للمحرر السفلي
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
                                size: 24),
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
                        ),
                      ),
                  ],
                ),
              ),
              
              // تلميح للمستخدم
              if (_hasTranslated)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '👆 اضغط على الشاشة أو الكيبورد/المايك لبدء ترجمة جديدة',
                    style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
