import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/ai_language_merger.dart';
import '../../services/tts_service.dart';
import '../../services/language_service.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});
  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  late stt.SpeechToText _speechToText;
  String _selectedLanguage = 'ar';
  bool _isListening = false;
  bool _isTranslating = false;
  bool _clearOnNextInput = false;

  // ===== 100 لغة متكاملة =====
  final Map<String, String> _hundredLanguages = {
    // أرابيك وأوردو وفارسي (25)
    'ar': '🇸🇦 العربية', 'eg': '🇪🇬 عربي مصري', 'dz': '🇩🇿 دارجة',
    'fa': '🇮🇷 فارسی', 'ur': '🇵🇰 اردو', 'ps': '🇦🇫 پښتو',
    'ku': '🇮🇶 Kurdî', 'ckb': 'کوردی سۆرانی', 'sd': 'سنڌي',
    'bal': 'بلوچی', 'lrc': 'لری', 'glk': 'گیلکی',
    'mzn': 'مازرونی', 'azb': 'آذربایجانی', 'bqi': 'بختیاری',

    // إنجليزية وأوروبية (35)
    'en': '🇬🇧 English', 'us': '🇺🇸 English US', 'au': '🇦🇺 English AU',
    'fr': '🇫🇷 Français', 'de': '🇩🇪 Deutsch', 'es': '🇪🇸 Español',
    'mx': '🇲🇽 Español MX', 'pt': '🇵🇹 Português', 'br': '🇧🇷 Português BR',
    'it': '🇮🇹 Italiano', 'nl': '🇳🇱 Nederlands', 'be': '🇧🇪 Nederlands BE',
    'pl': '🇵🇱 Polski', 'sv': '🇸🇪 Svenska', 'da': '🇩🇰 Dansk',
    'no': '🇳🇴 Norsk', 'fi': '🇫🇮 Suomi', 'el': '🇬🇷 Ελληνικά',
    'ro': '🇷🇴 Română', 'hu': '🇭🇺 Magyar', 'cs': '🇨🇿 Čeština',
    'sk': '🇸🇰 Slovenčina', 'sl': '🇸🇮 Slovenščina', 'hr': '🇭🇷 Hrvatski',
    'sr': '🇷🇸 Српски', 'bg': '🇧🇬 Български', 'uk': '🇺🇦 Українська',
    'bs': '🇧🇦 Bosanski', 'mk': '🇲🇰 Македонски', 'sq': '🇦🇱 Shqip',
    'mt': '🇲🇪 Malti', 'ga': '🇮🇪 Gaeilge', 'cy': '🏴 Cymraeg',
    'gd': '🏴 Gàidhlig', 'lb': '🇱🇺 Lëtzebuergesch',

    // آسيوية (25)
    'zh': '🇨🇳 中文简体', 'tw': '🇹🇼 繁體', 'ja': '🇯🇵 日本語',
    'ko': '🇰🇷 한국어', 'vi': '🇻🇳 Tiếng Việt', 'th': '🇹🇭 ไทย',
    'my': '🇲🇲 မြန်မာ', 'km': '🇰🇭 ភាសាខ្មែរ', 'lo': '🇱🇦 ລາວ',
    'mn': '🇲🇳 Монгол', 'ne': '🇳🇵 नेपाली', 'si': '🇱🇰 සිංහල',
    'bo': 'བོད་སྐད', 'dz': 'རྫོང་ཁ', 'ug': 'ئۇيغۇرچە',
    'ii': 'ꆈꌠꁱꂷ',

    // جنوب آسيا (10)
    'hi': '🇮🇳 हिन्दी', 'bn': '🇧🇩 বাংলা', 'pa': '🇮🇳 ਪੰਜਾਬੀ',
    'mr': '🇮🇳 मराठी', 'gu': '🇮🇳 ગુજરાતી', 'ta': '🇮🇳 தமிழ்',
    'te': '🇮🇳 తెలుగు', 'kn': '🇮🇳 ಕನ್ನಡ', 'ml': '🇮🇳 മലയാളം',
    'or': '🇮🇳 ଓଡ଼ିଆ',

    // تركي وقوقاز (5)
    'tr': '🇹🇷 Türkçe', 'az': '🇦🇿 Azərbaycan', 'kk': '🇰🇿 Қазақ',
    'ky': '🇰🇬 Кыргыз', 'uz': '🇺🇿 Oʻzbek',

    // إفريقية (10)
    'sw': '🇹🇿 Kiswahili', 'ha': '🇳🇬 Hausa', 'yo': '🇳🇬 Yorùbá',
    'ig': '🇳🇬 Igbo', 'am': '🇪🇹 አማርኛ', 'om': '🇪🇹 Oromoo',
    'so': '🇸🇴 Soomaali', 'rw': '🇷🇼 Kinyarwanda', 'sn': '🇿🇼 Shona',
    'st': '🇿🇦 Sesotho',

    // إضافات متنوعة
    'tl': '🇵🇭 Filipino', 'ms': '🇲🇾 Bahasa Melayu', 'id': '🇮🇩 Bahasa Indonesia',
    'jw': 'Basa Jawa', 'su': 'Basa Sunda', 'ceb': 'Cebuano',
    'hmn': 'Hmoob', 'haw': '🌺 ʻŌlelo Hawaiʻi',
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
  }

  @override
  void dispose() {
    _sourceController.dispose();
    _translatedController.dispose();
    super.dispose();
  }

  void _handleInputClearCheck() {
    if (_clearOnNextInput) {
      _clearOnNextInput = false;
    }
  }

  Future<void> _translate() async {
    final text = _sourceController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isTranslating = true);

    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          'q': text,
          'source': 'auto',
          'target': _selectedLanguage,
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = utf8.decode(response.bodyBytes);
        final data = jsonDecode(body) as Map;
        _translatedController.text =
            (data['translatedText'] as String?) ?? text;
      } else {
        _translatedController.text = text;
      }
    } catch (e) {
      _translatedController.text = text;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ فشل الاتصال، تحقق من الإنترنت')),
        );
      }
    }
    setState(() => _isTranslating = false);
  }

  void _handleMic() async {
    if (_isListening) {
      setState(() => _isListening = false);
      await _speechToText.stop();
      return;
    }
    final available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            _sourceController.text = result.recognizedWords;
            _handleInputClearCheck();
            _translate();
            setState(() => _isListening = false);
          }
        },
        localeId: 'ar_SA',
      );
    }
  }

  void _copyText() {
    if (_translatedController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ النص المترجم')),
    );
  }

  void _speakTranslated() {
    if (_translatedController.text.isNotEmpty) {
      Provider.of<TTSService>(context, listen: false)
          .speak(_translatedController.text, language: _selectedLanguage);
    }
  }

  void _shareWithSignature() {
    final text = _translatedController.text;
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(
      text: '$text\n\n—— ترجم بواسطة 🦂 Mirror Scorpion',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم النسخ مع توقيع ميرور سكربيون')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('المحرر الذكي والترجمة النصية',
            style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
            tooltip: 'AI Language Merger',
            onSelected: (v) async {
              final merger = AILanguageMerger();
              if (_sourceController.text.isNotEmpty) {
                final result = await merger.smartTranslate(
                  _sourceController.text,
                  _selectedLanguage,
                );
                _translatedController.text = result;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'merge', child: Text('🧠 AI Smart Translate', style: TextStyle(color: Colors.amber))),
              const PopupMenuItem(value: 'detect', child: Text('🔍 Detect Dialect', style: TextStyle(color: Colors.cyanAccent))),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: Column(
          children: [
            // Scorpion header
            Container(
              height: 80,
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1),
                      image: const DecorationImage(image: AssetImage('assets/images/scorpion_icon.jpeg'), fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🦂 100 لغة', style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('ترجمة فورية بالمايك', style: TextStyle(color: Colors.white38, fontSize: 9)),
                    ],
                  ),
                ],
              ),
            ),

            // Language selector
            Center(
              child: Container(
                width: 260,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _hundredLanguages.containsKey(_selectedLanguage) ? _selectedLanguage : 'ar',
                    isExpanded: true,
                    dropdownColor: const Color(0xFF1B2838),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent),
                    items: _hundredLanguages.entries.map((e) {
                      return DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _selectedLanguage = v);
                        if (_sourceController.text.isNotEmpty) _translate();
                      }
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Source text
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.03),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: _isListening
                              ? Colors.redAccent.withOpacity(0.5)
                              : Colors.white12),
                    ),
                    child: Column(children: [
                      TextField(
                        controller: _sourceController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.white, fontSize: 17),
                        decoration: const InputDecoration(
                          hintText: 'اكتب أو اضغط المايك للتحدث...',
                          hintStyle:
                              TextStyle(color: Colors.white30, fontSize: 15),
                          border: InputBorder.none,
                        ),
                        onChanged: (val) {
                          _handleInputClearCheck();
                          if (val.length > 3) _translate();
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(children: [
                        GestureDetector(
                          onTap: _handleMic,
                          child: CircleAvatar(
                            backgroundColor: _isListening
                                ? Colors.redAccent
                                : Colors.blueAccent.withOpacity(0.2),
                            radius: 20,
                            child: Icon(
                                _isListening ? Icons.stop : Icons.mic,
                                color: Colors.white,
                                size: 22),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_sourceController.text.length}/500',
                          style: const TextStyle(color: Colors.white24, fontSize: 11),
                        ),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 10),

                  // Translate button
                  if (_sourceController.text.isNotEmpty && !_isTranslating)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _translate,
                        icon: const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                        label: const Text('ترجم الآن',
                            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.amber.withOpacity(0.3))),
                        ),
                      ),
                    ),
                  if (_isTranslating)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: LinearProgressIndicator(
                          backgroundColor: Colors.white12,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.cyanAccent)),
                    ),
                  const SizedBox(height: 10),

                  // Translated text
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.02),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                    ),
                    child: Column(children: [
                      TextField(
                        controller: _translatedController,
                        maxLines: 4,
                        readOnly: true,
                        style: const TextStyle(
                            color: Colors.amberAccent,
                            fontSize: 17,
                            fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                          hintText: 'الترجمة تظهر هنا...',
                          hintStyle:
                              TextStyle(color: Colors.white24, fontSize: 14),
                          border: InputBorder.none,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        IconButton(
                            icon: const Icon(Icons.copy,
                                color: Colors.white60, size: 20),
                            onPressed: _copyText),
                        const SizedBox(width: 8),
                        IconButton(
                            icon: const Icon(Icons.volume_up,
                                color: Colors.cyanAccent, size: 22),
                            onPressed: _speakTranslated),
                        const SizedBox(width: 8),
                        IconButton(
                            icon: const Icon(Icons.share,
                                color: Colors.greenAccent, size: 20),
                            onPressed: _shareWithSignature),
                      ]),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  const Opacity(
                    opacity: 0.15,
                    child: Text("🦂 Mirror Scorpion • 100 لغة",
                        style: TextStyle(color: Colors.white, fontSize: 10)),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
