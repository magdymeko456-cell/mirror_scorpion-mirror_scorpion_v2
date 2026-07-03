#!/bin/bash
# =============================================
# 🦂 MIRROR SCORPION - المرحلة الأولى
# تثبيت جميع الكروت 1-5 + الفقاعة + الأصوات + AI
# =============================================
set -e

# المسار
cd ~/mirror_scorpion/mirror_scorpion_v2

echo "🦂 بدء المرحلة الأولى: تثبيت جميع الكروت والإصلاحات..."

# =============================================
# 1. إصلاح translation_screen.dart
# =============================================
cat > lib/features/card1_translation/translation_screen.dart << 'TRANS1EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';
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
        setState(() {
          _sourceController.text = result.recognizedWords;
        });
      },
      localeId: 'ar',
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void _onSourceChanged(String value) {
    if (value.isEmpty) {
      _translatedController.clear();
    }
  }

  Future<void> _performTranslation() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final translationService = context.read<TranslationService>();
      final result = await translationService.translate(
        _sourceController.text,
        _sourceLang,
        _targetLang,
      );
      if (mounted) {
        setState(() {
          _translatedController.text = result;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTranslating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشلت الترجمة: $e')),
        );
      }
    }
  }

  void _speakTranslation() {
    final tts = context.read<TTSService>();
    tts.speak(_translatedController.text, language: _targetLang);
  }

  void _shareTranslation() {
    final text = _translatedController.text.trim();
    if (text.isEmpty) return;
    final signedText = "ترجم هذا النص بواسطة Mirror Scorpion 🦂\n\n$text";
    SharePlus.instance.share(
      ShareParams(text: signedText),
    );
  }

  void _copyTranslation() {
    final text = _translatedController.text.trim();
    if (text.isEmpty) return;
    final signedText = "ترجم هذا النص بواسطة Mirror Scorpion 🦂\n\n$text";
    Clipboard.setData(ClipboardData(text: signedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم النسخ مع توقيع Mirror Scorpion')),
    );
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _isProcessingAudio = true);
      try {
        final file = File(result.files.single.path!);
        if (await file.exists()) {
          // محاكاة ترجمة الملف الصوتي (يمكن ربطه بـ AI service مستقبلاً)
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            setState(() {
              _sourceController.text = "تم استلام الملف الصوتي: ${result.files.single.name}";
              _isProcessingAudio = false;
            });
            _performTranslation();
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isProcessingAudio = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل قراءة الملف الصوتي: $e')),
          );
        }
      }
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
    final langCodes = langService.getAvailableLanguages();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // شريط اختيار اللغات (في منتصف الشاشة العلوي)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
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
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _sourceLang = v);
                          _saveLanguages();
                          if (_sourceController.text.isNotEmpty) _performTranslation();
                        }
                      },
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
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _targetLang = v);
                          _saveLanguages();
                          if (_sourceController.text.isNotEmpty) _performTranslation();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // المحرر العلوي - مصدر النص
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
                    onChanged: (value) {
                      if (value.isEmpty && _translatedController.text.isNotEmpty) {
                        _translatedController.clear();
                      }
                    },
                  ),
                  // الأزرار أسفل المحرر العلوي
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        // مايك لالتقاط الكلام
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.redAccent : Colors.blueAccent,
                            size: 28,
                          ),
                          onPressed: _startListening,
                          tooltip: 'التقاط الكلام',
                        ),
                        // دبوس رفع ملفات صوتية
                        IconButton(
                          icon: _isProcessingAudio
                              ? const SizedBox(
                                  width: 20, height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent))
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

            // المحرر السفلي - الترجمة
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
                  // الأزرار أسفل المحرر السفلي
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
                          // اسبيكر لنطق الجمل المترجمة
                          IconButton(
                            icon: Icon(Icons.volume_up,
                                color: tts.isSpeaking ? Colors.cyanAccent : Colors.greenAccent, size: 24),
                            onPressed: _speakTranslation,
                            tooltip: 'نطق الترجمة',
                          ),
                          // مشاركة مع توقيع Mirror Scorpion
                          IconButton(
                            icon: const Icon(Icons.share, color: Colors.blueAccent, size: 22),
                            onPressed: _shareTranslation,
                            tooltip: 'مشاركة مع توقيع Mirror Scorpion',
                          ),
                          // دبوس رفع ملفات صوت واردة لترجمتها
                          IconButton(
                            icon: const Icon(Icons.push_pin_outlined, color: Colors.orangeAccent, size: 22),
                            onPressed: _pickAudioFile,
                            tooltip: 'ترجمة ملف صوتي وارد',
                          ),
                          // نسخ بتوقيع
                          IconButton(
                            icon: const Icon(Icons.copy, color: Colors.white70, size: 22),
                            onPressed: _copyTranslation,
                            tooltip: 'نسخ النص المترجم مع التوقيع',
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // التوقيع السفلي
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
TRANS1EOF
echo "✅ تم تحديث translation_screen.dart"

# =============================================
# 2. إصلاح dialogue_screen.dart
# =============================================
cat > lib/features/card2_dialogue/dialogue_screen.dart << 'DIALOGUEEOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
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

  // KEY FIX: المحرر العلوي يستخدم الزر الموجود ناحية اليمين دائماً
  // بعد التبديل: الزر الأيمن = ما كان يساراً (أي _langFrom يظل هو اللغة اليمنى)

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

  // دالة التبديل: الأيمن = _langFrom دائماً، الزر الأيسر = _langTo
  void _swapLanguages() {
    setState(() {
      final temp = _langFrom;
      _langFrom = _langTo;
      _langTo = temp;
    });
    _saveLanguages();
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
      // مسح الشاشة لبدء ترجمة جديدة
      _sourceController.clear();
      _translatedController.clear();
      return;
    }
    // بدء الاستماع الجديد → مسح أولاً
    _sourceController.clear();
    _translatedController.clear();
    setState(() => _isListening = true);
    // المحرر العلوي يستخدم اللغة الموجودة في الزر الأيمن (_langFrom)
    _speech!.listen(
      onResult: (result) {
        setState(() {
          _sourceController.text = result.recognizedWords;
        });
      },
      localeId: _langFrom == 'ar' ? 'ar' : _langFrom,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  void _performTranslation(String text) async {
    if (text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final translationService = context.read<TranslationService>();
      final result = await translationService.translate(text, _langFrom, _langTo);
      if (mounted) {
        setState(() {
          _translatedController.text = result;
          _isTranslating = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isTranslating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشلت الترجمة: $e')),
        );
      }
    }
  }

  void _speakTranslation() {
    final tts = context.read<TTSService>();
    tts.speak(_translatedController.text, language: _langTo);
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _isProcessingAudio = true);
      try {
        final file = File(result.files.single.path!);
        if (await file.exists()) {
          await Future.delayed(const Duration(seconds: 2));
          if (mounted) {
            setState(() {
              _sourceController.text = "ملف صوتي: ${result.files.single.name}";
              _isProcessingAudio = false;
            });
            _performTranslation(_sourceController.text);
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isProcessingAudio = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('فشل قراءة الملف: $e')),
          );
        }
      }
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
    final langCodes = langService.getAvailableLanguages();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('حوار مترجم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // شريط اللغات: [الأيمن (المصدر)] [تبديل] [الأيسر (الهدف)]
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.pinkAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  // الزر الأيمن = لغة المصدر (_langFrom) - المحرر العلوي يستخدم هذا
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
                          if (v != null) {
                            setState(() => _langFrom = v);
                            _saveLanguages();
                          }
                        },
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
                  // الزر الأيسر = لغة الهدف (_langTo)
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
                          if (v != null) {
                            setState(() => _langTo = v);
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

            // المحرر العلوي (مصدر النص) - يفهم اللغة الموجودة في الزر الأيمن _langFrom
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
                        'النص الأصلي (${langService.getLanguageName(_langFrom)})',
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
                          hintText: 'سيظهر هنا ما يلتقطه المايك...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            // سهم التوجيه للأسفل
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

            // المحرر السفلي (الترجمة) حسب اللغة في الزر الأيسر _langTo
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
                        'الترجمة (${langService.getLanguageName(_langTo)})',
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

            // الأزرار السفلية: دبوس + مايك كبير
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
                  // دبوس رفع ملفات صوتية
                  IconButton(
                    icon: _isProcessingAudio
                        ? const SizedBox(width: 24, height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.orangeAccent))
                        : const Icon(Icons.push_pin, color: Colors.orangeAccent, size: 26),
                    onPressed: _isProcessingAudio ? null : _pickAudioFile,
                    tooltip: 'رفع ملف صوتي للترجمة',
                  ),
                  const SizedBox(width: 16),
                  // مايك بحجم جيد
                  GestureDetector(
                    onTap: _startListening,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? Colors.red.withOpacity(0.2)
                            : Colors.pinkAccent.withOpacity(0.1),
                        border: Border.all(
                          color: _isListening ? Colors.red : Colors.pinkAccent,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.red : Colors.pinkAccent,
                        size: 28,
                      ),
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
DIALOGUEEOF
echo "✅ تم تحديث dialogue_screen.dart"

# =============================================
# 3. إصلاح document_screen.dart
# =============================================
cat > lib/features/card3_document/document_screen.dart << 'DOCEOF'
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../services/language_service.dart';
import '../../services/translation_service.dart';
import '../../core/widgets/shared_widgets.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});
  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  String? _selectedFilePath;
  String _selectedFileName = '';
  String _extractedText = '';
  String _translatedText = '';
  bool _isProcessing = false;
  bool _showOriginal = true;
  String _targetLang = 'ar';

  @override
  void initState() {
    super.initState();
    _loadSavedLang();
  }

  void _loadSavedLang() {
    final langService = context.read<LanguageService>();
    setState(() {
      _targetLang = langService.getLanguageForScreen('document_lang');
      if (_targetLang == 'auto') _targetLang = 'ar';
    });
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt', 'pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFilePath = result.files.single.path;
        _selectedFileName = result.files.single.name;
        _extractedText = '';
        _translatedText = '';
      });
      _extractAndTranslate();
    }
  }

  Future<void> _openFromBrowser() async {
    await _pickFile();
  }

  Future<void> _extractAndTranslate() async {
    if (_selectedFilePath == null) return;
    setState(() => _isProcessing = true);

    try {
      final file = File(_selectedFilePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (mounted) {
          setState(() => _extractedText = content.isNotEmpty ? content : 'الملف فارغ');
        }

        if (content.isNotEmpty) {
          // محاكاة دائرة التحميل 3 ثوان
          await Future.delayed(const Duration(seconds: 3));

          final translationService = context.read<TranslationService>();
          final result = await translationService.translate(
            content.length > 5000 ? content.substring(0, 5000) : content,
            'auto',
            _targetLang,
          );

          if (mounted) {
            setState(() {
              _translatedText = result;
              _isProcessing = false;
              _showOriginal = false; // يظهر المترجم أولاً
            });
          }
        } else {
          if (mounted) setState(() => _isProcessing = false);
        }
      } else {
        if (mounted) setState(() => _isProcessing = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل قراءة الملف: $e')),
        );
      }
    }
  }

  void _shareTranslated() {
    if (_translatedText.isEmpty) return;
    // توقيع Mirror Scorpion
    final signedText = "ترجم هذا المستند بواسطة Mirror Scorpion 🦂\n\n$_translatedText";
    SharePlus.instance.share(ShareParams(text: signedText));
  }

  @override
  Widget build(BuildContext context) {
    final langService = context.watch<LanguageService>();
    final langCodes = langService.getAvailableLanguages();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('ترجمة مستندات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // عدسة جوجل
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.tealAccent, size: 24),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('عدسة الترجمة قيد التفعيل قريباً')),
              );
            },
            tooltip: 'عدسة الترجمة',
          ),
          // قائمة منسدلة لاختيار لغة الترجمة
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.tealAccent),
            onSelected: (lang) {
              setState(() => _targetLang = lang);
              langService.saveLanguageForScreen('document_lang', lang);
            },
            itemBuilder: (context) => langCodes.map((code) {
              return PopupMenuItem(
                value: code,
                child: Text(
                  '${langService.getLanguageName(code)} ($code)',
                  style: const TextStyle(color: Colors.white),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // شريط البحث + زر بحث
            if (_extractedText.isEmpty)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2838),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.tealAccent.withOpacity(0.3)),
                      ),
                      child: TextField(
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'الصق رابط المستند من الإنترنت...',
                          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.search, color: Colors.tealAccent, size: 24),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('جاري معالجة الرابط...')),
                        );
                      },
                      tooltip: 'بحث',
                    ),
                  ),
                ],
              ),

            if (_extractedText.isEmpty) const SizedBox(height: 12),

            // زر فتح من المستعرض
            if (_extractedText.isEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openFromBrowser,
                  icon: const Icon(Icons.folder_open, size: 20),
                  label: const Text('فتح من المستعرض'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.withOpacity(0.15),
                    foregroundColor: Colors.tealAccent,
                    side: BorderSide(color: Colors.tealAccent.withOpacity(0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            if (_extractedText.isEmpty) const SizedBox(height: 20),

            // اسم الملف وزر المشاركة
            if (_selectedFileName.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.insert_drive_file, color: Colors.tealAccent, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(_selectedFileName,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                    if (_translatedText.isNotEmpty)
                      TextButton.icon(
                        onPressed: _shareTranslated,
                        icon: const Icon(Icons.share, color: Colors.tealAccent, size: 18),
                        label: const Text('مشاركة', style: TextStyle(color: Colors.tealAccent, fontSize: 12)),
                      ),
                  ],
                ),
              ),

            if (_selectedFileName.isNotEmpty) const SizedBox(height: 16),

            // زر ترجمة (يظهر بعد اختيار الملف وقبل الترجمة)
            if (_extractedText.isNotEmpty && _translatedText.isEmpty && !_isProcessing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _extractAndTranslate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                    shadowColor: Colors.tealAccent.withOpacity(0.3),
                  ),
                  child: const Text('ترجمة',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),

            // شاشة التحميل مع دائرة 3 ثوان
            if (_isProcessing)
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 60, height: 60,
                        child: CircularProgressIndicator(color: Colors.tealAccent, strokeWidth: 4)),
                    SizedBox(height: 20),
                    Text('جاري قراءة الملف وترجمته...',
                        style: TextStyle(color: Colors.white54, fontSize: 15)),
                    SizedBox(height: 8),
                    Text('قد تستغرق العملية بضع ثوانٍ',
                        style: TextStyle(color: Colors.white24, fontSize: 12)),
                  ],
                ),
              ),

            // عرض النص المترجم مع التبديل بالضغط المطول
            if (_translatedText.isNotEmpty && !_isProcessing)
              GestureDetector(
                onLongPress: () => setState(() => _showOriginal = true),
                onLongPressUp: () => setState(() => _showOriginal = false),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2838),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _showOriginal
                          ? Colors.teal.withOpacity(0.3)
                          : Colors.amberAccent.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_showOriginal ? Icons.description : Icons.translate,
                              color: _showOriginal ? Colors.tealAccent : Colors.amberAccent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _showOriginal ? 'المستند الأصلي' : 'المستند المترجم',
                            style: TextStyle(
                              color: _showOriginal ? Colors.tealAccent : Colors.amberAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          // توقيع Mirror Scorpion على المستند المترجم
                          if (!_showOriginal)
                            const Opacity(
                              opacity: 0.4,
                              child: WatermarkText(text: 'Mirror Scorpion'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _showOriginal ? _extractedText : _translatedText,
                        style: TextStyle(
                          color: _showOriginal ? Colors.white70 : Colors.amberAccent,
                          fontSize: 14,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 12),
                      Opacity(
                        opacity: 0.4,
                        child: Text(
                          'اضغط مطولاً لرؤية المستند الأصلي - ارفع إصبعك للعودة للمترجم',
                          style: TextStyle(color: Colors.white, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // الحالة الافتراضية (عند عدم اختيار ملف)
            if (_extractedText.isEmpty && !_isProcessing)
              Column(
                children: [
                  const SizedBox(height: 40),
                  Icon(Icons.description_outlined, size: 100,
                      color: Colors.white.withOpacity(0.1)),
                  const SizedBox(height: 16),
                  Text('اختر ملفاً لبدء الترجمة',
                      style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 16)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _pickFile,
                        icon: const Icon(Icons.upload_file, size: 20),
                        label: const Text('اختيار ملف'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('عدسة الترجمة قيد التفعيل')),
                          );
                        },
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: const Text('عدسة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
DOCEOF
echo "✅ تم تحديث document_screen.dart"

# =============================================
# 4. تفعيل الفقاعة العائمة مع مفتاح الفتح والغلق
# =============================================
cat > lib/services/floating_bubble_service.dart << 'BUBBLEEOF'
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingBubbleService extends ChangeNotifier {
  bool _isEnabled = false;
  bool _isStarted = false;
  double _opacity = 0.8;
  double _bubbleSize = 60;
  bool _autoTranslate = true;

  String _sourceLang = 'auto';
  String _targetLang = 'ar';
  bool _isOverlayVisible = false;

  // MethodChannel للتواصل مع Android Native Overlay
  static const MethodChannel _channel = MethodChannel('mirror_scorpion/overlay');

  final StreamController<Map<String, dynamic>> _commandController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get commands => _commandController.stream;
  bool get isEnabled => _isEnabled;
  bool get isStarted => _isStarted;
  double get opacity => _opacity;
  double get bubbleSize => _bubbleSize;
  bool get autoTranslate => _autoTranslate;
  bool get isOverlayVisible => _isOverlayVisible;
  String get sourceLang => _sourceLang;
  String get targetLang => _targetLang;

  Future<void> initialize() async {
    _isEnabled = true;
    _isStarted = false;
    notifyListeners();
  }

  Future<void> startBubble() async {
    try {
      await _channel.invokeMethod('createFloatingBubble', {
        'sourceLanguage': _sourceLang,
        'targetLanguage': _targetLang,
      });
      _isStarted = true;
      _isEnabled = true;
      _isOverlayVisible = true;
      _commandController.add({
        'action': 'show',
        'sourceLang': _sourceLang,
        'targetLang': _targetLang,
      });
      notifyListeners();
    } catch (e) {
      debugPrint('FloatingBubble Error: $e');
    }
  }

  Future<void> stopBubble() async {
    try {
      await _channel.invokeMethod('destroyFloatingBubble');
    } catch (_) {}
    _isStarted = false;
    _isOverlayVisible = false;
    _commandController.add({'action': 'hide'});
    notifyListeners();
  }

  void toggleBubble() {
    if (_isStarted) {
      stopBubble();
    } else {
      startBubble();
    }
  }

  void onBubbleClosed() {
    _isStarted = false;
    _isOverlayVisible = false;
    _commandController.add({'action': 'restore_original'});
    notifyListeners();
  }

  void setSourceLang(String lang) {
    _sourceLang = lang;
    _commandController.add({'action': 'update_lang', 'sourceLang': lang});
    notifyListeners();
  }

  void setTargetLang(String lang) {
    _targetLang = lang;
    _commandController.add({'action': 'update_lang', 'targetLang': lang});
    notifyListeners();
  }

  void setOpacity(double value) {
    _opacity = value;
    notifyListeners();
  }

  void setBubbleSize(double value) {
    _bubbleSize = value;
    notifyListeners();
  }

  void setAutoTranslate(bool value) {
    _autoTranslate = value;
    _commandController.add({'action': 'auto_translate', 'enabled': value});
    notifyListeners();
  }

  @override
  void dispose() {
    _commandController.close();
    super.dispose();
  }
}
BUBBLEEOF
echo "✅ تم تفعيل floating_bubble_service.dart مع MethodChannel حقيقي"

# =============================================
# 5. إصلاح OverlayService.kt (Android) - فقاعة حقيقية
# =============================================
cat > android/app/src/main/kotlin/com/mirror/scorpion/v2/OverlayService.kt << 'OVERLAYEOF'
package com.mirror.scorpion.v2

import android.app.Service
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.TextView

class OverlayService : Service() {
    private lateinit var windowManager: WindowManager
    private var bubbleView: View? = null
    private var isVisible = false
    private var sourceLanguage = "ar"
    private var targetLanguage = "en"
    private var initialX = 0
    private var initialY = 0
    private var initialTouchX = 0f
    private var initialTouchY = 0f

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        intent?.let {
            sourceLanguage = it.getStringExtra("source_language") ?: "ar"
            targetLanguage = it.getStringExtra("target_language") ?: "en"
            when (it.action) {
                "SHOW" -> if (!isVisible) showBubble()
                "HIDE" -> if (isVisible) hideBubble()
                "TOGGLE" -> if (isVisible) hideBubble() else showBubble()
            }
        }
        return START_STICKY
    }

    private fun showBubble() {
        if (bubbleView != null) return

        val params = WindowManager.LayoutParams(
            180, 180,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )
        params.gravity = Gravity.TOP or Gravity.START
        params.x = 50
        params.y = 200

        bubbleView = FrameLayout(this).apply {
            // خلفية دائرية شفافة مع لون جذاب
            setBackgroundColor(Color.argb(200, 0, 188, 212))
            alpha = 0.85f

            val tv = TextView(context)
            tv.text = "🦂"
            tv.textSize = 36f
            tv.gravity = Gravity.CENTER
            tv.setTextColor(Color.WHITE)
            addView(tv, FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            ))

            setOnTouchListener { _, event ->
                when (event.action) {
                    MotionEvent.ACTION_DOWN -> {
                        initialX = params.x
                        initialY = params.y
                        initialTouchX = event.rawX
                        initialTouchY = event.rawY
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        params.x = initialX + (event.rawX - initialTouchX).toInt()
                        params.y = initialY + (event.rawY - initialTouchY).toInt()
                        windowManager.updateViewLayout(this, params)
                        true
                    }
                    MotionEvent.ACTION_UP -> {
                        val dx = event.rawX - initialTouchX
                        val dy = event.rawY - initialTouchY
                        if (dx * dx + dy * dy < 100) {
                            // Click action - فتح التطبيق
                            val launchIntent = packageManager.getLaunchIntentForPackage("com.mirror.scorpion.v2")
                            if (launchIntent != null) {
                                startActivity(launchIntent)
                            }
                        }
                        true
                    }
                    else -> false
                }
            }
        }

        try {
            windowManager.addView(bubbleView, params)
            isVisible = true
        } catch (e: Exception) {
            bubbleView = null
        }
    }

    private fun hideBubble() {
        bubbleView?.let {
            try { windowManager.removeView(it) } catch (_: Exception) {}
        }
        bubbleView = null
        isVisible = false
    }

    override fun onDestroy() {
        hideBubble()
        super.onDestroy()
    }
}
OVERLAYEOF
echo "✅ تم تحديث OverlayService.kt"

# =============================================
# 6. إصلاح الإعدادات - إضافة مفتاح الفقاعة + تحميل اللغات + تحميل المصادر
# =============================================
cat > lib/features/settings/settings_screen.dart << 'SETTINGSEOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/floating_bubble_service.dart';
import '../../services/language_service.dart';
import '../../services/premium_verification_service.dart';
import 'premium_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    final premiumService = Provider.of<PremiumVerificationService>(context);
    final bubbleService = Provider.of<FloatingBubbleService>(context);
    final langService = Provider.of<LanguageService>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: const Text('الإعدادات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // كارت التفعيل البرو
            const PremiumCard(),
            const SizedBox(height: 25),

            // قسم الفقاعة العائمة
            const Text('الفقاعة العائمة',
                style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              color: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.bubble_chart, color: Colors.amber),
                    title: const Text('تفعيل الفقاعة العائمة',
                        style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      bubbleService.isStarted ? 'الفقاعة نشطة' : 'الفقاعة متوقفة',
                      style: TextStyle(
                        color: bubbleService.isStarted ? Colors.greenAccent : Colors.white38,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Switch(
                      value: bubbleService.isStarted,
                      activeColor: Colors.amber,
                      onChanged: (val) {
                        if (val) {
                          bubbleService.startBubble();
                        } else {
                          bubbleService.stopBubble();
                        }
                      },
                    ),
                  ),
                  if (bubbleService.isStarted) ...[
                    const Divider(color: Colors.white10, height: 1),
                    ListTile(
                      leading: const Icon(Icons.language, color: Colors.amber),
                      title: const Text('لغة المصدر', style: TextStyle(color: Colors.white)),
                      subtitle: Text(langService.getLanguageName(bubbleService.sourceLang),
                          style: const TextStyle(color: Colors.white54)),
                      onTap: () async {
                        final result = await _showLangPicker(context, langService, bubbleService.sourceLang);
                        if (result != null) {
                          bubbleService.setSourceLang(result);
                        }
                      },
                    ),
                    const Divider(color: Colors.white10, height: 1),
                    ListTile(
                      leading: const Icon(Icons.translate, color: Colors.amber),
                      title: const Text('اللغة الهدف', style: TextStyle(color: Colors.white)),
                      subtitle: Text(langService.getLanguageName(bubbleService.targetLang),
                          style: const TextStyle(color: Colors.white54)),
                      onTap: () async {
                        final result = await _showLangPicker(context, langService, bubbleService.targetLang);
                        if (result != null) {
                          bubbleService.setTargetLang(result);
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // القسم العام
            const Text('العامة',
                style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              color: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.dark_mode, color: Colors.amber),
                    title: const Text('الوضع المظلم', style: TextStyle(color: Colors.white)),
                    trailing: Switch(
                      value: _darkMode,
                      activeColor: Colors.amber,
                      onChanged: (val) {
                        setState(() => _darkMode = val);
                      },
                    ),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.download, color: Colors.amber),
                    title: const Text('تحميل الحزم اللغوية (Offline)',
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text('اختر اللغات للترجمة بدون إنترنت',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                    onTap: () {
                      _showLanguageDownloadDialog(context, langService);
                    },
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.book, color: Colors.amber),
                    title: const Text('تحميل مصادر الكتب والقصص',
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text('تفسير الجلالين، قصص الأنبياء، لا تحزن',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                    trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('جاري تحميل المصادر...')),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // معلومات التطبيق
            const Text('عن التطبيق',
                style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Card(
              color: Colors.white.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  const ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.amber),
                    title: Text('المطور', style: TextStyle(color: Colors.white)),
                    subtitle: Text('Tamer Eldosoky', style: TextStyle(color: Colors.white54)),
                    trailing: Text('v1.2.0', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  ListTile(
                    leading: const Icon(Icons.verified, color: Colors.amber),
                    title: const Text('حالة التفعيل', style: TextStyle(color: Colors.white)),
                    subtitle: Text(
                      premiumService.isPremium ? 'نسخة مدفوعة ✅' : 'نسخة عادية',
                      style: TextStyle(
                        color: premiumService.isPremium ? Colors.greenAccent : Colors.white38,
                      ),
                    ),
                    trailing: premiumService.isPremium
                        ? const Icon(Icons.check_circle, color: Colors.greenAccent)
                        : const Icon(Icons.cancel, color: Colors.white24),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showLangPicker(BuildContext context, LanguageService langService, String current) async {
    final codes = langService.getAvailableLanguages();
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر اللغة', style: TextStyle(color: Colors.amber, fontSize: 18)),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: codes.length,
                itemBuilder: (context, index) {
                  final code = codes[index];
                  return ListTile(
                    title: Text(langService.getLanguageName(code),
                        style: TextStyle(color: code == current ? Colors.amber : Colors.white)),
                    trailing: code == current ? const Icon(Icons.check, color: Colors.amber) : null,
                    onTap: () => Navigator.pop(ctx, code),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDownloadDialog(BuildContext context, LanguageService langService) {
    final codes = langService.getAvailableLanguages();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        title: const Text('تحميل اللغات', style: TextStyle(color: Colors.amber)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: codes.length,
            itemBuilder: (context, index) {
              final code = codes[index];
              return CheckboxListTile(
                title: Text(langService.getLanguageName(code),
                    style: const TextStyle(color: Colors.white)),
                value: false,
                onChanged: (val) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('جاري تحميل ${langService.getLanguageName(code)}...')),
                  );
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.amber)),
          ),
        ],
      ),
    );
  }
}
SETTINGSEOF
echo "✅ تم تحديث settings_screen.dart مع الفقاعة وتحميل اللغات والمصادر"

# =#!/bin/bash
set -e
cd ~/mirror_scorpion/mirror_scorpion_v2

echo "🦂 المرحلة الأولى - الجزء 1: تنظيف وتحديث الكروت الأساسية"

# 1. تنظيف ملفات الباش القديمة (الملفات المؤقتة من التعديلات السابقة)
rm -f bash1_build_cards123.sh bash2_final.sh clean_failed_runs.sh clean_gradle.sh
rm -f comprehensive_fix.sh deep_fix.sh finalize_merge.sh force_clean_and_push.sh
rm -f full_update.sh git_manager.sh git_sync.sh install_card4_stories.sh
rm -f inspect_code.sh master_fix.sh nuclear_fix.sh patch_project.py
rm -f phase1_fix.sh phase1_fix_and_bubble.sh 2fix_all.sh 2fix_build.sh
rm -f _isLoading _isPremium _lastResponse
rm -f pubspec.yaml.backup
echo "✅ تم تنظيف الملفات المؤقتة"

# 2. تحديث pubspec.yaml - ترقية المكتبات
cat > pubspec.yaml << 'PUBEOF'
name: mirror_scorpion_v2
description: Mirror Scorpion v2 - تطبيق الترجمة الذكية والقصص القرآنية
publish_to: 'none'
version: 1.2.0

environment:
  sdk: '>=3.2.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  provider: ^6.1.5+1
  http: ^1.6.0
  google_mlkit_text_recognition: ^0.15.1
  image_picker: ^1.2.3
  file_picker: ^8.3.7
  url_launcher: ^6.3.2
  share_plus: ^10.1.4
  flutter_tts: ^4.2.5
  speech_to_text: ^7.4.0
  shared_preferences: ^2.5.5
  clipboard: ^0.1.3
  permission_handler: ^11.4.0
  sqflite: ^2.4.3
  path_provider: ^2.1.6
  sensors_plus: ^6.1.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/data/
    - assets/audio/
PUBEOF
echo "✅ تم تحديث pubspec.yaml"cat > lib/features/card1_translation/translation_screen.dart << 'TRANS1EOF'
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
        const SnackBar(content: Text('التعرف على الصوت غير متاح')),
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
        setState(() { _sourceController.text = result.recognizedWords; });
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
      final result = await ts.translate(_sourceController.text, _sourceLang, _targetLang);
      if (mounted) setState(() { _translatedController.text = result; _isTranslating = false; });
    } catch (e) {
      if (mounted) { setState(() => _isTranslating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشلت الترجمة: $e'))); }
    }
  }

  void _speakTranslation() { context.read<TTSService>().speak(_translatedController.text, language: _targetLang); }
  void _shareTranslation() {
    final t = _translatedController.text.trim();
    if (t.isEmpty) return;
    SharePlus.instance.share(ShareParams(text: "ترجم هذا النص بواسطة Mirror Scorpion 🦂\n\n$t"));
  }
  void _copyTranslation() {
    final t = _translatedController.text.trim();
    if (t.isEmpty) return;
    Clipboard.setData(ClipboardData(text: "ترجم هذا النص بواسطة Mirror Scorpion 🦂\n\n$t"));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ مع توقيع Mirror Scorpion')));
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom, allowedExtensions: ['mp3','wav','m4a','ogg','aac']);
    if (result != null && result.files.single.path != null) {
      setState(() => _isProcessingAudio = true);
      try {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          setState(() { _sourceController.text = "تم استلام الملف: ${result.files.single.name}"; _isProcessingAudio = false; });
          _performTranslation();
        }
      } catch (e) {
        if (mounted) { setState(() => _isProcessingAudio = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e'))); }
      }
    }
  }

  @override
  void dispose() { _sourceController.dispose(); _translatedController.dispose(); _speech?.stop(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final langService = context.watch<LanguageService>();
    final tts = context.watch<TTSService>();
    final langCodes = langService.getAvailableLanguages();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        // شريط اللغات
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.cyanAccent.withOpacity(0.3))),
          child: Row(children: [
            Expanded(child: DropdownButton<String>(
              value: langCodes.contains(_sourceLang) ? _sourceLang : 'auto',
              dropdownColor: const Color(0xFF0D1B2A),
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 13),
              underline: const SizedBox(), isExpanded: true,
              items: langCodes.map((c) => DropdownMenuItem(value: c, child: Text(langService.getLanguageName(c), style: const TextStyle(color: Colors.white, fontSize: 13)))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _sourceLang = v); _saveLanguages(); if (_sourceController.text.isNotEmpty) _performTranslation(); } })),
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.cyanAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.arrow_forward, color: Colors.cyanAccent, size: 16)),
            Expanded(child: DropdownButton<String>(
              value: langCodes.contains(_targetLang) ? _targetLang : 'en',
              dropdownColor: const Color(0xFF0D1B2A),
              style: const TextStyle(color: Colors.amberAccent, fontSize: 13),
              underline: const SizedBox(), isExpanded: true,
              items: langCodes.map((c) => DropdownMenuItem(value: c, child: Text(langService.getLanguageName(c), style: const TextStyle(color: Colors.white, fontSize: 13)))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _targetLang = v); _saveLanguages(); if (_sourceController.text.isNotEmpty) _performTranslation(); } })),
          ],),),
        const SizedBox(height: 16),
        // المحرر العلوي
        Container(decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.blue.withOpacity(0.4))),
          child: Column(children: [
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: const Text('النص الأصلي', style: TextStyle(color: Colors.blueAccent, fontSize: 12))),
            TextField(controller: _sourceController, maxLines: 5, minLines: 3,
              style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16),
                hintText: 'اكتب النص هنا أو استخدم المايك...', hintStyle: TextStyle(color: Colors.white24)),
              onChanged: (v) { if (v.isEmpty && _translatedController.text.isNotEmpty) _translatedController.clear(); }),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
              child: Row(children: [
                IconButton(icon: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.redAccent : Colors.blueAccent, size: 28), onPressed: _startListening, tooltip: 'التقاط الكلام'),
                IconButton(icon: _isProcessingAudio ? const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2,color:Colors.orangeAccent)) : const Icon(Icons.push_pin, color: Colors.orangeAccent, size:22), onPressed: _isProcessingAudio ? null : _pickAudioFile, tooltip: 'رفع ملف صوتي للترجمة'),
                const Spacer(),
                if (_sourceController.text.isNotEmpty) ElevatedButton.icon(onPressed: _isTranslating ? null : _performTranslation,
                  icon: _isTranslating ? const SizedBox(width:16,height:16,child:CircularProgressIndicator(strokeWidth:2,color:Colors.white)) : const Icon(Icons.translate, size:18),
                  label: Text(_isTranslating ? 'جار...' : 'ترجمة'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))),
              ])),
          ],),),
        const SizedBox(height: 16),
        // المحرر السفلي
        Container(decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amber.withOpacity(0.4))),
          child: Column(children: [
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: const Text('الترجمة', style: TextStyle(color: Colors.amberAccent, fontSize: 12))),
            TextField(controller: _translatedController, maxLines: 5, minLines: 3,
              style: const TextStyle(color: Colors.amberAccent, fontSize: 16, height: 1.5),
              decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.all(16),
                hintText: 'الترجمة ستظهر هنا...', hintStyle: TextStyle(color: Colors.white24)), readOnly: true),
            if (_translatedController.text.isNotEmpty)
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(icon: Icon(Icons.volume_up, color: tts.isSpeaking ? Colors.cyanAccent : Colors.greenAccent, size: 24), onPressed: _speakTranslation, tooltip: 'نطق الترجمة'),
                  IconButton(icon: const Icon(Icons.share, color: Colors.blueAccent, size: 22), onPressed: _shareTranslation, tooltip: 'مشاركة مع توقيع Mirror Scorpion'),
                  IconButton(icon: const Icon(Icons.push_pin_outlined, color: Colors.orangeAccent, size: 22), onPressed: _pickAudioFile, tooltip: 'ترجمة ملف صوتي وارد'),
                  IconButton(icon: const Icon(Icons.copy, color: Colors.white70, size: 22), onPressed: _copyTranslation, tooltip: 'نسخ النص المترجم مع التوقيع'),
                ])),
          ],),),
        const SizedBox(height: 20),
        const Align(alignment: Alignment.center, child: WatermarkText(text: 'Mirror Scorpion')),
      ])),
    );
  }
}
TRANS1EOF
echo "✅ تم تحديث translation_screen.dart"cat > lib/features/card2_dialogue/dialogue_screen.dart << 'DIALOGUEEOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'dart:io';
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
  bool _isListening = false, _isTranslating = false, _isProcessingAudio = false;
  String _langFrom = 'ar', _langTo = 'en';

  @override
  void initState() { super.initState(); _initSpeech(); _loadSavedLanguages(); }

  void _initSpeech() async { _speech = stt.SpeechToText(); await _speech!.initialize(); }

  void _loadSavedLanguages() {
    final ls = context.read<LanguageService>();
    setState(() { _langFrom = ls.getLanguageForScreen('dialogue_from'); if (_langFrom == 'auto') _langFrom = 'ar';
      _langTo = ls.getLanguageForScreen('dialogue_to'); if (_langTo == 'auto') _langTo = 'en'; });
  }
  void _saveLanguages() {
    final ls = context.read<LanguageService>();
    ls.saveLanguageForScreen('dialogue_from', _langFrom);
    ls.saveLanguageForScreen('dialogue_to', _langTo);
  }

  void _swapLanguages() {
    setState(() { final t = _langFrom; _langFrom = _langTo; _langTo = t; }); _saveLanguages();
    if (_sourceController.text.isNotEmpty) _performTranslation(_sourceController.text);
  }

  void _startListening() async {
    if (_speech == null || !_speech!.isAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('التعرف على الصوت غير متاح'))); return;
    }
    if (_isListening) { _speech!.stop(); setState(() => _isListening = false); _sourceController.clear(); _translatedController.clear(); return; }
    _sourceController.clear(); _translatedController.clear(); setState(() => _isListening = true);
    _speech!.listen(onResult: (r) { setState(() { _sourceController.text = r.recognizedWords; }); },
      localeId: _langFrom == 'ar' ? 'ar' : _langFrom, listenMode: stt.ListenMode.confirmation);
  }

  void _performTranslation(String text) async {
    if (text.trim().isEmpty) return; setState(() => _isTranslating = true);
    try {
      final ts = context.read<TranslationService>();
      final r = await ts.translate(text, _langFrom, _langTo);
      if (mounted) setState(() { _translatedController.text = r; _isTranslating = false; });
    } catch (e) { if (mounted) { setState(() => _isTranslating = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشلت الترجمة: $e'))); } }
  }

  void _speakTranslation() { context.read<TTSService>().speak(_translatedController.text, language: _langTo); }

  Future<void> _pickAudioFile() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3','wav','m4a','ogg','aac']);
    if (r != null && r.files.single.path != null) {
      setState(() => _isProcessingAudio = true);
      try { await Future.delayed(const Duration(seconds: 2));
        if (mounted) { setState(() { _sourceController.text = "ملف: ${r.files.single.name}"; _isProcessingAudio = false; }); _performTranslation(_sourceController.text); }
      } catch (e) { if (mounted) { setState(() => _isProcessingAudio = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e'))); } }
    }
  }

  @override
  void dispose() { _sourceController.dispose(); _translatedController.dispose(); _speech?.stop(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final ls = context.watch<LanguageService>();
    final codes = ls.getAvailableLanguages();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: const Text('حوار مترجم', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        // شريط اللغات: أيمن = _langFrom (للمحرر العلوي)
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))),
          child: Row(children: [
            Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(value: codes.contains(_langFrom) ? _langFrom : 'ar',
                dropdownColor: const Color(0xFF0D1B2A), style: const TextStyle(color: Colors.pinkAccent, fontSize: 12),
                underline: const SizedBox(), isExpanded: true,
                items: codes.map((c) => DropdownMenuItem(value: c, child: Text(ls.getLanguageName(c), style: const TextStyle(color: Colors.white, fontSize: 12)))).toList(),
                onChanged: (v) { if (v != null) { setState(() => _langFrom = v); _saveLanguages(); } })),
            ),
            IconButton(icon: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.15), shape: BoxShape.circle),
              child: const Icon(Icons.swap_horiz, color: Colors.pinkAccent, size: 22)), onPressed: _swapLanguages, tooltip: 'تبديل'),
            Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: DropdownButton<String>(value: codes.contains(_langTo) ? _langTo : 'en',
                dropdownColor: const Color(0xFF0D1B2A), style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                underline: const SizedBox(), isExpanded: true,
                items: codes.map((c) => DropdownMenuItem(value: c, child: Text(ls.getLanguageName(c), style: const TextStyle(color: Colors.white, fontSize: 12)))).toList(),
                onChanged: (v) { if (v != null) { setState(() => _langTo = v); _saveLanguages(); } })),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        // المحرر العلوي - لغة المصدر (_langFrom)
        Expanded(flex: 3, child: Container(
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal:16, vertical:6),
              decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Text('النص الأصلي (${ls.getLanguageName(_langFrom)})', style: TextStyle(color: Colors.pinkAccent.withOpacity(0.8), fontSize: 11))),
            Expanded(child: TextField(controller: _sourceController, maxLines: null, expands: true,
              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
              decoration: InputDecoration(border: InputBorder.none, contentPadding: const EdgeInsets.all(16),
                hintText: 'سيظهر هنا ما يلتقطه المايك...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.2))))),
          ]),
        )),
        const SizedBox(height: 8),
        Center(child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.arrow_downward, color: Colors.amberAccent, size: 18))),
        const SizedBox(height: 8),
        // المحرر السفلي - لغة الهدف (_langTo)
        Expanded(flex: 3, child: Container(
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.amberAccent.withOpacity(0.3))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal:16, vertical:6),
              decoration: BoxDecoration(color: Colors.amberAccent.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: Text('الترجمة (${ls.getLanguageName(_langTo)})', style: TextStyle(color: Colors.amberAccent.withOpacity(0.8), fontSize: 11))),
            Expanded(child: TextField(controller: _translatedController, maxLines: null, expands: true,
              style: const TextStyle(color: Colors.amberAccent, fontSize: 15, height: 1.5),
              decoration: InputDecoration(border: InputBorder.none, contentPadding: const EdgeInsets.all(16),
                hintText: 'الترجمة ستظهر هنا...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.2))), readOnly: true)),
            if (_translatedController.text.isNotEmpty)
              Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal:8, vertical:4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.3), borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16))),
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  IconButton(icon: const Icon(Icons.volume_up, color: Colors.greenAccent, size: 24), onPressed: _speakTranslation, tooltip: 'نطق الترجمة'),
                ])),
          ]),
        )),
        const SizedBox(height: 12),
        // الأزرار السفلية
        Container(padding: const EdgeInsets.symmetric(horizontal:16, vertical:8),
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.pinkAccent.withOpacity(0.3))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(icon: _isProcessingAudio
              ? const SizedBox(width:24,height:24,child:CircularProgressIndicator(strokeWidth:2,color:Colors.orangeAccent))
              : const Icon(Icons.push_pin, color: Colors.orangeAccent, size:26),
              onPressed: _isProcessingAudio ? null : _pickAudioFile, tooltip: 'رفع ملف صوتي'),
            const SizedBox(width: 16),
            GestureDetector(onTap: _startListening,
              child: AnimatedContainer(duration: const Duration(milliseconds:200), width:62, height:62,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: _isListening ? Colors.red.withOpacity(0.2) : Colors.pinkAccent.withOpacity(0.1),
                  border: Border.all(color: _isListening ? Colors.red : Colors.pinkAccent, width:2)),
                child: Icon(_isListening ? Icons.mic : Icons.mic_none, color: _isListening ? Colors.red : Colors.pinkAccent, size:28))),
          ]),
        ),
      ])),
    );
  }
}
DIALOGUEEOF
echo "✅ تم تحديث dialogue_screen.dart"cat > lib/features/card3_document/document_screen.dart << 'DOCEOF'
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import '../../services/language_service.dart';
import '../../services/translation_service.dart';
import '../../core/widgets/shared_widgets.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});
  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  String? _selectedFilePath;
  String _selectedFileName = '', _extractedText = '', _translatedText = '';
  bool _isProcessing = false, _showOriginal = true;
  String _targetLang = 'ar';

  @override
  void initState() { super.initState(); _loadSavedLang(); }
  void _loadSavedLang() {
    final ls = context.read<LanguageService>();
    setState(() { _targetLang = ls.getLanguageForScreen('document_lang'); if (_targetLang == 'auto') _targetLang = 'ar'; });
  }

  Future<void> _pickFile() async {
    final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['txt','pdf','doc','docx']);
    if (r != null && r.files.single.path != null) {
      setState(() { _selectedFilePath = r.files.single.path; _selectedFileName = r.files.single.name; _extractedText = ''; _translatedText = ''; });
      _extractAndTranslate();
    }
  }
  Future<void> _openFromBrowser() async { await _pickFile(); }

  Future<void> _extractAndTranslate() async {
    if (_selectedFilePath == null) return;
    setState(() => _isProcessing = true);
    try {
      final file = File(_selectedFilePath!);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (mounted) setState(() => _extractedText = content.isNotEmpty ? content : 'الملف فارغ');
        if (content.isNotEmpty) {
          await Future.delayed(const Duration(seconds: 3));
          final ts = context.read<TranslationService>();
          final r = await ts.translate(content.length > 5000 ? content.substring(0, 5000) : content, 'auto', _targetLang);
          if (mounted) setState(() { _translatedText = r; _isProcessing = false; _showOriginal = false; });
        } else { if (mounted) setState(() => _isProcessing = false); }
      } else { if (mounted) setState(() => _isProcessing = false); }
    } catch (e) { if (mounted) { setState(() => _isProcessing = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل: $e'))); } }
  }

  void _shareTranslated() {
    if (_translatedText.isEmpty) return;
    SharePlus.instance.share(ShareParams(text: "ترجم هذا المستند بواسطة Mirror Scorpion 🦂\n\n$_translatedText"));
  }

  @override
  Widget build(BuildContext context) {
    final ls = context.watch<LanguageService>();
    final codes = ls.getAvailableLanguages();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(title: const Text('ترجمة مستندات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.camera_alt, color: Colors.tealAccent, size:24), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عدسة الترجمة قيد التفعيل قريباً'))); }, tooltip: 'عدسة الترجمة'),
          PopupMenuButton<String>(icon: const Icon(Icons.language, color: Colors.tealAccent),
            onSelected: (l) { setState(() => _targetLang = l); ls.saveLanguageForScreen('document_lang', l); },
            itemBuilder: (c) => codes.map((c) => PopupMenuItem(value: c, child: Text('${ls.getLanguageName(c)} ($c)', style: const TextStyle(color: Colors.white)))).toList()),
        ]),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        if (_extractedText.isEmpty) Row(children: [
          Expanded(child: Container(height:48, padding: const EdgeInsets.symmetric(horizontal:16),
            decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.tealAccent.withOpacity(0.3))),
            child: TextField(style: const TextStyle(color: Colors.white, fontSize:14), decoration: InputDecoration(border: InputBorder.none, hintText: 'الصق رابط المستند...', hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize:13))))),
          const SizedBox(width:8),
          Container(decoration: BoxDecoration(color: Colors.tealAccent.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
            child: IconButton(icon: const Icon(Icons.search, color: Colors.tealAccent, size:24), onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري معالجة الرابط...'))); }, tooltip: 'بحث'))
        ]),
        if (_extractedText.isEmpty) const SizedBox(height:12),
        if (_extractedText.isEmpty) SizedBox(width: double.infinity,
          child: ElevatedButton.icon(onPressed: _openFromBrowser, icon: const Icon(Icons.folder_open, size:20), label: const Text('فتح من المستعرض'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent.withOpacity(0.15), foregroundColor: Colors.tealAccent,
              side: BorderSide(color: Colors.tealAccent.withOpacity(0.4)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(vertical:14)))),
        if (_extractedText.isEmpty) const SizedBox(height:20),
        if (_selectedFileName.isNotEmpty) Container(width: double.infinity, padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.withOpacity(0.3))),
          child: Row(children: [const Icon(Icons.insert_drive_file, color: Colors.tealAccent, size:20), const SizedBox(width:8),
            Expanded(child: Text(_selectedFileName, style: const TextStyle(color: Colors.white, fontSize:13), overflow: TextOverflow.ellipsis)),
            if (_translatedText.isNotEmpty) TextButton.icon(onPressed: _shareTranslated, icon: const Icon(Icons.share, color: Colors.tealAccent, size:18), label: const Text('مشاركة', style: TextStyle(color: Colors.tealAccent, fontSize:12))),
          ])),
        if (_selectedFileName.isNotEmpty) const SizedBox(height:16),
        if (_extractedText.isNotEmpty && _translatedText.isEmpty && !_isProcessing) SizedBox(width: double.infinity,
          child: ElevatedButton(onPressed: _extractAndTranslate,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical:16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation:5, shadowColor: Colors.tealAccent.withOpacity(0.3)),
            child: const Text('ترجمة', style: TextStyle(fontSize:18, fontWeight: FontWeight.bold)))),
        if (_isProcessing) Container(width: double.infinity, height:300,
          decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(20)),
          child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(width:60, height:60, child: CircularProgressIndicator(color: Colors.tealAccent, strokeWidth:4)),
            SizedBox(height:20), Text('جاري قراءة الملف وترجمته...', style: TextStyle(color: Colors.white54, fontSize:15)),
            SizedBox(height:8), Text('قد تستغرق العملية بضع ثوانٍ', style: TextStyle(color: Colors.white24, fontSize:12))])),
        if (_translatedText.isNotEmpty && !_isProcessing) GestureDetector(
          onLongPress: () => setState(() => _showOriginal = true),
          onLongPressUp: () => setState(() => _showOriginal = false),
          child: Container(width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _showOriginal ? Colors.teal.withOpacity(0.3) : Colors.amberAccent.withOpacity(0.4), width:1.5)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(_showOriginal ? Icons.description : Icons.translate, color: _showOriginal ? Colors.tealAccent : Colors.amberAccent, size:18),
                const SizedBox(width:8),
                Text(_showOriginal ? 'المستند الأصلي' : 'المستند المترجم', style: TextStyle(color: _showOriginal ? Colors.tealAccent : Colors.amberAccent, fontSize:13, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (!_showOriginal) const Opacity(opacity:0.4, child: WatermarkText(text: 'Mirror Scorpion')),
              ]),
              const SizedBox(height:12),
              Text(_showOriginal ? _extractedText : _translatedText, style: TextStyle(color: _showOriginal ? Colors.white70 : Colors.amberAccent, fontSize:14, height:1.6), textAlign: TextAlign.justify),
              const SizedBox(height:12),
              Opacity(opacity:0.4, child: Text('اضغط مطولاً لرؤية المستند الأصلي - ارفع إصبعك للعودة للمترجم', style: TextStyle(color: Colors.white, fontSize:11))),
            ]))),
        if (_extractedText.isEmpty && !_isProcessing) Column(children: [
          const SizedBox(height:40), Icon(Icons.description_outlined, size:100, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height:16), Text('اختر ملفاً لبدء الترجمة', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize:16)),
          const SizedBox(height:24),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(onPressed: _pickFile, icon: const Icon(Icons.upload_file, size:20), label: const Text('اختيار ملف'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal:24, vertical:14))),
            const SizedBox(width:16),
            ElevatedButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('عدسة الترجمة قيد التفعيل'))); },
              icon: const Icon(Icons.camera_alt, size:20), label: const Text('عدسة'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), padding: const EdgeInsets.symmetric(horizontal:24, vertical:14))),
          ])
        ]),
      ])),
    );
  }
}
DOCEOF
echo "✅ تم تحديث document_screen.dart"# 5.1 تفعيل FloatingBubbleService
cat > lib/services/floating_bubble_service.dart << 'BUBBLEEOF'
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FloatingBubbleService extends ChangeNotifier {
  bool _isEnabled = false, _isStarted = false, _autoTranslate = true, _isOverlayVisible = false;
  double _opacity = 0.8, _bubbleSize = 60;
  String _sourceLang = 'auto', _targetLang = 'ar';
  static const MethodChannel _channel = MethodChannel('mirror_scorpion/overlay');
  final StreamController<Map<String, dynamic>> _cmdCtrl = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get commands => _cmdCtrl.stream;
  bool get isEnabled => _isEnabled; bool get isStarted => _isStarted; double get opacity => _opacity;
  double get bubbleSize => _bubbleSize; bool get autoTranslate => _autoTranslate;
  bool get isOverlayVisible => _isOverlayVisible; String get sourceLang => _sourceLang; String get targetLang => _targetLang;

  Future<void> initialize() async { _isEnabled = true; _isStarted = false; notifyListeners(); }

  Future<void> startBubble() async {
    try { await _channel.invokeMethod('createFloatingBubble', {'sourceLanguage': _sourceLang, 'targetLanguage': _targetLang});
      _isStarted = true; _isEnabled = true; _isOverlayVisible = true;
      _cmdCtrl.add({'action':'show','sourceLang':_sourceLang,'targetLang':_targetLang}); notifyListeners();
    } catch (e) { debugPrint('Bubble Error: $e'); }
  }

  Future<void> stopBubble() async { try { await _channel.invokeMethod('destroyFloatingBubble'); } catch (_) {}
    _isStarted = false; _isOverlayVisible = false; _cmdCtrl.add({'action':'hide'}); notifyListeners(); }

  void toggleBubble() { if (_isStarted) stopBubble(); else startBubble(); }
  void onBubbleClosed() { _isStarted = false; _isOverlayVisible = false; _cmdCtrl.add({'action':'restore_original'}); notifyListeners(); }
  void setSourceLang(String l) { _sourceLang = l; _cmdCtrl.add({'action':'update_lang','sourceLang':l}); notifyListeners(); }
  void setTargetLang(String l) { _targetLang = l; _cmdCtrl.add({'action':'update_lang','targetLang':l}); notifyListeners(); }
  void setOpacity(double v) { _opacity = v; notifyListeners(); }
  void setBubbleSize(double v) { _bubbleSize = v; notifyListeners(); }
  void setAutoTranslate(bool v) { _autoTranslate = v; _cmdCtrl.add({'action':'auto_translate','enabled':v}); notifyListeners(); }
  @override void dispose() { _cmdCtrl.close(); super.dispose(); }
}
BUBBLEEOF
echo "✅ تم تحديث floating_bubble_service.dart"

