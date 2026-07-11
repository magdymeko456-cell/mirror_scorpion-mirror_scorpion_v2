import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';
import '../../services/ai_service.dart';
import '../../core/widgets/shared_widgets.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final FocusNode _sourceFocus = FocusNode();
  final FocusNode _targetFocus = FocusNode();
  late stt.SpeechToText _speech;
  late AudioRecorder _audioRecorder;
  bool _isListening = false;
  bool _isTranslating = false;
  String _selectedLanguage = 'en';
  String _sourceLanguage = 'ar';
  bool _isRecording = false;
  String? _recordedFilePath;

  // قائمة 100 لغة
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
    {'code': 'hi', 'name': 'हिन्दी', 'flag': '🇮🇳'},
    {'code': 'id', 'name': 'Bahasa Indonesia', 'flag': '🇮🇩'},
    {'code': 'ms', 'name': 'Bahasa Melayu', 'flag': '🇲🇾'},
    {'code': 'th', 'name': 'ไทย', 'flag': '🇹🇭'},
    {'code': 'vi', 'name': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'code': 'nl', 'name': 'Nederlands', 'flag': '🇳🇱'},
    {'code': 'pl', 'name': 'Polski', 'flag': '🇵🇱'},
    {'code': 'sv', 'name': 'Svenska', 'flag': '🇸🇪'},
    {'code': 'no', 'name': 'Norsk', 'flag': '🇳🇴'},
    {'code': 'da', 'name': 'Dansk', 'flag': '🇩🇰'},
    {'code': 'fi', 'name': 'Suomi', 'flag': '🇫🇮'},
    {'code': 'el', 'name': 'Ελληνικά', 'flag': '🇬🇷'},
    {'code': 'cs', 'name': 'Čeština', 'flag': '🇨🇿'},
    {'code': 'hu', 'name': 'Magyar', 'flag': '🇭🇺'},
    {'code': 'ro', 'name': 'Română', 'flag': '🇷🇴'},
    {'code': 'bg', 'name': 'Български', 'flag': '🇧🇬'},
    {'code': 'uk', 'name': 'Українська', 'flag': '🇺🇦'},
    {'code': 'he', 'name': 'עברית', 'flag': '🇮🇱'},
    {'code': 'bn', 'name': 'বাংলা', 'flag': '🇧🇩'},
    {'code': 'ta', 'name': 'தமிழ்', 'flag': '🇮🇳'},
    {'code': 'te', 'name': 'తెలుగు', 'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'मराठी', 'flag': '🇮🇳'},
    {'code': 'gu', 'name': 'ગુજરાતી', 'flag': '🇮🇳'},
    {'code': 'kn', 'name': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
    {'code': 'ml', 'name': 'മലയാളം', 'flag': '🇮🇳'},
    {'code': 'pa', 'name': 'ਪੰਜਾਬੀ', 'flag': '🇮🇳'},
    {'code': 'sw', 'name': 'Kiswahili', 'flag': '🇰🇪'},
    {'code': 'af', 'name': 'Afrikaans', 'flag': '🇿🇦'},
    {'code': 'sq', 'name': 'Shqip', 'flag': '🇦🇱'},
    {'code': 'am', 'name': 'አማርኛ', 'flag': '🇪🇹'},
    {'code': 'az', 'name': 'Azərbaycan', 'flag': '🇦🇿'},
    {'code': 'be', 'name': 'Беларуская', 'flag': '🇧🇾'},
    {'code': 'bs', 'name': 'Bosanski', 'flag': '🇧🇦'},
    {'code': 'ca', 'name': 'Català', 'flag': '🇪🇸'},
    {'code': 'hr', 'name': 'Hrvatski', 'flag': '🇭🇷'},
    {'code': 'et', 'name': 'Eesti', 'flag': '🇪🇪'},
    {'code': 'eu', 'name': 'Euskara', 'flag': '🇪🇸'},
    {'code': 'gl', 'name': 'Galego', 'flag': '🇪🇸'},
    {'code': 'ka', 'name': 'ქართული', 'flag': '🇬🇪'},
    {'code': 'is', 'name': 'Íslenska', 'flag': '🇮🇸'},
    {'code': 'kk', 'name': 'Қазақ', 'flag': '🇰🇿'},
    {'code': 'km', 'name': 'ខ្មែរ', 'flag': '🇰🇭'},
    {'code': 'ky', 'name': 'Кыргыз', 'flag': '🇰🇬'},
    {'code': 'lo', 'name': 'ລາວ', 'flag': '🇱🇦'},
    {'code': 'lt', 'name': 'Lietuvių', 'flag': '🇱🇹'},
    {'code': 'lv', 'name': 'Latviešu', 'flag': '🇱🇻'},
    {'code': 'mk', 'name': 'Македонски', 'flag': '🇲🇰'},
    {'code': 'mn', 'name': 'Монгол', 'flag': '🇲🇳'},
    {'code': 'my', 'name': 'မြန်မာ', 'flag': '🇲🇲'},
    {'code': 'ne', 'name': 'नेपाली', 'flag': '🇳🇵'},
    {'code': 'si', 'name': 'සිංහල', 'flag': '🇱🇰'},
    {'code': 'sk', 'name': 'Slovenčina', 'flag': '🇸🇰'},
    {'code': 'sl', 'name': 'Slovenščina', 'flag': '🇸🇮'},
    {'code': 'sr', 'name': 'Српски', 'flag': '🇷🇸'},
    {'code': 'tg', 'name': 'Тоҷикӣ', 'flag': '🇹🇯'},
    {'code': 'tk', 'name': 'Türkmen', 'flag': '🇹🇲'},
    {'code': 'uz', 'name': 'Oʻzbek', 'flag': '🇺🇿'},
    {'code': 'yi', 'name': 'ייִדיש', 'flag': '🇮🇱'},
    {'code': 'yo', 'name': 'Yorùbá', 'flag': '🇳🇬'},
    {'code': 'zu', 'name': 'isiZulu', 'flag': '🇿🇦'},
    {'code': 'xh', 'name': 'isiXhosa', 'flag': '🇿🇦'},
    {'code': 'st', 'name': 'Sesotho', 'flag': '🇱🇸'},
    {'code': 'mg', 'name': 'Malagasy', 'flag': '🇲🇬'},
    {'code': 'haw', 'name': 'ʻŌlelo Hawaiʻi', 'flag': '🇺🇸'},
    {'code': 'sm', 'name': 'Gagana Sāmoa', 'flag': '🇼🇸'},
    {'code': 'mi', 'name': 'Māori', 'flag': '🇳🇿'},
    {'code': 'eo', 'name': 'Esperanto', 'flag': '🌍'},
    {'code': 'la', 'name': 'Latina', 'flag': '🏛️'},
    {'code': 'cy', 'name': 'Cymraeg', 'flag': '🏴'},
    {'code': 'ga', 'name': 'Gaeilge', 'flag': '🇮🇪'},
    {'code': 'lb', 'name': 'Lëtzebuergesch', 'flag': '🇱🇺'},
    {'code': 'jv', 'name': 'Basa Jawa', 'flag': '🇮🇩'},
    {'code': 'su', 'name': 'Basa Sunda', 'flag': '🇮🇩'},
    {'code': 'ceb', 'name': 'Cebuano', 'flag': '🇵🇭'},
    {'code': 'ht', 'name': 'Kreyòl Ayisyen', 'flag': '🇭🇹'},
    {'code': 'ku', 'name': 'Kurdî', 'flag': '🇮🇶'},
    {'code': 'ps', 'name': 'پښتو', 'flag': '🇦🇫'},
    {'code': 'sd', 'name': 'سنڌي', 'flag': '🇵🇰'},
    {'code': 'yi', 'name': 'ייִדיש', 'flag': '🇮🇱'},
    {'code': 'hy', 'name': 'Հայերեն', 'flag': '🇦🇲'},
    {'code': 'ba', 'name': 'Башҡорт', 'flag': '🇷🇺'},
    {'code': 'tt', 'name': 'Татар', 'flag': '🇷🇺'},
    {'code': 'sah', 'name': 'Саха тыла', 'flag': '🇷🇺'},
    {'code': 'cv', 'name': 'Чӑвашла', 'flag': '🇷🇺'},
    {'code': 'ce', 'name': 'Нохчийн', 'flag': '🇷🇺'},
    {'code': 'av', 'name': 'Авар', 'flag': '🇷🇺'},
    {'code': 'os', 'name': 'Ирон', 'flag': '🇷🇺'},
    {'code': 'krc', 'name': 'Къарачай-малкъар', 'flag': '🇷🇺'},
  ];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _audioRecorder = AudioRecorder();
    _sourceLanguage = 'ar';
    _selectedLanguage = 'en';
    _loadSavedLanguages();
  }

  Future<void> _loadSavedLanguages() async {
    final lang = context.read<LanguageService>();
    final saved = await lang.getLastUsedLanguages();
    if (saved != null && mounted) {
      setState(() {
        _sourceLanguage = saved['source'] ?? 'ar';
        _selectedLanguage = saved['target'] ?? 'en';
      });
    }
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    _sourceFocus.dispose();
    _targetFocus.dispose();
    _speech.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onError: (val) {
        setState(() => _isListening = false);
        _showMessage('خطأ في التعرف على الكلام: ${val.errorMsg}');
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
    } else {
      _showMessage('الميكروفون غير متاح');
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  String _getLocaleForLanguage(String code) {
    const locales = {
      'ar': 'ar_SA',
      'en': 'en_US',
      'fr': 'fr_FR',
      'de': 'de_DE',
      'es': 'es_ES',
      'tr': 'tr_TR',
      'fa': 'fa_IR',
      'ur': 'ur_PK',
    };
    return locales[code] ?? 'en_US';
  }

  Future<void> _translate() async {
    if (_sourceController.text.trim().isEmpty) return;

    setState(() => _isTranslating = true);

    try {
      // هنا نستخدم خدمة الترجمة (مكتبة http)
      // للتبسيط سنستخدم ترجمة تجريبية
      final result = await _performTranslation(
        _sourceController.text,
        _sourceLanguage,
        _selectedLanguage,
      );

      setState(() {
        _targetController.text = result;
        _isTranslating = false;
      });

      // حفظ اللغات
      final lang = context.read<LanguageService>();
      await lang.saveLastUsedLanguages(
        source: _sourceLanguage,
        target: _selectedLanguage,
      );
    } catch (e) {
      setState(() => _isTranslating = false);
      _showMessage('خطأ في الترجمة: $e');
    }
  }

  Future<String> _performTranslation(
    String text,
    String from,
    String to,
  ) async {
    // في الإصدار الكامل، يتم استدعاء MyMemory API
    // هنا نقدم تجربة وهمية لاختبار الواجهة
    await Future.delayed(const Duration(milliseconds: 800));
    return '🔤 [ترجمة $from → $to]: $text\n\n💡 للترجمة الفعلية، يتطلب التطبيق مفتاح API.';
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/mirror_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: path,
        );
        setState(() {
          _isRecording = true;
          _recordedFilePath = path;
        });
        _showMessage('بدأ التسجيل...');
      }
    } catch (e) {
      _showMessage('خطأ في التسجيل: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      setState(() => _isRecording = false);
      if (path != null) {
        _showMessage('تم حفظ التسجيل: $path');
      }
    } catch (e) {
      _showMessage('خطأ في إيقاف التسجيل: $e');
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
      );
      if (result != null) {
        final file = File(result.files.single.path!);
        _showMessage('تم اختيار الملف: ${file.path}');
        // في النسخة الكاملة: ترجمة الملف الصوتي
      }
    } catch (e) {
      _showMessage('خطأ في اختيار الملف: $e');
    }
  }

  Future<void> _speakTranslation() async {
    if (_targetController.text.isEmpty) return;
    final tts = context.read<TTSService>();
    await tts.speak(_targetController.text, languageCode: _selectedLanguage);
  }

  Future<void> _shareTranslation() async {
    if (_targetController.text.isEmpty) return;
    await Share.share(
      '🔤 ترجم هذا النص بواسطة Mirror Scorpion:\n\n${_targetController.text}',
      subject: 'ترجمة Mirror Scorpion',
    );
  }

  void _copyTranslation() {
    if (_targetController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _targetController.text));
    _showMessage('✅ تم نسخ الترجمة');
  }

  void _clearFields() {
    setState(() {
      _sourceController.clear();
      _targetController.clear();
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF1B2838),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showLanguagePicker(bool isSource) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    isSource ? 'اختر لغة المصدر' : 'اختر لغة الترجمة',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: _languages.length,
                    itemBuilder: (context, index) {
                      final lang = _languages[index];
                      return ListTile(
                        leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                        title: Text(
                          lang['name']!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          lang['code']!,
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        onTap: () {
                          setState(() {
                            if (isSource) {
                              _sourceLanguage = lang['code']!;
                            } else {
                              _selectedLanguage = lang['code']!;
                            }
                          });
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
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
        title: const Text('🌍 ترجمة نصية', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
            tooltip: 'إلهام',
            onPressed: () async {
              final inspiration = await AIService.generateInspiration(
                userMood: '',
                context: 'Translation',
              );
              _showMessage(inspiration);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            // ── زر اختيار اللغة في المنتصف العلوي ──
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.blueAccent),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLanguageChip(
                    _sourceLanguage,
                    () => _showLanguagePicker(true),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(Icons.arrow_forward, color: Colors.blueAccent),
                  ),
                  _buildLanguageChip(
                    _selectedLanguage,
                    () => _showLanguagePicker(false),
                  ),
                ],
              ),
            ),
            // ── محرر المصدر (العلوي) ──
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
                    Row(
                      children: [
                        const Icon(Icons.edit, color: Colors.white54, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'من: ${_getLanguageName(_sourceLanguage)}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
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
                          hintText: 'اكتب أو تحدث...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          // ترجمة فورية بعد توقف الكتابة
                        },
                        onSubmitted: (_) => _translate(),
                      ),
                    ),
                    // ── شريط الأزرار السفلي للمحرر العلوي ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.red : Colors.blueAccent,
                            size: 28,
                          ),
                          onPressed: _isListening ? _stopListening : _startListening,
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.keyboard, color: Colors.white70),
                          onPressed: () => _sourceFocus.requestFocus(),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: _clearFields,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // ── محرر الترجمة (السفلي) ──
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
                        const Icon(Icons.translate, color: Colors.cyanAccent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'إلى: ${_getLanguageName(_selectedLanguage)}',
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
                        focusNode: _targetFocus,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'الترجمة ستظهر هنا...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    // ── شريط الأزرار السفلي للمحرر السفلي ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // اسبيكر (نطق)
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.cyanAccent, size: 26),
                          tooltip: 'نطق الترجمة',
                          onPressed: _speakTranslation,
                        ),
                        // مشاركة
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.cyanAccent, size: 26),
                          tooltip: 'مشاركة',
                          onPressed: _shareTranslation,
                        ),
                        // رفع ملف صوتي
                        IconButton(
                          icon: Icon(
                            _isRecording ? Icons.stop_circle : Icons.attach_file,
                            color: _isRecording ? Colors.red : Colors.cyanAccent,
                            size: 26,
                          ),
                          tooltip: _isRecording ? 'إيقاف التسجيل' : 'رفع ملف صوتي',
                          onPressed: () {
                            if (_isRecording) {
                              _stopRecording();
                            } else {
                              _showFileOptions();
                            }
                          },
                        ),
                        // نسخ
                        IconButton(
                          icon: const Icon(Icons.content_copy, color: Colors.cyanAccent, size: 26),
                          tooltip: 'نسخ الترجمة',
                          onPressed: _copyTranslation,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageChip(String code, VoidCallback onTap) {
    final lang = _languages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'code': code, 'name': code, 'flag': '🌐'},
    );
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blueAccent.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(lang['flag']!, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              lang['name']!,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Icon(Icons.arrow_drop_down, color: Colors.white70),
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

  void _showFileOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'اختر مصدر الملف الصوتي',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.mic, color: Colors.red, size: 32),
              title: const Text('تسجيل من الميكروفون', style: TextStyle(color: Colors.white)),
              subtitle: const Text('سجل رسالة صوتية و ترجمها', style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                _startRecording();
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.folder, color: Colors.cyanAccent, size: 32),
              title: const Text('اختيار ملف من الجهاز', style: TextStyle(color: Colors.white)),
              subtitle: const Text('اختر ملف صوتي من المعرض أو الملفات', style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                _pickAudioFile();
              },
            ),
          ],
        ),
      ),
    );
  }
}
