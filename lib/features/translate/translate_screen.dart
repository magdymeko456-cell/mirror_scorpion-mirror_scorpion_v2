import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mirror_scorpion/core/services/tts_service.dart';
import 'package:mirror_scorpion/core/widgets/shared_widgets.dart';
import 'package:mirror_scorpion/core/services/database_service.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  String _sourceLang = 'ar';
  String _targetLang = 'en';
  bool _isTranslating = false;
  String _selectedVoice = 'Seif';
  bool _showWatermark = true;
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _history = [];
  bool _isListening = false;

  final List<String> _voices = ['Seif', 'Salma', 'Sama', 'Sara', 'User'];
  final List<Map<String, String>> _languages = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'ur', 'name': 'اردو'},
  ];

  @override
  void initState() {
    super.initState();
    _loadHistory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseService>(context, listen: false).incrementCardUsage('translate');
    });
  }

  Future<void> _loadHistory() async {
    final h = await _dbService.getTranslationHistory();
    if (mounted) setState(() => _history = h);
  }

  Future<void> _translate() async {
    if (_sourceController.text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final response = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': _sourceController.text,
          'source': _sourceLang,
          'target': _targetLang,
        }),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _targetController.text = data['translatedText'];
        await _dbService.saveTranslation(
          _sourceController.text,
          _targetController.text,
          _sourceLang,
          _targetLang,
        );
        await _loadHistory();
      }
    } catch (e) {
      _targetController.text = '[🔁 ترجمة تجريبية] ${_sourceController.text}';
    }
    setState(() => _isTranslating = false);
  }

  void _speak(String text, String lang) {
    if (_selectedVoice == 'User') {
      _showSpeechInput();
      return;
    }
    context.read<TtsService>().speak(text, lang, _selectedVoice);
  }

  void _showSpeechInput() {
    setState(() => _isListening = true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _isListening = false);
        _sourceController.text = '🎤 تجربة الإدخال الصوتي';
      }
    });
  }

  void _swapLanguages() {
    setState(() {
      final temp = _sourceLang;
      _sourceLang = _targetLang;
      _targetLang = temp;
      final tempText = _sourceController.text;
      _sourceController.text = _targetController.text;
      _targetController.text = tempText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦂 ترجمة النصوص'),
        actions: [
          IconButton(
            icon: Icon(_showWatermark ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showWatermark = !_showWatermark),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _sourceLang,
                    decoration: const InputDecoration(labelText: 'من'),
                    items: _languages.map((l) => DropdownMenuItem(
                      value: l['code'],
                      child: Text(l['name']!),
                    )).toList(),
                    onChanged: (v) => setState(() => _sourceLang = v!),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _swapLanguages,
                ),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _targetLang,
                    decoration: const InputDecoration(labelText: 'إلى'),
                    items: _languages.map((l) => DropdownMenuItem(
                      value: l['code'],
                      child: Text(l['name']!),
                    )).toList(),
                    onChanged: (v) => setState(() => _targetLang = v!),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: TextField(
                  controller: _sourceController,
                  maxLines: null,
                  expands: true,
                  textAlign: TextAlign.right,
                  decoration: const InputDecoration(
                    hintText: 'اكتب النص للترجمة...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              MicButton(
                isListening: _isListening,
                onPressed: _showSpeechInput,
              ),
              ElevatedButton.icon(
                onPressed: _isTranslating ? null : _translate,
                icon: _isTranslating
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.translate),
                label: Text(_isTranslating ? 'جارٍ الترجمة...' : 'ترجمة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              SpeakerButton(
                voice: _selectedVoice,
                onPressed: () => _speak(_targetController.text, _targetLang),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Stack(
                  children: [
                    TextField(
                      controller: _targetController,
                      maxLines: null,
                      expands: true,
                      textAlign: TextAlign.right,
                      decoration: const InputDecoration(
                        hintText: 'ستظهر الترجمة هنا...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                    if (_showWatermark)
                      const Positioned(
                        bottom: 8,
                        right: 8,
                        child: WatermarkText(fontSize: 12),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (_showWatermark)
            const Padding(
              padding: EdgeInsets.all(4),
              child: WatermarkText(fontSize: 10),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Text('🎤 الصوت: '),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedVoice,
                  items: _voices.map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(v),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedVoice = v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