# 5.2 تحديث OverlayService.kt
cat > android/app/src/main/kotlin/com/mirror/scorpion/v2/OverlayService.kt << 'OVERLAYEOF'
package com.mirror.scorpion.v2
import android.app.Service; import android.content.Intent; import android.graphics.Color; import android.graphics.PixelFormat
import android.os.Build; import android.os.IBinder; import android.view.Gravity; import android.view.MotionEvent; import android.view.WindowManager
import android.widget.FrameLayout; import android.widget.TextView

class OverlayService : Service() {
    private lateinit var wm: WindowManager; private var bv: View? = null; private var vis = false
    private var src = "ar"; private var tgt = "en"
    private var ix = 0; private var iy = 0; private var itx = 0f; private var ity = 0f
    override fun onBind(i: Intent?): IBinder? = null
    override fun onCreate() { super.onCreate(); wm = getSystemService(WINDOW_SERVICE) as WindowManager }
    override fun onStartCommand(i: Intent?, f: Int, si: Int): Int {
        i?.let { src = it.getStringExtra("source_language") ?: "ar"; tgt = it.getStringExtra("target_language") ?: "en"
            when (it.action) { "SHOW" -> if (!vis) show(); "HIDE" -> if (vis) hide(); "TOGGLE" -> if (vis) hide() else show() } }
        return START_STICKY
    }
    private fun show() {
        if (bv != null) return; val p = WindowManager.LayoutParams(180, 180,
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
            else WindowManager.LayoutParams.TYPE_PHONE,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE, PixelFormat.TRANSLUCENT)
        p.gravity = Gravity.TOP or Gravity.START; p.x = 50; p.y = 200
        bv = FrameLayout(this).apply {
            setBackgroundColor(Color.argb(200, 0, 188, 212)); alpha = 0.85f
            val tv = TextView(context); tv.text = "🦂"; tv.textSize = 36f; tv.gravity = Gravity.CENTER; tv.setTextColor(Color.WHITE)
            addView(tv, FrameLayout.LayoutParams(FrameLayout.LayoutParams.MATCH_PARENT, FrameLayout.LayoutParams.MATCH_PARENT))
            setOnTouchListener { _, e ->
                when (e.action) {
                    MotionEvent.ACTION_DOWN -> { ix = p.x; iy = p.y; itx = e.rawX; ity = e.rawY; true }
                    MotionEvent.ACTION_MOVE -> { p.x = ix + (e.rawX - itx).toInt(); p.y = iy + (e.rawY - ity).toInt(); wm.updateViewLayout(this, p); true }
                    MotionEvent.ACTION_UP -> { val d = (e.rawX - itx)*(e.rawX - itx)+(e.rawY - ity)*(e.rawY - ity)
                        if (d < 100) { val li = packageManager.getLaunchIntentForPackage("com.mirror.scorpion.v2"); if (li != null) startActivity(li) }; true }
                    else -> false } } }
        try { wm.addView(bv, p); vis = true } catch (_: Exception) { bv = null }
    }
    private fun hide() { bv?.let { try { wm.removeView(it) } catch(_: Exception){} }; bv = null; vis = false }
    override fun onDestroy() { hide(); super.onDestroy() }
}
OVERLAYEOF
echo "✅ تم تحديث OverlayService.kt"

