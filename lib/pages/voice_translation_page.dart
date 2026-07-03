import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:translator/translator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';

class VoiceTranslationPage extends StatefulWidget {
  const VoiceTranslationPage({super.key});

  @override
  State<VoiceTranslationPage> createState() => _VoiceTranslationPageState();
}

class _VoiceTranslationPageState extends State<VoiceTranslationPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _outputController = TextEditingController();
  final GoogleTranslator _translator = GoogleTranslator();
  final FlutterTts _flutterTts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  String _leftLanguage = 'ar';    // اللغة التي سيتحدث بها المستخدم
  String _rightLanguage = 'en';   // اللغة المترجم إليها
  bool _isListening = false;

  final Map<String, String> _languages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'ur': 'اردو', 'tr': 'Türkçe', 'de': 'Deutsch', 'zh': '中文',
    'hi': 'हिन्दी', 'pt': 'Português', 'ru': 'Русский', 'ja': '日本語',
    'ko': '한국어', 'it': 'Italiano', 'nl': 'Nederlands',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedLanguages();
  }

  Future<void> _loadSavedLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _leftLanguage = prefs.getString('voice_left_lang') ?? 'ar';
      _rightLanguage = prefs.getString('voice_right_lang') ?? 'en';
    });
  }

  Future<void> _saveLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('voice_left_lang', _leftLanguage);
    await prefs.setString('voice_right_lang', _rightLanguage);
  }

  void _swapLanguages() {
    setState(() {
      final temp = _leftLanguage;
      _leftLanguage = _rightLanguage;
      _rightLanguage = temp;
      _inputController.clear();
      _outputController.clear();
    });
    _saveLanguages();
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Status: $status'),
        onError: (error) => print('Error: $error'),
      );
      if (available) {
        setState(() => _isListening = true);
        // اللغة اليمين هي لغة المستخدم (سيتم وضعها في المحرر العلوي)
        _speech.listen(
          onResult: (result) {
            setState(() {
              _inputController.text = result.recognizedWords;
            });
          },
          localeId: _leftLanguage, // المستخدم يتحدث باللغة اليمنى
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
      // ترجمة المحتوى
      if (_inputController.text.isNotEmpty) {
        _translateCurrent();
      }
    }
  }

  Future<void> _translateCurrent() async {
    try {
      final translation = await _translator.translate(
        _inputController.text,
        from: _leftLanguage,
        to: _rightLanguage,
      );
      setState(() {
        _outputController.text = translation.text;
      });
      // نطق الترجمة
      await _flutterTts.setLanguage(_rightLanguage);
      await _flutterTts.speak(translation.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e')),
        );
      }
    }
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم اختيار: ${result.files.first.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حوار مترجم'),
        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.9),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // مربع المحرر العلوي (الإدخال)
            Expanded(
              flex: 4,
              child: Card(
                child: TextField(
                  controller: _inputController,
                  maxLines: null,
                  expands: true,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: 'سيتحدث المستخدم...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // مربع المحرر السفلي (الترجمة)
            Expanded(
              flex: 4,
              child: Card(
                child: TextField(
                  controller: _outputController,
                  maxLines: null,
                  expands: true,
                  textAlign: TextAlign.right,
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'الترجمة...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            
            // أسفل: سبيكر للنطق
            if (_outputController.text.isNotEmpty)
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.volume_up, size: 28),
                  onPressed: () async {
                    await _flutterTts.setLanguage(_rightLanguage);
                    await _flutterTts.speak(_outputController.text);
                  },
                  tooltip: 'نطق الترجمة',
                ),
              ),
            
            const SizedBox(height: 12),
            
            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // زر اختيار لغة المصدر (اليمين)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _leftLanguage,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      items: _languages.entries.map((e) => 
                        DropdownMenuItem(value: e.key, child: Text(e.value))
                      ).toList(),
                      onChanged: (v) {
                        setState(() => _leftLanguage = v!);
                        _saveLanguages();
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // زر التبديل
                IconButton(
                  icon: const Icon(Icons.swap_horiz, size: 32),
                  onPressed: _swapLanguages,
                  tooltip: 'تبديل اللغات',
                ),
                const SizedBox(width: 8),
                // زر اختيار لغة الهدف (اليسار)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _rightLanguage,
                      icon: const Icon(Icons.arrow_drop_down),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      items: _languages.entries.map((e) => 
                        DropdownMenuItem(value: e.key, child: Text(e.value))
                      ).toList(),
                      onChanged: (v) {
                        setState(() => _rightLanguage = v!);
                        _saveLanguages();
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // الصف السفلي: دبوس ومايك
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file, size: 28),
                  onPressed: _pickAudioFile,
                  tooltip: 'رفع ملف صوتي',
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  backgroundColor: _isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                  onPressed: _listen,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _inputController.dispose();
    _outputController.dispose();
    super.dispose();
  }
}
