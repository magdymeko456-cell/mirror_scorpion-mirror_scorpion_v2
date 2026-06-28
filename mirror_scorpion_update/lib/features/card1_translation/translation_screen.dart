import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/language_service.dart';
import 'package:flutter/services.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});
  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  bool _isTranslating = false;
  String _selectedLanguage = 'en';

  final Map<String, String> _languages = {
    'ar': 'Arabic', 'en': 'English', 'fr': 'French', 'es': 'Spanish', 'de': 'German',
    'it': 'Italian', 'tr': 'Turkish', 'zh': 'Chinese', 'ru': 'Russian', 'hi': 'Hindi'
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _loadLastLanguage();
  }

  Future<void> _loadLastLanguage() async {
    final langService = Provider.of<LanguageService>(context, listen: false);
    final lastLang = await langService.getLanguageForScreen('translation');
    if (lastLang != null) setState(() => _selectedLanguage = lastLang);
  }

  void _onMicPressed() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
      _translate();
    } else {
      // مسح عند البدء الجديد
      _sourceController.clear();
      _translatedController.clear();
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(onResult: (result) {
          setState(() => _sourceController.text = result.recognizedWords);
          if (result.finalResult) {
            setState(() => _isListening = false);
            _translate();
          }
        });
      }
    }
  }

  Future<void> _translate() async {
    if (_sourceController.text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_selectedLanguage&dt=t&q=${Uri.encodeComponent(_sourceController.text)}');
      final res = await http.get(url);
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() => _translatedController.text = (data[0] as List).map((e) => e[0] as String).join());
      }
    } catch (e) { debugPrint(e.toString()); }
    setState(() => _isTranslating = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // العقرب في المنتصف العلوي
            Center(child: Image.asset('assets/images/scorpion_icon.jpeg', height: 80)),
            const SizedBox(height: 20),
            // اختيار اللغة
            DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: const Color(0xFF1B2838),
              style: const TextStyle(color: Colors.amber),
              items: _languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
              onChanged: (v) {
                setState(() => _selectedLanguage = v!);
                Provider.of<LanguageService>(context, listen: false).saveLanguageForScreen('translation', v!);
              },
            ),
            const SizedBox(height: 10),
            // المحرر العلوي (مساحة أكبر لرؤية المايك)
            TextField(
              controller: _sourceController,
              maxLines: 6,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: IconButton(onPressed: _onMicPressed, icon: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.blueAccent)),
              ),
            ),
            const SizedBox(height: 15),
            // المحرر السفلي للترجمة
            TextField(
              controller: _translatedController,
              maxLines: 6, readOnly: true,
              style: const TextStyle(color: Colors.amberAccent, fontSize: 18),
              decoration: InputDecoration(
                filled: true, fillColor: Colors.blueAccent.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.copy, color: Colors.white70), onPressed: () => Clipboard.setData(ClipboardData(text: _translatedController.text))),
                IconButton(icon: const Icon(Icons.share, color: Colors.greenAccent), onPressed: () {}), // سيتم برمجتها لمشاركة الصوت
                IconButton(icon: const Icon(Icons.volume_up, color: Colors.blueAccent), onPressed: () => Provider.of<TTSService>(context, listen: false).speak(_translatedController.text)),
              ],
            )
          ],
        ),
      ),
    );
  }
}
