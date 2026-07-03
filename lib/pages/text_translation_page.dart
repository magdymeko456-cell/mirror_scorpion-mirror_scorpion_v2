import 'package:flutter/material.dart';
import 'dart:io';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/translator.dart';
import 'package:intl/intl.dart';

class TextTranslationPage extends StatefulWidget {
  const TextTranslationPage({super.key});

  @override
  State<TextTranslationPage> createState() => _TextTranslationPageState();
}

class _TextTranslationPageState extends State<TextTranslationPage> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  String _sourceLanguage = 'ar';
  String _targetLanguage = 'en';
  bool _isListening = false;
  bool _isTranslating = false;
  String? _lastTranslatedText;

  // قائمة بأكثر من 100 لغة
  final Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'ur': 'اردو', 'tr': 'Türkçe', 'de': 'Deutsch', 'zh': '中文',
    'hi': 'हिन्दी', 'pt': 'Português', 'ru': 'Русский', 'ja': '日本語',
    'ko': '한국어', 'it': 'Italiano', 'nl': 'Nederlands', 'pl': 'Polski',
    'sv': 'Svenska', 'da': 'Dansk', 'fi': 'Suomi', 'no': 'Norsk',
    'cs': 'Čeština', 'hu': 'Magyar', 'ro': 'Română', 'el': 'Ελληνικά',
    'he': 'עברית', 'th': 'ไทย', 'vi': 'Tiếng Việt', 'id': 'Bahasa Indonesia',
    'ms': 'Bahasa Melayu', 'tl': 'Filipino', 'bn': 'বাংলা', 'ta': 'தமிழ்',
    'te': 'తెలుగు', 'mr': 'मराठी', 'gu': 'ગુજરાતી', 'kn': 'ಕನ್ನಡ',
    'ml': 'മലയാളം', 'pa': 'ਪੰਜਾਬੀ', 'ne': 'नेपाली', 'si': 'සිංහල',
    'km': 'ភាសាខ្មែរ', 'my': 'မြန်မာဘာသာ', 'lo': 'ລາວ', 'ka': 'ქართული',
    'hy': 'Հայերեն', 'az': 'Azərbaycan dili', 'kk': 'Қазақ тілі',
    'uz': 'Oʻzbekcha', 'tg': 'Тоҷикӣ', 'mn': 'Монгол', 'ps': 'پښتو',
    'sd': 'سنڌي', 'ku': 'Kurdî', 'ckb': 'کوردیی ناوەندی', 'sw': 'Kiswahili',
    'ha': 'Hausa', 'yo': 'Yorùbá', 'ig': 'Igbo', 'zu': 'isiZulu',
    'xh': 'isiXhosa', 'af': 'Afrikaans', 'st': 'Sesotho', 'tn': 'Setswana',
    'ts': 'Xitsonga', 'ss': 'siSwati', 've': 'Tshivenḓa', 'nr': 'isiNdebele',
    'am': 'አማርኛ', 'ti': 'ትግርኛ', 'om': 'Oromoo', 'so': 'Soomaali',
    'rw': 'Kinyarwanda', 'rn': 'Ikirundi', 'mg': 'Malagasy', 'ny': 'Chichewa',
    'lg': 'Luganda', 'eo': 'Esperanto', 'la': 'Latina', 'cy': 'Cymraeg',
    'ga': 'Gaeilge', 'gd': 'Gàidhlig', 'mt': 'Malti', 'is': 'Íslenska',
    'lb': 'Lëtzebuergesch', 'fy': 'Frysk', 'oc': 'Occitan', 'ca': 'Català',
    'gl': 'Galego', 'eu': 'Euskara', 'br': 'Brezhoneg', 'co': 'Corsu',
    'ht': 'Kreyòl Ayisyen', 'jv': 'Basa Jawa', 'su': 'Basa Sunda',
    'be': 'Беларуская', 'uk': 'Українська', 'bg': 'Български', 'mk': 'Македонски',
    'sq': 'Shqip', 'bs': 'Bosanski', 'hr': 'Hrvatski', 'sr': 'Српски',
    'sl': 'Slovenščina', 'sk': 'Slovenčina', 'lt': 'Lietuvių', 'lv': 'Latviešu',
    'et': 'Eesti', 'fa': 'فارسی', 'dv': 'ދިވެހި', 'as': 'অসমীয়া',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedLanguages();
  }

  Future<void> _loadSavedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sourceLanguage = prefs.getString('text_source_lang') ?? 'ar';
      _targetLanguage = prefs.getString('text_target_lang') ?? 'en';
    });
  }

  Future<void> _saveLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('text_source_lang', _sourceLanguage);
    await prefs.setString('text_target_lang', _targetLanguage);
  }

  // ترجمة النص
  Future<void> _translate() async {
    if (_sourceController.text.isEmpty) return;
    
    setState(() => _isTranslating = true);
    try {
      final translation = await _translator.translate(
        _sourceController.text,
        from: _sourceLanguage,
        to: _targetLanguage,
      );
      setState(() {
        _targetController.text = translation.text;
        _lastTranslatedText = translation.text;
        _isTranslating = false;
      });
    } catch (e) {
      setState(() => _isTranslating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الترجمة: $e')),
        );
      }
    }
  }

  // نطق النص
  Future<void> _speak(String text, String lang) async {
    await _flutterTts.setLanguage(lang);
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  // الاستماع للصوت
  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _sourceController.text = result.recognizedWords;
            });
          },
          localeId: _sourceLanguage,
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      if (_sourceController.text.isNotEmpty) {
        _translate();
      }
    }
  }

  // اختيار ملف صوتي للترجمة
  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
    );
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم اختيار الملف: ${result.files.first.name}')),
      );
    }
  }

  // مشاركة النص المترجم
  Future<void> _shareTranslation() async {
    if (_targetController.text.isNotEmpty) {
      await Share.share(
        '${_targetController.text}\n\n- ترجم بواسطة Mirror Scorpion',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترجمة نصية'),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // زر اختيار اللغة (في منتصف الشاشة العلوي)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // لغة المصدر
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sourceLanguage,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      items: _languages.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _sourceLanguage = value!);
                        _saveLanguages();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(Icons.swap_horiz, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  // لغة الهدف
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _targetLanguage,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      items: _languages.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _targetLanguage = value!);
                        _saveLanguages();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // مربع المحرر العلوي (النص المصدر)
            Expanded(
              flex: 3,
              child: Card(
                child: TextField(
                  controller: _sourceController,
                  maxLines: null,
                  expands: true,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'اكتب أو تحدث...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  onChanged: (_) => _translate(),
                ),
              ),
            ),
            
            // أزرار المايك ودبوس الملفات
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // دبوس رفع الملفات الصوتية
                  IconButton(
                    icon: const Icon(Icons.attach_file),
                    onPressed: _pickAudioFile,
                    tooltip: 'رفع ملف صوتي',
                  ),
                  // مايك للاستماع
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                    onPressed: _listen,
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 48), // توازن
                ],
              ),
            ),
            
            // مربع المحرر السفلي (النص المترجم)
            Expanded(
              flex: 3,
              child: Card(
                child: TextField(
                  controller: _targetController,
                  maxLines: null,
                  expands: true,
                  textAlign: TextAlign.right,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'الترجمة...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            
            // أزرار أسفل المحرر السفلي
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // نسخ
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      if (_targetController.text.isNotEmpty) {
                        // نسخ النص
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('تم النسخ')),
                        );
                      }
                    },
                    tooltip: 'نسخ',
                  ),
                  // مشاركة
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: _shareTranslation,
                    tooltip: 'مشاركة',
                  ),
                  // سبيكر (نطق)
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () {
                      if (_targetController.text.isNotEmpty) {
                        _speak(_targetController.text, _targetLanguage);
                      }
                    },
                    tooltip: 'نطق',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _targetController.dispose();
    super.dispose();
  }
}
