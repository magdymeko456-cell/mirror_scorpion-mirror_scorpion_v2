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
import '../../services/ai_service.dart';
import '../../services/language_service.dart';
import '../../services/premium_verification_service.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  // ... (keep all existing variables and methods as they were)
  final TextEditingController _myMessageController = TextEditingController();
  final TextEditingController _partnerMessageController = TextEditingController();
  final List<Map<String, String>> _conversation = [];
  String _selectedMyLanguage = 'ar';
  String _selectedPartnerLanguage = 'en';
  bool _isRecording = false;
  bool _isTranslating = false;
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechAvailable = false;

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
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize();
    } catch (_) {
      _speechAvailable = false;
    }
  }

  String _getLanguageName(String code) {
    return _languages[code] ?? code;
  }

  Future<String> _translate(String text, String target) async {
    if (text.trim().isEmpty) return '';
    setState(() => _isTranslating = true);
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': 'auto',
          'target': target,
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return (data['translatedText'] as String?) ?? text;
      }
    } catch (_) {}
    setState(() => _isTranslating = false);
    return text;
  }

  Future<void> _startRecording(String forWho) async {
    if (!_speechAvailable) return;
    setState(() => _isRecording = true);
    try {
      await _speech.listen(
        onResult: (result) async {
          final spoken = result.recognizedWords;
          if (spoken.isNotEmpty) {
            if (forWho == 'me') {
              _myMessageController.text = spoken;
            } else {
              _partnerMessageController.text = spoken;
            }
          }
        },
        listenFor: const Duration(seconds: 10),
        localeId: _selectedMyLanguage,
      );
    } catch (_) {}
    setState(() => _isRecording = false);
  }

  Future<void> _sendMessage() async {
    final myText = _myMessageController.text.trim();
    final partnerText = _partnerMessageController.text.trim();
    if (myText.isEmpty && partnerText.isEmpty) return;

    setState(() => _isTranslating = true);

    String translatedToPartner = myText;
    String translatedToMe = partnerText;

    if (myText.isNotEmpty) {
      translatedToPartner = await _translate(myText, _selectedPartnerLanguage);
    }
    if (partnerText.isNotEmpty) {
      translatedToMe = await _translate(partnerText, _selectedMyLanguage);
    }

    setState(() {
      _conversation.add({
        'me': myText,
        'me_translated': translatedToPartner,
        'partner': partnerText,
        'partner_translated': translatedToMe,
      });
      _myMessageController.clear();
      _partnerMessageController.clear();
      _isTranslating = false;
    });
  }

  Future<void> _speak(String text, String lang) async {
    try {
      await _tts.setLanguage(lang);
      await _tts.speak(text);
    } catch (_) {}
  }

  void _sendScreenshot() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📸 تم إرسال المحادثة كصورة — قريباً')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حوار مترجم'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.auto_awesome, color: Colors.amber),
            tooltip: 'AI Language Merger',
            onSelected: (v) {
              if (v == 'merge') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('🧠 AI Merger نشط — سيتم كشف اللهجة تلقائياً')),
                );
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
          // Language selectors
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              border: Border(bottom: BorderSide(color: Colors.teal.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _languageDropdown('لغتي', _selectedMyLanguage, (v) {
                    setState(() => _selectedMyLanguage = v ?? 'ar');
                  }),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.compare_arrows, color: Colors.teal, size: 28),
                ),
                Expanded(
                  child: _languageDropdown('لغة الشريك', _selectedPartnerLanguage, (v) {
                    setState(() => _selectedPartnerLanguage = v ?? 'en');
                  }),
                ),
              ],
            ),
          ),

          // Conversation
          Expanded(
            child: _conversation.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.teal),
                        SizedBox(height: 16),
                        Text('ابدأ المحادثة', style: TextStyle(fontSize: 18, color: Colors.teal)),
                        SizedBox(height: 8),
                        Text('اكتب أو استخدم الميكروفون', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _conversation.length,
                    itemBuilder: (_, i) {
                      final msg = _conversation[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // My message
                              Row(
                                children: [
                                  Icon(Icons.person, size: 18, color: Colors.teal),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(msg['me'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, size: 16),
                                    onPressed: () => _speak(msg['me'] ?? '', _selectedMyLanguage),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              if (msg['me_translated'] != msg['me'])
                                Padding(
                                  padding: const EdgeInsets.only(left: 22),
                                  child: Text(msg['me_translated'] ?? '', style: TextStyle(color: Colors.teal.shade600, fontSize: 13)),
                                ),
                              const Divider(),
                              // Partner message
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 18, color: Colors.orange),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(msg['partner'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, size: 16),
                                    onPressed: () => _speak(msg['partner'] ?? '', _selectedPartnerLanguage),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                              if (msg['partner_translated'] != msg['partner'])
                                Padding(
                                  padding: const EdgeInsets.only(left: 22),
                                  child: Text(msg['partner_translated'] ?? '', style: TextStyle(color: Colors.orange.shade600, fontSize: 13)),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Column(
              children: [
                // My input
                Row(
                  children: [
                    Icon(Icons.person, size: 16, color: Colors.teal),
                    const SizedBox(width: 4),
                    Text('أنا', style: TextStyle(color: Colors.teal.shade700)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _myMessageController,
                        decoration: const InputDecoration(
                          hintText: 'اكتب رسالتك...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          isDense: true,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isRecording ? Icons.mic : Icons.mic_none, color: Colors.teal),
                      onPressed: () => _startRecording('me'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Partner input
                Row(
                  children: [
                    Icon(Icons.person_outline, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('الشريك', style: TextStyle(color: Colors.orange.shade700)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _partnerMessageController,
                        decoration: const InputDecoration(
                          hintText: 'رسالة الشريك...',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(_isRecording ? Icons.mic : Icons.mic_none, color: Colors.orange),
                      onPressed: () => _startRecording('partner'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Send + screenshot
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isTranslating ? null : _sendMessage,
                      icon: _isTranslating
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send),
                      label: const Text('إرسال'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.camera_alt),
                      onPressed: _sendScreenshot,
                      tooltip: 'إرسال صورة المحادثة',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _languageDropdown(String label, String value, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            isDense: true,
          ),
          items: _languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 13)))).toList(),
          onChanged: onChanged,
        ),
      ],
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
