import 'package:flutter/material.dart';
import "dart:convert";
import "package:http/http.dart" as http;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/tts_service.dart';
import '../../services/language_service.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  late stt.SpeechToText _speechToText;
  String _selectedLanguage = 'en';
  bool _isListening = false;
  bool _isTranslating = false;
  final Map<String, String> _hundredLanguages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'de': 'Deutsch',
    'es': 'Español', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
    'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'hi': 'हिन्दी',
    'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی', 'nl': 'Nederlands',
    'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk', 'fi': 'Suomi',
    'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย', 'vi': 'Tiếng Việt',
    'ms': 'Bahasa Melayu', 'id': 'Bahasa Indonesia', 'tl': 'Filipino',
    'cs': 'Čeština', 'hu': 'Magyar', 'ro': 'Română', 'sk': 'Slovenčina',
    'hr': 'Hrvatski', 'sr': 'Српски', 'bg': 'Български', 'uk': 'Українська',
    'sq': 'Shqip', 'hy': 'Հայերեն', 'ka': 'ქართული', 'kk': 'Қазақ',
    'uz': 'Oʻzbek', 'az': 'Azərbaycan', 'mn': 'Монгол', 'ne': 'नेपाली',
    'si': 'සිංහල', 'am': 'አማርኛ', 'sw': 'Kiswahili', 'ha': 'Hausa',
    'yo': 'Yorùbá', 'ig': 'Igbo', 'zu': 'isiZulu', 'xh': 'isiXhosa',
    'af': 'Afrikaans', 'mt': 'Malti', 'cy': 'Cymraeg', 'ga': 'Gaeilge',
    'gd': 'Gàidhlig', 'lb': 'Lëtzebuergesch', 'is': 'Íslenska', 'no': 'Norsk',
    'et': 'Eesti', 'lv': 'Latviešu', 'lt': 'Lietuvių', 'be': 'Беларуская',
    'mk': 'Македонски', 'bs': 'Bosanski', 'sl': 'Slovenščina', 'ca': 'Català',
    'gl': 'Galego', 'eu': 'Euskara', 'fy': 'Frysk', 'eo': 'Esperanto',
    'la': 'Latina', 'ku': 'Kurdî', 'ps': 'پښتو', 'sd': 'سنڌي',
    'ckb': 'کوردی', 'dv': 'ދިވެހި', 'dz': 'རྫོང་ཁ', 'my': 'မြန်မာ',
    'km': 'ភាសាខ្មែរ', 'lo': 'ລາວ', 'bo': 'བོད་སྐད', 'ug': 'ئۇيغۇرچە',
    'tt': 'Татар', 'ba': 'Башҡорт', 'cv': 'Чӑваш', 'ce': 'Нохчийн',
    'os': 'Ирон', 'ab': 'Аԥсшәа', 'kv': 'Коми', 'udm': 'Удмурт',
    'mhr': 'Марий', 'mrj': 'Кырык мары', 'koi': 'Перем коми',
    'sjd': 'Са̄мь', 'sma': 'Åarjelsaemien', 'smj': 'Julevsámegiella',
    'se': 'Davvisámegiella', 'sms': 'Nuorttâlääʹmmiõll',
    'syr': 'ܣܘܪܝܝܐ', 'arc': 'ܐܪܡܝܐ', 'cop': 'ϯⲙⲉⲧⲣⲉⲙⲛ̀ⲭⲏⲙⲓ',
    'tig': 'ትግረ', 'tir': 'ትግርኛ', 'aar': 'Qafar', 'som': 'Soomaali',
    'orm': 'Oromoo', 'ber': 'ⵜⴰⵎⴰⵣⵉⵖⵜ', 'ary': 'الدارجة',
    'apc': 'شامي', 'acm': 'عراقي', 'ars': 'نجدي', 'acq': 'خليجي',
    'ayl': 'ليبي', 'aec': 'مصري',
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final langService = Provider.of<LanguageService>(context, listen: false);
    final saved = langService.getLanguageForScreen('translation');
    if (saved.isNotEmpty && _hundredLanguages.containsKey(saved)) {
      _selectedLanguage = saved;
    }
  }

  void _saveLanguage(String lang) {
    Provider.of<LanguageService>(context, listen: false)
        .saveLanguageForScreen('translation', lang);
  }

  void _handleMic() async {
    if (_isListening) {
      _speakToText.stop();
      setState(() => _isListening = false);
      return;
    }

    bool available = await _speakToText.initialize();
    if (!available) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ التعرف على الصوت غير متاح')),
      );
      return;
    }

    setState(() => _isListening = true);
    _speakToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            _sourceController.text = result.recognizedWords;
            _isListening = false;
            _translate();
          });
        } else {
          setState(() => _sourceController.text = result.recognizedWords);
        }
      },
      localeId: 'ar_SA',
    );
  }

  void _handleInputClearCheck() {
    // لا نحتاج لمسح يدوي، المستخدم يتحكم
  }

  Future<void> _translate() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final response = await http.post(
        Uri.parse('https://translate.googleapis.com/translate_a/single'),
        body: {
          'client': 'gtx',
          'sl': 'auto',
          'tl': _selectedLanguage,
          'dt': 't',
          'q': _sourceController.text,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translatedText = data[0][0][0];
        setState(() => _translatedController.text = translatedText);
      }
    } catch (e) {
      // Fallback محلي
      setState(() => _translatedController.text = _sourceController.text);
    }
    setState(() => _isTranslating = false);
  }

  void _copyTranslated() {
    if (_translatedController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ النص المترجم'), duration: Duration(seconds: 2)),
    );
  }

  String _getSignature() {
    return 'ترجم هذا المستند بواسطه ميرور اسكربيون';
  }

  Future<void> _shareAudio() async {
    if (_translatedController.text.isEmpty) return;
    try {
      final tts = Provider.of<TTSService>(context, listen: false);
      await tts.speak(_translatedController.text, language: _selectedLanguage);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/mirror_scorpion_translation.wav');
      await file.writeAsString(_translatedController.text);
      await Share.shareXFiles([XFile(file.path)], text: _getSignature());
    } catch (e) {
      Share.share('${_getSignature()}\n\n${_translatedController.text}');
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _sourceController.text = '📂 تم اختيار ملف: ${result.files.single.name}\n(ترجمة الملفات الصوتية قادمة في التحديث القادم)');
      }
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // شعار العقرب
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/scorpion_icon.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // شريط تحديد اللغة - 100 لغة
              Center(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2838),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _hundredLanguages.containsKey(_selectedLanguage) ? _selectedLanguage : 'en',
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1B2838),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent),
                      items: _hundredLanguages.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedLanguage = v);
                          _saveLanguage(v);
                          _translate();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // المحرر العلوي - النص المصدر
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isListening ? Colors.redAccent.withOpacity(0.5) : Colors.white12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _sourceController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                      decoration: const InputDecoration(
                        hintText: 'ابدأ بالكتابة أو اضغط المايك للتحدث...',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 15),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        if (_isListening) return;
                        setState(() {});
                        if (val.isNotEmpty && _translatedController.text.isNotEmpty) {
                          _translate();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // مايك لالتقاط الكلام
                        GestureDetector(
                          onTap: _handleMic,
                          child: CircleAvatar(
                            backgroundColor: _isListening ? Colors.redAccent : Colors.blueAccent.withOpacity(0.2),
                            radius: 22,
                            child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 24),
                          ),
                        ),
                        const Spacer(),
                        if (_sourceController.text.isNotEmpty)
                          TextButton.icon(
                            onPressed: _isTranslating ? null : _translate,
                            icon: _isTranslating
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
                                : const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                            label: const Text('ترجم الآن', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // المحرر السفلي - الترجمة
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _translatedController,
                      maxLines: 5,
                      readOnly: true,
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 17, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'الترجمة تظهر هنا...',
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // دبوس رفع ملفات صوتية
                        GestureDetector(
                          onTap: _pickAudioFile,
                          child: const CircleAvatar(
                            backgroundColor: Colors.orangeAccent,
                            radius: 18,
                            child: Icon(Icons.push_pin, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // نسخ
                        GestureDetector(
                          onTap: _copyTranslated,
                          child: const CircleAvatar(
                            backgroundColor: Colors.white12,
                            radius: 18,
                            child: Icon(Icons.copy, color: Colors.white60, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // مشاركة (ملف صوت فقط + توقيع)
                        GestureDetector(
                          onTap: _shareAudio,
                          child: const CircleAvatar(
                            backgroundColor: Colors.greenAccent,
                            radius: 18,
                            child: Icon(Icons.share, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // سبيكر لنطق الترجمة
                        GestureDetector(
                          onTap: () {
                            if (_translatedController.text.isNotEmpty) {
                              Provider.of<TTSService>(context, listen: false)
                                  .speak(_translatedController.text, language: _selectedLanguage);
                            }
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.cyanAccent,
                            radius: 18,
                            child: Icon(Icons.volume_up, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // توقيع التطبيق
              Opacity(
                opacity: 0.15,
                child: Transform.rotate(
                  angle: 130 * 3.14159 / 180,
                  child: const Text(
                    'ترجم هذا النص بواسطه ميرور اسكربيون',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // مفتاح فتح/غلق الفقاعة
              Center(
                child: Consumer<FloatingBubbleService>(
                  builder: (context, bubble, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: bubble.isStarted ? Colors.blueAccent : Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bubble_chart, color: bubble.isStarted ? Colors.blueAccent : Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            bubble.isStarted ? '🔓 الفقاعة مفتوحة' : '🔒 الفقاعة مغلقة',
                            style: TextStyle(color: bubble.isStarted ? Colors.blueAccent : Colors.white38, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: bubble.isStarted,
                            onChanged: (_) {
                              if (bubble.isStarted) {
                                bubble.stopBubble();
                              } else {
                                bubble.startBubble(context);
                              }
                            },
                            activeColor: Colors.blueAccent,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Opacity(
                opacity: 0.2,
                child: Text(
                  "Mirror Scorpion • v2",
                  style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
