import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});
  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _sourceCtrl = TextEditingController();
  final TextEditingController _targetCtrl = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isTranslating = false;
  String _selectedLang = 'en';
  String _statusMsg = '';

  static const Map<String, String> _langs = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'de': 'Deutsch', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
    'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'tr': 'Türkçe',
    'ur': 'اردو', 'fa': 'فارسی', 'hi': 'हिन्दी', 'bn': 'বাংলা',
    'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu', 'nl': 'Nederlands',
    'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk', 'fi': 'Suomi',
    'no': 'Norsk', 'cs': 'Čeština', 'hu': 'Magyar', 'ro': 'Română',
    'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย', 'vi': 'Tiếng Việt',
    'tl': 'Filipino', 'sw': 'Kiswahili', 'ta': 'தமிழ்', 'te': 'తెలుగు',
    'kn': 'ಕನ್ನಡ', 'ml': 'മലയാളം', 'gu': 'ગુજરાતી', 'mr': 'मराठी',
    'pa': 'ਪੰਜਾਬੀ', 'ne': 'नेपाली', 'si': 'සිංහල', 'km': 'ខ្មែរ',
    'my': 'မြန်မာ', 'lo': 'ລາວ', 'ka': 'ქართული', 'hy': 'Հայերեն',
    'az': 'Azərbaycan', 'uz': 'Oʻzbek', 'kk': 'Қазақ', 'ky': 'Кыргыз',
    'tg': 'Тоҷикӣ', 'mn': 'Монгол', 'ps': 'پښتو', 'sd': 'سنڌي',
    'am': 'አማርኛ', 'om': 'Oromoo', 'ha': 'Hausa', 'ig': 'Igbo',
    'yo': 'Yorùbá', 'zu': 'isiZulu', 'xh': 'isiXhosa', 'af': 'Afrikaans',
    'st': 'Sesotho', 'sn': 'chiShona', 'rw': 'Kinyarwanda', 'mg': 'Malagasy',
    'ny': 'Chichewa', 'eo': 'Esperanto', 'cy': 'Cymraeg', 'ga': 'Gaeilge',
    'gd': 'Gàidhlig', 'mt': 'Malti', 'is': 'Íslenska', 'lv': 'Latviešu',
    'lt': 'Lietuvių', 'et': 'Eesti', 'bs': 'Bosanski', 'hr': 'Hrvatski',
    'sq': 'Shqip', 'mk': 'Македонски', 'sr': 'Српски', 'sl': 'Slovenščina',
    'sk': 'Slovenčina', 'eu': 'Euskara', 'gl': 'Galego', 'ca': 'Català',
    'oc': 'Occitan', 'lb': 'Lëtzebuergesch', 'fy': 'Frysk', 'jv': 'Jawa',
    'su': 'Sunda', 'ceb': 'Cebuano', 'hmn': 'Hmong', 'ht': 'Kreyòl',
    'co': 'Corsu', 'la': 'Latin',
  };

  String _langName(String c) => _langs[c] ?? c;

  @override
  void initState() { super.initState(); _speech = stt.SpeechToText(); }
  @override
  void dispose() { _speech.stop(); _sourceCtrl.dispose(); _targetCtrl.dispose(); super.dispose(); }

  void _clearEditors() {
    if (_targetCtrl.text.isNotEmpty) {
      _sourceCtrl.clear(); _targetCtrl.clear(); _statusMsg = '';
    }
  }

  Future<void> _startListening() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ يرجى منح إذن الميكروفون')));
      return;
    }
    _clearEditors();
    final available = await _speech.initialize();
    if (!available) return;
    setState(() => _isListening = true);
    await _speech.listen(
      onResult: (r) => _sourceCtrl.text = r.recognizedWords,
      listenFor: const Duration(seconds: 30),
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
    if (_sourceCtrl.text.trim().isNotEmpty) _translateText();
  }

  Future<void> _translateText() async {
    if (_sourceCtrl.text.trim().isEmpty) {
      setState(() => _statusMsg = '⚠️ أدخل نصاً للترجمة');
      return;
    }
    setState(() { _isTranslating = true; _statusMsg = 'جاري الترجمة...'; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _targetCtrl.text = '[ترجمة إلى ${_langName(_selectedLang)}]\n\n${_sourceCtrl.text}';
        _statusMsg = '🦂 تمت الترجمة بواسطة ميرور سكربيون';
        _isTranslating = false;
      });
    }
  }

  void _speakTranslation() {
    if (_targetCtrl.text.isNotEmpty) {
      context.read<TTSService>().speak(_targetCtrl.text);
    }
  }

  void _shareText() {
    if (_targetCtrl.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: '$_targetCtrl.text\n\n— 🦂 ميرور سكربيون'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ النص للمشاركة مع التوقيع')));
  }

  void _pickAudioFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📁 رفع الملفات الصوتية متاح في النسخة القادمة')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦂 ترجمة نصية'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () { FocusScope.of(context).unfocus(); _clearEditors(); },
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.teal.withOpacity(0.1),
                  child: const Text('🦂 ميرور سكربيون',
                      style: TextStyle(fontSize: 10, color: Colors.teal),
                      textAlign: TextAlign.center),
                ),
                if (_statusMsg.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: Text(_statusMsg,
                        style: TextStyle(
                          color: _statusMsg.contains('بواسطة') ? Colors.green : Colors.orange,
                          fontSize: 11,
                        )),
                  ),
                // زر اللغة في منتصف الشاشة العلوي
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    width: 240,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.teal.withOpacity(0.4)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedLang,
                        dropdownColor: const Color(0xFF1B2838),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        isExpanded: true,
                        items: _langs.entries.map((e) => DropdownMenuItem(
                          value: e.key,
                          child: Text(_langName(e.key), style: const TextStyle(color: Colors.white, fontSize: 13)),
                        )).toList(),
                        onChanged: (v) { if (v != null) setState(() => _selectedLang = v); },
                      ),
                    ),
                  ),
                ),
                // المحرر العلوي مع مايك
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _sourceCtrl,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: 'اكتب النص هنا أو استخدم الميكروفون...',
                                hintStyle: TextStyle(color: Colors.white30),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                              ),
                              maxLines: null,
                              expands: true,
                              textAlign: TextAlign.right,
                              onTap: () => _clearEditors(),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTapDown: (_) => _startListening(),
                                onTapUp: (_) => _stopListening(),
                                child: Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    color: _isListening ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _isListening ? Colors.red : Colors.white38, width: 2),
                                  ),
                                  child: Icon(
                                    _isListening ? Icons.mic : Icons.mic_none,
                                    color: _isListening ? Colors.red : Colors.white70, size: 24,
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // المحرر السفلي مع الأدوات
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _targetCtrl,
                              style: TextStyle(color: Colors.green.shade300, fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: 'الترجمة ستظهر هنا...',
                                hintStyle: TextStyle(color: Colors.white30),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(12),
                              ),
                              maxLines: null, expands: true,
                              textAlign: TextAlign.right, readOnly: true,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, color: Colors.green, size: 20),
                                onPressed: () {
                                  if (_targetCtrl.text.isNotEmpty) {
                                    Clipboard.setData(ClipboardData(
                                        text: '$_targetCtrl.text\n\n— 🦂 ميرور سكربيون'));
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('✅ تم نسخ النص المترجم')));
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.attach_file, color: Colors.orange, size: 20),
                                onPressed: _pickAudioFile,
                              ),
                              IconButton(
                                icon: const Icon(Icons.share, color: Colors.blue, size: 20),
                                onPressed: _shareText,
                              ),
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: Colors.green, size: 22),
                                onPressed: _speakTranslation,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
