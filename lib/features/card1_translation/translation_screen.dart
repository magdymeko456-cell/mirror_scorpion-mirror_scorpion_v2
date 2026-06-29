import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import '../../services/translation_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  String _selectedLanguage = 'en';
  bool _isTranslating = false;
  bool _isRecording = false;
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechAvailable = false;
  String? _detectedLanguage;

  // 100 languages
  static const Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'pt': 'Português', 'de': 'Deutsch', 'tr': 'Türkçe', 'fa': 'فارسی',
    'ur': 'اردو', 'hi': 'हिन्दी', 'bn': 'বাংলা', 'pa': 'ਪੰਜਾਬੀ',
    'gu': 'ગુજરાતી', 'mr': 'मराठी', 'ta': 'தமிழ்', 'te': 'తెలుగు',
    'kn': 'ಕನ್ನಡ', 'ml': 'മലയാളം', 'or': 'ଓଡ଼ିଆ', 'as': 'অসমীয়া',
    'mai': 'मैथिली', 'ne': 'नेपाली', 'si': 'සිංහල', 'th': 'ไทย',
    'lo': 'ລາວ', 'my': 'မြန်မာ', 'km': 'ភាសាខ្មែរ', 'vi': 'Tiếng Việt',
    'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'mn': 'Монгол',
    'ru': 'Русский', 'uk': 'Українська', 'be': 'Беларуская', 'bg': 'Български',
    'mk': 'Македонски', 'sr': 'Српски', 'hr': 'Hrvatski', 'sl': 'Slovenščina',
    'bs': 'Bosanski', 'sq': 'Shqip', 'ro': 'Română', 'hu': 'Magyar',
    'pl': 'Polski', 'cs': 'Čeština', 'sk': 'Slovenčina', 'lt': 'Lietuvių',
    'lv': 'Latviešu', 'et': 'Eesti', 'fi': 'Suomi', 'sv': 'Svenska',
    'nb': 'Norsk', 'da': 'Dansk', 'is': 'Íslenska', 'ga': 'Gaeilge',
    'cy': 'Cymraeg', 'gd': 'Gàidhlig', 'mt': 'Malti', 'el': 'Ελληνικά',
    'hy': 'Հայերեն', 'ka': 'ქართული', 'az': 'Azərbaycan', 'tk': 'Türkmen',
    'uz': 'Oʻzbek', 'kk': 'Қазақ', 'ky': 'Кыргыз', 'crh': 'Qırımtatar',
    'sd': 'سنڌي', 'ps': 'پښتو', 'ku': 'Kurdî', 'ckb': 'کوردی',
    'sw': 'Kiswahili', 'ha': 'Hausa', 'yo': 'Yorùbá', 'ig': 'Igbo',
    'zu': 'isiZulu', 'xh': 'isiXhosa', 'af': 'Afrikaans',
    'am': 'አማርኛ', 'ti': 'ትግርኛ', 'om': 'Oromoo', 'so': 'Soomaali',
    'rw': 'Kinyarwanda', 'rn': 'Ikirundi', 'lg': 'Luganda', 'ny': 'Chichewa',
    'mg': 'Malagasy', 'eo': 'Esperanto', 'la': 'Latina',
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _sourceController.addListener(_onTextChanged);
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize();
    } catch (_) {
      _speechAvailable = false;
    }
  }

  void _onTextChanged() {
    // Auto-detect when user types
    if (_sourceController.text.isNotEmpty) {
      _autoDetect();
    }
  }

  Future<void> _autoDetect() async {
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/detect'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': _sourceController.text}),
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        if (data.isNotEmpty) {
          final lang = data[0]['language'] as String?;
          setState(() => _detectedLanguage = lang);
        }
      }
    } catch (_) {}
  }

  Future<void> _translateText() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': _sourceController.text,
          'source': 'auto',
          'target': _selectedLanguage,
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final translated = data['translatedText'] as String?;
        if (translated != null) {
          setState(() => _translatedController.text = translated);
        }
      }
    } catch (e) {
      setState(() => _translatedController.text = '⚠️ خطأ: $e');
    }
    setState(() => _isTranslating = false);
  }

  Future<void> _startRecording() async {
    if (!_speechAvailable) return;
    setState(() => _isRecording = true);
    try {
      await _speech.listen(
        onResult: (result) {
          setState(() => _sourceController.text = result.recognizedWords);
        },
        listenFor: const Duration(seconds: 10),
      );
    } catch (_) {}
    setState(() => _isRecording = false);
  }

  Future<void> _speak(String text, String lang) async {
    try {
      await _tts.setLanguage(lang);
      await _tts.speak(text);
    } catch (_) {}
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📋 تم النسخ')));
  }

  void _share(String text) {
    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  void dispose() {
    _sourceController.removeListener(_onTextChanged);
    _sourceController.dispose();
    _translatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ترجمة ${_languages[_selectedLanguage] ?? _selectedLanguage}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
            tooltip: 'AI Language Merger',
            onSelected: (v) {
              if (v == 'merge' && _sourceController.text.isNotEmpty) {
                _translateText();
              } else if (v == 'dialects') {
                _showDialectInfo();
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'merge', child: Text('🧠 AI Smart Translate', style: TextStyle(color: Colors.amber))),
              const PopupMenuItem(value: 'dialects', child: Text('🔍 عرض اللهجات المتقاربة', style: TextStyle(color: Colors.cyanAccent))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Source text
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        const Text('النص المصدر', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        const Spacer(),
                        if (_detectedLanguage != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '🌐 ${_languages[_detectedLanguage] ?? _detectedLanguage}',
                              style: const TextStyle(fontSize: 12, color: Colors.teal),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _sourceController,
                      decoration: const InputDecoration(
                        hintText: 'اكتب النص هنا...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                      ),
                      maxLines: null,
                      expands: true,
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Language selector
              SizedBox(
                width: 150,
                child: DropdownButtonFormField<String>(
                  value: _selectedLanguage,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    isDense: true,
                  ),
                  items: _languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 12)))).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() => _selectedLanguage = v);
                      if (_sourceController.text.isNotEmpty) _translateText();
                    }
                  },
                ),
              ),
              // Translate button
              ElevatedButton.icon(
                onPressed: _isTranslating ? null : _translateText,
                icon: _isTranslating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.translate),
                label: const Text('ترجمة'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              ),
              // Mic
              IconButton(
                icon: Icon(_isRecording ? Icons.mic : Icons.mic_none, color: Colors.teal),
                onPressed: _startRecording,
                tooltip: 'إملاء صوتي',
              ),
            ],
          ),

          // Translated text
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Text('الترجمة إلى ${_languages[_selectedLanguage] ?? _selectedLanguage}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                        const Spacer(),
                        // Copy
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () => _copyToClipboard(_translatedController.text),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        // Speak
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 18),
                          onPressed: () => _speak(_translatedController.text, _selectedLanguage),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 4),
                        // Share
                        IconButton(
                          icon: const Icon(Icons.share, size: 18),
                          onPressed: () => _share(_translatedController.text),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _translatedController,
                      decoration: const InputDecoration(
                        hintText: 'الترجمة ستظهر هنا...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(8),
                      ),
                      maxLines: null,
                      expands: true,
                      readOnly: true,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialectInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.language, color: Colors.teal),
            SizedBox(width: 8),
            Text('اللغات المتقاربة'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _clusterTile('🇸🇦 العربية', '10 لهجات: مصري، شامي، عراقي، مغربي...'),
              _clusterTile('🇬🇧 English', '10 لهجات: US, UK, AU, CA, IN...'),
              _clusterTile('🇹🇷 Türkçe', '10 لغات: أذري، تركمان، أوزبكي...'),
              _clusterTile('🇮🇳 الهندية', '10 لغات: أردو، بنغالي، بنجابي...'),
              _clusterTile('🇨🇳 الصينية', '8 لهجات: كانتونيز، هوكيين، هاكا...'),
              _clusterTile('🇪🇸 Español', '7 لهجات: مكسيكي، أرجنتيني...'),
              _clusterTile('🇧🇷 Português', '4 لهجات: برازيلي، أوروبي...'),
              _clusterTile('🇫🇷 Français', '4 لهجات: كيبيك، بلجيكي...'),
              _clusterTile('🇩🇪 Deutsch', '3 لهجات: نمساوي، سويسري...'),
              _clusterTile('🇮🇷 فارسی', '5 لهجات: تاجیکی، گیلکی...'),
              _clusterTile('🇮🇳 درافيدية', '4 لغات: تاميل، تيلوغو...'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('حسناً')),
        ],
      ),
    );
  }

  Widget _clusterTile(String title, String subtitle) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        leading: const Icon(Icons.auto_awesome, color: Colors.amber),
      ),
    );
  }
}