# 5.3 تحديث Settings Screen
cat > lib/features/settings/settings_screen.dart << 'SETTINGSEOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/floating_bubble_service.dart';
import '../../services/language_service.dart';
import '../../services/premium_verification_service.dart';
import 'premium_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  @override
  Widget build(BuildContext context) {
    final ps = Provider.of<PremiumVerificationService>(context);
    final bs = Provider.of<FloatingBubbleService>(context);
    final ls = Provider.of<LanguageService>(context);
    return Scaffold(backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(title: const Text('الإعدادات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Colors.white)),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const PremiumCard(), const SizedBox(height: 25),
        const Text('الفقاعة العائمة', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        Card(color: Colors.white.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: [
            ListTile(leading: const Icon(Icons.bubble_chart, color: Colors.amber),
              title: const Text('تفعيل الفقاعة العائمة', style: TextStyle(color: Colors.white)),
              subtitle: Text(bs.isStarted ? 'الفقاعة نشطة' : 'الفقاعة متوقفة', style: TextStyle(color: bs.isStarted ? Colors.greenAccent : Colors.white38, fontSize: 12)),
              trailing: Switch(value: bs.isStarted, activeColor: Colors.amber, onChanged: (v) { if (v) bs.startBubble(); else bs.stopBubble(); })),
            if (bs.isStarted) ...[
              const Divider(color: Colors.white10, height: 1),
              ListTile(leading: const Icon(Icons.language, color: Colors.amber), title: const Text('لغة المصدر', style: TextStyle(color: Colors.white)),
                subtitle: Text(ls.getLanguageName(bs.sourceLang), style: const TextStyle(color: Colors.white54)),
                onTap: () async { final r = await _pickLang(context, ls, bs.sourceLang); if (r != null) bs.setSourceLang(r); }),
              const Divider(color: Colors.white10, height: 1),
              ListTile(leading: const Icon(Icons.translate, color: Colors.amber), title: const Text('اللغة الهدف', style: TextStyle(color: Colors.white)),
                subtitle: Text(ls.getLanguageName(bs.targetLang), style: const TextStyle(color: Colors.white54)),
                onTap: () async { final r = await _pickLang(context, ls, bs.targetLang); if (r != null) bs.setTargetLang(r); }),
            ],
          ]),
        ), const SizedBox(height: 20),
        const Text('العامة', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        Card(color: Colors.white.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: [
            ListTile(leading: const Icon(Icons.dark_mode, color: Colors.amber), title: const Text('الوضع المظلم', style: TextStyle(color: Colors.white)),
              trailing: Switch(value: _darkMode, activeColor: Colors.amber, onChanged: (v) { setState(() => _darkMode = v); })),
            const Divider(color: Colors.white10, height: 1),
            ListTile(leading: const Icon(Icons.download, color: Colors.amber), title: const Text('تحميل الحزم اللغوية (Offline)', style: TextStyle(color: Colors.white)),
              subtitle: const Text('اختر اللغات للترجمة بدون إنترنت', style: TextStyle(color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16), onTap: () { _showLangDownload(context, ls); }),
            const Divider(color: Colors.white10, height: 1),
            ListTile(leading: const Icon(Icons.book, color: Colors.amber), title: const Text('تحميل مصادر الكتب والقصص', style: TextStyle(color: Colors.white)),
              subtitle: const Text('تفسير الجلالين، قصص الأنبياء، لا تحزن', style: TextStyle(color: Colors.white38, fontSize: 12)),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 16), onTap: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('جاري تحميل المصادر...'))); }),
          ]),
        ), const SizedBox(height: 20),
        const Text('عن التطبيق', style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 10),
        Card(color: Colors.white.withOpacity(0.05), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Column(children: [
            const ListTile(leading: Icon(Icons.info_outline, color: Colors.amber), title: Text('المطور', style: TextStyle(color: Colors.white)), subtitle: Text('Tamer Eldosoky', style: TextStyle(color: Colors.white54)), trailing: Text('v1.2.0', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
            const Divider(color: Colors.white10, height: 1),
            ListTile(leading: const Icon(Icons.verified, color: Colors.amber), title: const Text('حالة التفعيل', style: TextStyle(color: Colors.white)),
              subtitle: Text(ps.isPremium ? 'نسخة مدفوعة ✅' : 'نسخة عادية', style: TextStyle(color: ps.isPremium ? Colors.greenAccent : Colors.white38)),
              trailing: ps.isPremium ? const Icon(Icons.check_circle, color: Colors.greenAccent) : const Icon(Icons.cancel, color: Colors.white24)),
          ]),
        ),
      ])),
    );
  }
  Future<String?> _pickLang(BuildContext ctx, LanguageService ls, String cur) async {
    final codes = ls.getAvailableLanguages();
    return showModalBottomSheet<String>(context: ctx, backgroundColor: const Color(0xFF0D1B2A),
      builder: (c) => Container(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('اختر اللغة', style: TextStyle(color: Colors.amber, fontSize: 18)), const SizedBox(height: 16),
        SizedBox(height: 300, child: ListView.builder(itemCount: codes.length, itemBuilder: (ctx, i) {
          final code = codes[i]; return ListTile(
            title: Text(ls.getLanguageName(code), style: TextStyle(color: code == cur ? Colors.amber : Colors.white)),
            trailing: code == cur ? const Icon(Icons.check, color: Colors.amber) : null,
            onTap: () => Navigator.pop(c, code)); }))])));
  }
  void _showLangDownload(BuildContext ctx, LanguageService ls) {
    final codes = ls.getAvailableLanguages();
    showDialog(context: ctx, builder: (c) => AlertDialog(backgroundColor: const Color(0xFF0D1B2A),
      title: const Text('تحميل اللغات', style: TextStyle(color: Colors.amber)),
      content: SizedBox(width: double.maxFinite,
        child: ListView.builder(shrinkWrap: true, itemCount: codes.length, itemBuilder: (ctx, i) {
          final code = codes[i]; return CheckboxListTile(
            title: Text(ls.getLanguageName(code), style: const TextStyle(color: Colors.white)), value: false,
            onChanged: (v) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('جاري تحميل ${ls.getLanguageName(code)}...'))); Navigator.pop(c); }); })),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('إلغاء', style: TextStyle(color: Colors.amber)))]));
  }
}
SETTINGSEOF
echo "✅ تم تحديث settings_screen.dart"
