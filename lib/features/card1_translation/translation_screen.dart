import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
  String? _lastTranslatedText;

  static const Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'pt': 'Português', 'de': 'Deutsch', 'tr': 'Türkçe', 'fa': 'فارسی',
    'ur': 'اردو', 'hi': 'हिन्दी', 'bn': 'বাংলা', 'zh': '中文',
    'ja': '日本語', 'ko': '한국어', 'ru': 'Русский', 'it': 'Italiano',
    'nl': 'Nederlands', 'sv': 'Svenska', 'pl': 'Polski', 'ro': 'Română',
  };

  @override
  void initState() { super.initState(); _initSpeech(); }

  Future<void> _initSpeech() async {
    try { _speechAvailable = await _speech.initialize(); } catch (_) { _speechAvailable = false; }
  }

  Future<void> _translateText() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': _sourceController.text, 'source': 'auto', 'target': _selectedLanguage, 'format': 'text'}),
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final translated = data['translatedText'] as String?;
        if (translated != null) {
          setState(() { _translatedController.text = translated; _lastTranslatedText = translated; });
        }
      }
    } catch (e) {
      setState(() => _translatedController.text = 'خطأ في الترجمة');
    }
    setState(() => _isTranslating = false);
  }

  Future<void> _startRecording() async {
    if (!_speechAvailable) return;
    setState(() => _isRecording = true);
    try {
      await _speech.listen(onResult: (result) {
        setState(() { _sourceController.text = result.recognizedWords; });
        if (result.finalResult) _translateText();
      }, listenFor: const Duration(seconds: 10));
    } catch (_) {}
    setState(() => _isRecording = false);
  }

  Future<void> _speak(String text, String lang) async {
    try { await _tts.setLanguage(lang); await _tts.speak(text); } catch (_) {}
  }

  void _clear() { _sourceController.clear(); _translatedController.clear(); }

  @override
  void dispose() { _sourceController.dispose(); _translatedController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _clear,
      child: Scaffold(
        appBar: AppBar(title: Text('ترجمة إلى ${_languages[_selectedLanguage] ?? _selectedLanguage}'), backgroundColor: Colors.teal, foregroundColor: Colors.white),
        body: Column(children: [
          // Source text
          Expanded(child: Container(margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Padding(padding: EdgeInsets.all(8), child: Text('النص المصدر', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal))),
              Expanded(child: TextField(controller: _sourceController, decoration: const InputDecoration(hintText: 'اكتب النص هنا...', border: InputBorder.none, contentPadding: EdgeInsets.all(8)), maxLines: null, expands: true)),
            ]),
          )),
          // Controls
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(width: 150, child: DropdownButtonFormField<String>(
              value: _selectedLanguage, isExpanded: true,
              decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), isDense: true),
              items: _languages.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 12)))).toList(),
              onChanged: (v) { if (v != null) { setState(() => _selectedLanguage = v); if (_sourceController.text.isNotEmpty) _translateText(); } },
            )),
            ElevatedButton.icon(onPressed: _isTranslating ? null : _translateText,
              icon: _isTranslating ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.translate),
              label: const Text('ترجمة'), style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white)),
            IconButton(icon: Icon(_isRecording ? Icons.mic : Icons.mic_none, color: Colors.teal, size: 32), onPressed: _startRecording, tooltip: 'إملاء'),
          ]),
          // Translated text
          Expanded(child: Container(margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(padding: const EdgeInsets.all(8), child: Row(children: [
                Text('الترجمة', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                const Spacer(),
                IconButton(icon: const Icon(Icons.copy, size: 18), onPressed: () { Clipboard.setData(ClipboardData(text: _translatedController.text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ'))); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                IconButton(icon: const Icon(Icons.volume_up, size: 18), onPressed: () => _speak(_translatedController.text, _selectedLanguage), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                IconButton(icon: const Icon(Icons.share, size: 18), onPressed: () { Clipboard.setData(ClipboardData(text: '$_lastTranslatedText\n\n- Mirror Scorpion')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ للمشاركة'))); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
              ])),
              Expanded(child: TextField(controller: _translatedController, decoration: const InputDecoration(hintText: 'الترجمة ستظهر هنا...', border: InputBorder.none, contentPadding: EdgeInsets.all(8)), maxLines: null, expands: true, readOnly: true)),
            ]),
          )),
        ]),
      ),
    );
  }
}
