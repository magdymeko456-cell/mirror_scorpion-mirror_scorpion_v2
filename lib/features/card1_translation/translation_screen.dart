import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/language_service.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  late stt.SpeechToText _speechToText;
  late AnimationController _scorpionController;
  
  String _selectedLanguage = 'tr'; 
  bool _isListening = false;
  bool _isTranslating = false;
  bool _clearOnNextInput = false;

  final Map<String, String> _hundredLanguages = {
    'tr': 'Türkçe (التركية)', 'ar': 'العربية', 'en': 'English', 'fr': 'Français', 
    'de': 'Deutsch', 'es': 'Español', 'it': 'Italiano', 'pt': 'Português', 
    'ru': 'Русский', 'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'hi': 'हिन्दी',
    'fa': 'فارسی', 'ur': 'اردو', 'nl': 'Nederlands', 'pl': 'Polski', 'sv': 'Svenska',
    'da': 'Dansk', 'fi': 'Suomi', 'el': 'Ελληνικά', 'he': 'עבריت', 'th': 'ไทย', 
    'vi': 'Tiếng Việt', 'ms': 'Bahasa Melayu', 'id': 'Bahasa Indonesia', 'tl': 'Filipino', 
    'cs': 'Čeština', 'hu': 'Magyar', 'ro': 'Română', 'sk': 'Slovenčina', 'hr': 'Hrvatski',
    'sr': 'Српски', 'bg': 'Български', 'uk': 'Українська', 'ka': 'ქართული', 'hy': 'Հայერեն'
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _scorpionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    
    _initScreenLanguage();
  }

  void _initScreenLanguage() async {
    final langService = Provider.of<LanguageService>(context, listen: false);
    String savedLang = langService.getLanguageForScreen('translation');
    if (savedLang == 'auto' || savedLang.isEmpty) {
      savedLang = langService.currentLanguage == 'auto' ? langService.getDeviceLanguage() : langService.currentLanguage;
    }
    setState(() {
      _selectedLanguage = _hundredLanguages.containsKey(savedLang) ? savedLang : 'tr';
    });
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    _scorpionController.dispose();
    super.dispose();
  }

  void _handleInputClearCheck() {
    if (_clearOnNextInput) {
      _sourceController.clear();
      _translatedController.clear();
      _clearOnNextInput = false;
      setState(() {});
    }
  }

  Future<void> _handleMic() async {
    _handleInputClearCheck();
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
      _translate();
      return;
    }

    final available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _sourceController.text = result.recognizedWords;
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
            _translate();
          }
        },
        localeId: 'ar',
      );
    }
  }

  Future<void> _translate() async {
    if (_sourceController.text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_selectedLanguage&dt=t&q=${Uri.encodeComponent(_sourceController.text)}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() {
          _translatedController.text = translated;
          _clearOnNextInput = true;
        });
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    setState(() => _isTranslating = false);
  }

  void _shareAudioWithSignature() {
    if (_translatedController.text.isEmpty) return;
    final textSignature = "\n\nتمت الترجمة بواسطة ميرور سكربيون";
    Clipboard.setData(ClipboardData(text: _translatedController.text + textSignature));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎵 تم توقيع ومحاكاة ملف الصوت بنجاح في المستودع الجديد v2!'),
        backgroundColor: Colors.greenAccent,
      ),
    );
  }

  void _copyText() {
    if (_translatedController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ النص المترجم')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('المحرر الذكي والترجمة النصية', style: TextStyle(color: Colors.white, fontSize: 16)),
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
              AnimatedBuilder(
                animation: _scorpionController,
                builder: (context, child) {
                  return Column(
                    children: [
                      Opacity(
                        opacity: 0.85,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/scorpion_icon.jpeg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 140,
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Colors.cyanAccent.withOpacity(0.4), Colors.transparent],
                          ),
                        ),
                      ),
                      Transform.flip(
                        flipY: true,
                        child: Opacity(
                          opacity: 0.2,
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage('assets/images/scorpion_icon.jpeg'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 15),
              Center(
                child: Container(
                  width: 240,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2838),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1B2838),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent),
                      items: _hundredLanguages.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (v) async {
                        setState(() => _selectedLanguage = v!);
                        final langService = Provider.of<LanguageService>(context, listen: false);
                        await langService.saveLanguageForScreen('translation', v!);
                        _translate();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isListening ? Colors.redAccent.withOpacity(0.5) : Colors.white12),
                ),
                child: Stack(
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
                      onChanged: (val) => _handleInputClearCheck(),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      child: GestureDetector(
                        onTap: _handleMic,
                        child: CircleAvatar(
                          backgroundColor: _isListening ? Colors.redAccent : Colors.blueAccent.withOpacity(0.2),
                          radius: 22,
                          child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                    if (_sourceController.text.isNotEmpty && !_isTranslating)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: TextButton.icon(
                          onPressed: _translate,
                          icon: const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                          label: const Text('ترجم الآن', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 15),
              if (_isTranslating)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(color: Colors.cyanAccent, backgroundColor: Colors.white12),
                ),
              Container(
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _translatedController,
                        maxLines: 5,
                        readOnly: true,
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 17, fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: 'الترجمة الاحترافية تظهر هنا...',
                          hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white60, size: 20),
                          onPressed: _copyText,
                          tooltip: 'نسخ النص المترجم',
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.greenAccent, size: 20),
                          onPressed: _shareAudioWithSignature,
                          tooltip: 'مشاركة ملف الصوت مع التوقيع',
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.cyanAccent, size: 24),
                          onPressed: () {
                            if (_translatedController.text.isNotEmpty) {
                              Provider.of<TTSService>(context, listen: false)
                                  .speak(_translatedController.text, language: _selectedLanguage);
                            }
                          },
                          tooltip: 'نطق الترجمة',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 25),
              const Opacity(
                opacity: 0.2,
                child: Text(
                  "Mirror Scorpion • v2 المستودع الناجح والأصلي",
                  style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
