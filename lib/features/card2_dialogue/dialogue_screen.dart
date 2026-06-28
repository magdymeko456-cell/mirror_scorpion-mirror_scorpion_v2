import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/language_service.dart';

class DialogueTranslationScreen extends StatefulWidget {
  const DialogueTranslationScreen({super.key});

  @override
  State<DialogueTranslationScreen> createState() =>
      _DialogueTranslationScreenState();
}

class _DialogueTranslationScreenState
    extends State<DialogueTranslationScreen> {
  final TextEditingController _upperController = TextEditingController();
  final TextEditingController _lowerController = TextEditingController();
  late stt.SpeechToText _speechToText;
  String _rightLang = 'ar';
  String _leftLang = 'en';
  bool _isListening = false;
  bool _isTranslating = false;
  bool _hasResult = false;

  final Map<String, String> _languages = {
    'af': 'Afrikaans', 'sq': 'Albanian', 'am': 'Amharic', 'ar': 'العربية',
    'hy': 'Armenian', 'az': 'Azerbaijani', 'eu': 'Basque', 'be': 'Belarusian',
    'bn': 'Bengali', 'bs': 'Bosnian', 'bg': 'Bulgarian', 'ca': 'Catalan',
    'zh': '中文', 'co': 'Corsican', 'hr': 'Croatian', 'cs': 'Czech',
    'da': 'Danish', 'nl': 'Dutch', 'en': 'English', 'et': 'Estonian',
    'tl': 'Filipino', 'fi': 'Finnish', 'fr': 'Français', 'ka': 'Georgian',
    'de': 'Deutsch', 'el': 'Greek', 'gu': 'Gujarati', 'hi': 'Hindi',
    'hu': 'Hungarian', 'is': 'Icelandic', 'id': 'Indonesian', 'ga': 'Irish',
    'it': 'Italiano', 'ja': '日本語', 'kn': 'Kannada', 'kk': 'Kazakh',
    'ko': '한국어', 'ku': 'Kurdish', 'lv': 'Latvian', 'lt': 'Lithuanian',
    'mk': 'Macedonian', 'ms': 'Malay', 'ml': 'Malayalam', 'mt': 'Maltese',
    'mr': 'Marathi', 'mn': 'Mongolian', 'my': 'Myanmar', 'ne': 'Nepali',
    'no': 'Norwegian', 'fa': 'فارسی', 'pl': 'Polish', 'pt': 'Português',
    'pa': 'Punjabi', 'ro': 'Romanian', 'ru': 'Русский', 'sr': 'Serbian',
    'si': 'Sinhala', 'sk': 'Slovak', 'sl': 'Slovenian', 'so': 'Somali',
    'es': 'Español', 'su': 'Sundanese', 'sw': 'Swahili', 'sv': 'Swedish',
    'ta': 'Tamil', 'te': 'Telugu', 'th': 'ไทย', 'tr': 'Türkçe',
    'uk': 'Ukrainian', 'ur': 'اردو', 'vi': 'Tiếng Việt', 'cy': 'Welsh',
    'yi': 'Yiddish', 'yo': 'Yoruba', 'zu': 'Zulu',
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _loadLastLanguages();
  }

  Future<void> _loadLastLanguages() async {
    final langService = Provider.of<LanguageService>(context, listen: false);
    final savedRight = langService.getLanguageForScreen('dialogue_right');
    final savedLeft = langService.getLanguageForScreen('dialogue_left');
    if (savedRight != 'auto' && _languages.containsKey(savedRight)) {
      setState(() => _rightLang = savedRight);
    }
    if (savedLeft != 'auto' && _languages.containsKey(savedLeft)) {
      setState(() => _leftLang = savedLeft);
    }
  }

  @override
  void dispose() {
    _upperController.dispose();
    _lowerController.dispose();
    super.dispose();
  }

  Future<void> _handleMic() async {
    // إذا كان في نتائج سابقة، امسح الشاشة لبدء جديد
    if (_hasResult) {
      _upperController.clear();
      _lowerController.clear();
      setState(() => _hasResult = false);
    }

    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
      if (_upperController.text.isNotEmpty) {
        _translate();
      }
      return;
    }

    final available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      // المحرر العلوي يستخدم لغة الزر الذي ناحية اليمين دائماً
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _upperController.text = result.recognizedWords;
            _upperController.selection = TextSelection.fromPosition(
              TextPosition(offset: _upperController.text.length),
            );
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
            _translate();
          }
        },
        localeId: _rightLang, // دائماً يستخدم لغة الزر اليمين
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          listenMode: stt.ListenMode.confirmation,
        ),
      );
    }
  }

  Future<void> _translate() async {
    if (_upperController.text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=$_rightLang&tl=$_leftLang&dt=t&q=${Uri.encodeComponent(_upperController.text)}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() {
          _lowerController.text = translated;
          _hasResult = true;
        });
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    setState(() => _isTranslating = false);
  }

  void _swapLanguages() {
    setState(() {
      final temp = _rightLang;
      _rightLang = _leftLang;
      _leftLang = temp;
      _upperController.clear();
      _lowerController.clear();
      _hasResult = false;
    });
    final langService = Provider.of<LanguageService>(context, listen: false);
    langService.saveLanguageForScreen('dialogue_right', _rightLang);
    langService.saveLanguageForScreen('dialogue_left', _leftLang);
  }

  void _speakTranslation() {
    if (_lowerController.text.isNotEmpty) {
      Provider.of<TTSService>(context, listen: false)
          .speak(_lowerController.text, language: _leftLang);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حوار مترجم',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Upper Editor (source - يستخدم لغة الزر اليمين دائماً)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _upperController,
                            maxLines: null,
                            expands: true,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 20),
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              hintText:
                                  'الكلام الملتقط من المايك يظهر هنا...',
                              hintStyle: TextStyle(
                                  color: Colors.white24, fontSize: 16),
                              border: InputBorder.none,
                            ),
                            readOnly: true,
                          ),
                        ),
                        // إظهار لغة المصدر الحالية
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: Text(
                            'اللغة: ${_languages[_rightLang] ?? _rightLang}',
                            style: TextStyle(
                              color: Colors.blueAccent.withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Language selectors + mic + swap
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left language button (target - للمحرر السفلي)
                      Expanded(
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _leftLang,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1B2838),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white54),
                              items: _languages.entries
                                  .map((e) => DropdownMenuItem(
                                        value: e.key,
                                        child: Text(e.value,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                            overflow:
                                                TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                setState(() => _leftLang = v!);
                                Provider.of<LanguageService>(context,
                                        listen: false)
                                    .saveLanguageForScreen(
                                        'dialogue_left', v!);
                              },
                            ),
                          ),
                        ),
                      ),

                      // Swap
                      IconButton(
                        icon: const Icon(Icons.swap_horiz,
                            color: Colors.amber, size: 28),
                        onPressed: _swapLanguages,
                        tooltip: 'تبديل اللغات',
                      ),

                      // Mic (حجم كبير)
                      GestureDetector(
                        onTap: _handleMic,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isListening
                                ? Colors.redAccent
                                : Colors.blueAccent,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: (_isListening
                                        ? Colors.red
                                        : Colors.blue)
                                    .withOpacity(0.4),
                                blurRadius: 15,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Icon(
                            _isListening ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),

                      // Right language button (source - للمحرر العلوي دائماً)
                      Expanded(
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _rightLang,
                              isExpanded: true,
                              dropdownColor: const Color(0xFF1B2838),
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: Colors.white54),
                              items: _languages.entries
                                  .map((e) => DropdownMenuItem(
                                        value: e.key,
                                        child: Text(e.value,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                            overflow:
                                                TextOverflow.ellipsis),
                                      ))
                                  .toList(),
                              onChanged: (v) {
                                setState(() => _rightLang = v!);
                                Provider.of<LanguageService>(context,
                                        listen: false)
                                    .saveLanguageForScreen(
                                        'dialogue_right', v!);
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Lower Editor (translated - يستخدم لغة الزر اليسار)
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.blueAccent.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _lowerController,
                            maxLines: null,
                            expands: true,
                            style: const TextStyle(
                              color: Colors.amberAccent,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                            decoration: const InputDecoration(
                              hintText: 'الترجمة تظهر هنا...',
                              hintStyle: TextStyle(
                                  color: Colors.white24, fontSize: 16),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_isTranslating)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.blueAccent,
                                    strokeWidth: 2),
                              ),
                            const Spacer(),
                            // سبيكر نطق الترجمة
                            IconButton(
                              icon: const Icon(Icons.volume_up,
                                  color: Colors.blueAccent, size: 28),
                              onPressed: _speakTranslation,
                              tooltip: 'نطق الترجمة',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Branding
                Opacity(
                  opacity: 0.3,
                  child: const Text(
                    "Mirror Scorpion Dialogue",
                    style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
