import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';

class DialogueTranslationScreen extends StatefulWidget {
  const DialogueTranslationScreen({super.key});

  @override
  State<DialogueTranslationScreen> createState() => _DialogueTranslationScreenState();
}

class _DialogueTranslationScreenState extends State<DialogueTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final FocusNode _sourceFocus = FocusNode();
  late stt.SpeechToText _speech;
  late AudioRecorder _audioRecorder;
  bool _isListening = false;
  bool _isTranslating = false;
  String _sourceLanguage = 'ar';
  String _targetLanguage = 'en';

  final List<Map<String, String>> _languages = [
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'en', 'name': 'English', 'flag': '🇬🇧'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'tr', 'name': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'fa', 'name': 'فارسی', 'flag': '🇮🇷'},
    {'code': 'ur', 'name': 'اردو', 'flag': '🇵🇰'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _audioRecorder = AudioRecorder();
    _loadSavedLanguages();
  }

  Future<void> _loadSavedLanguages() async {
    final lang = context.read<LanguageService>();
    final saved = await lang.getLastUsedLanguages();
    if (saved != null && mounted) {
      setState(() {
        _sourceLanguage = saved['source'] ?? 'ar';
        _targetLanguage = saved['target'] ?? 'en';
      });
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    _sourceFocus.dispose();
    _speech.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  String _getLocaleForLanguage(String code) {
    const locales = {
      'ar': 'ar_SA', 'en': 'en_US', 'fr': 'fr_FR', 'de': 'de_DE',
      'es': 'es_ES', 'tr': 'tr_TR', 'fa': 'fa_IR', 'ur': 'ur_PK',
    };
    return locales[code] ?? 'en_US';
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLanguage;
      _sourceLanguage = _targetLanguage;
      _targetLanguage = temp;
    });
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onError: (val) {
        setState(() => _isListening = false);
      },
      onStatus: (val) {
        if (val == 'done' || val == 'notListening') {
          setState(() => _isListening = false);
        }
      },
    );

    if (available) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (val) {
          setState(() {
            _sourceController.text = val.recognizedWords;
            _sourceController.selection = TextSelection.collapsed(
              offset: _sourceController.text.length,
            );
          });
          if (val.finalResult) {
            _translate();
          }
        },
        localeId: _getLocaleForLanguage(_sourceLanguage),
      );
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  Future<void> _translate() async {
    if (_sourceController.text.trim().isEmpty) return;

    setState(() => _isTranslating = true);

    await Future.delayed(const Duration(milliseconds: 800));
    final result = '🔤 [$sourceLanguage → $targetLanguage]: ${_sourceController.text}';

    setState(() {
      _targetController.text = result;
      _isTranslating = false;
    });

    final lang = context.read<LanguageService>();
    await lang.saveLastUsedLanguages(
      source: _sourceLanguage,
      target: _targetLanguage,
    );
  }

  void _clearAndStart() {
    setState(() {
      _sourceController.clear();
      _targetController.clear();
    });
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      if (result != null) {
        _showMessage('تم اختيار الملف: ${result.files.single.name}');
      }
    } catch (e) {
      _showMessage('خطأ: $e');
    }
  }

  Future<void> _speakTarget() async {
    if (_targetController.text.isEmpty) return;
    final tts = context.read<TTSService>();
    await tts.speak(_targetController.text, languageCode: _targetLanguage);
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFF1B2838),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLanguagePicker(bool isSource) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      builder: (context) {
        return SizedBox(
          height: 500,
          child: ListView.builder(
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final lang = _languages[index];
              return ListTile(
                leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                title: Text(lang['name']!, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() {
                    if (isSource) {
                      _sourceLanguage = lang['code']!;
                    } else {
                      _targetLanguage = lang['code']!;
                    }
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('💬 حوار مترجم', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── شريط اختيار اللغات: يمين (مصدر) | تبديل | يسار (هدف) | مايك ──
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.blueAccent),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // زر اللغة المصدر (يمين)
                Expanded(
                  child: _buildLanguageButton(
                    _sourceLanguage,
                    'من',
                    () => _showLanguagePicker(true),
                  ),
                ),
                // زر التبديل
                IconButton(
                  icon: const Icon(Icons.swap_horiz, color: Colors.blueAccent, size: 28),
                  onPressed: _swapLanguages,
                ),
                // زر اللغة الهدف (يسار)
                Expanded(
                  child: _buildLanguageButton(
                    _targetLanguage,
                    'إلى',
                    () => _showLanguagePicker(false),
                  ),
                ),
                // زر المايك
                Container(
                  decoration: BoxDecoration(
                    color: _isListening ? Colors.red : Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                    onPressed: _isListening ? _stopListening : _startListening,
                  ),
                ),
              ],
            ),
          ),
          // ── المحرر العلوي (مصدر) ──
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getLanguageName(_sourceLanguage)} (لغة المستخدم)',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _sourceController,
                      focusNode: _sourceFocus,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'تحدث أو اكتب هنا...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // ── المحرر السفلي (هدف) ──
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.cyanAccent.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'الترجمة (${_getLanguageName(_targetLanguage)})',
                        style: const TextStyle(color: Colors.cyanAccent, fontSize: 12),
                      ),
                      const Spacer(),
                      if (_isTranslating)
                        const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.cyanAccent,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: TextField(
                      controller: _targetController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'الترجمة...',
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  // أزرار المحرر السفلي
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.attach_file, color: Colors.cyanAccent),
                        tooltip: 'رفع ملف صوتي',
                        onPressed: _pickAudioFile,
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.cyanAccent, size: 26),
                        tooltip: 'نطق',
                        onPressed: _speakTarget,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String code, String label, VoidCallback onTap) {
    final lang = _languages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'code': code, 'name': code, 'flag': '🌐'},
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang['flag']!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
                  Text(
                    lang['name']!,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String code) {
    final lang = _languages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'code': code, 'name': code, 'flag': '🌐'},
    );
    return lang['name']!;
  }
}
