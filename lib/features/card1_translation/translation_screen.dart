import 'dart:async';
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
  String? _detectedLanguage;

  static const Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'pt': 'Português', 'de': 'Deutsch', 'tr': 'Türkçe', 'fa': 'فارسی',
    'ur': 'اردو', 'hi': 'हिन्दी', 'bn': 'বাংলা', 'zh': '中文',
    'ja': '日本語', 'ko': '한국어', 'ru': 'Русский', 'it': 'Italiano',
    'nl': 'Nederlands', 'sv': 'Svenska', 'pl': 'Polski', 'ro': 'Română',
    'hu': 'Magyar', 'el': 'Ελληνικά', 'cs': 'Čeština', 'th': 'ไทย',
    'vi': 'Tiếng Việt', 'ms': 'Bahasa Melayu', 'id': 'Bahasa Indonesia',
    'sw': 'Kiswahili', 'ha': 'Hausa', 'yo': 'Yorùbá', 'ig': 'Igbo',
    'am': 'አማርኛ', 'so': 'Soomaali', 'zu': 'isiZulu',
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
    if (_sourceController.text.isNotEmpty && _detectedLanguage == null) {
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
          setState(() => _detectedLanguage = data[0]['language'] as String?);
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
      setState(() => _translatedController.text = 'Error: ${e.toString()}');
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم النسخ')),
    );
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
        title: Text('ترجمة إلى ${_languages[_selectedLanguage] ?? _selectedLanguage}'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
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
                            child: Text(_detectedLanguage!, style: const TextStyle(fontSize: 12, color: Colors.teal)),
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
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
              ElevatedButton.icon(
                onPressed: _isTranslating ? null : _translateText,
                icon: _isTranslating
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.translate),
                label: const Text('ترجمة'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              ),
              IconButton(
                icon: Icon(_isRecording ? Icons.mic : Icons.mic_none, color: Colors.teal),
                onPressed: _startRecording,
                tooltip: 'إملاء صوتي',
              ),
            ],
          ),
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
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () => _copyToClipboard(_translatedController.text),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 18),
                          onPressed: () => _speak(_translatedController.text, _selectedLanguage),
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
}
