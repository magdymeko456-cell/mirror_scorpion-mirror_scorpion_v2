import "dart:convert";
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';

class DialogueTranslationScreen extends StatefulWidget {
  const DialogueTranslationScreen({super.key});

  @override
  State<DialogueTranslationScreen> createState() => _DialogueTranslationScreenState();
}

class _DialogueTranslationScreenState extends State<DialogueTranslationScreen> with TickerProviderStateMixin {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _langFrom = 'ar';
  String _langTo = 'en';
  bool _isTranslating = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _initSpeech();
    _loadSavedLanguages();
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    if (!await _speech!.initialize()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ التعرف على الصوت غير متاح')),
        );
      }
    }
  }

  void _loadSavedLanguages() {
    final langService = Provider.of<LanguageService>(context, listen: false);
    setState(() {
      _langFrom = langService.getLanguageForScreen('dialogue_from');
      _langTo = langService.getLanguageForScreen('dialogue_to');
      if (_langFrom.isEmpty) _langFrom = 'ar';
      if (_langTo.isEmpty) _langTo = 'en';
    });
  }

  void _saveLanguages() {
    final langService = Provider.of<LanguageService>(context, listen: false);
    langService.saveLanguageForScreen('dialogue_from', _langFrom);
    langService.saveLanguageForScreen('dialogue_to', _langTo);
  }

  void _swapLanguages() {
    setState(() {
      final temp = _langFrom;
      _langFrom = _langTo;
      _langTo = temp;
      final tempText = _sourceController.text;
      _sourceController.text = _translatedController.text;
      _translatedController.text = tempText;
      _saveLanguages();
    });
  }

  void _startListening() async {
    if (_isListening) {
      _speech?.stop();
      setState(() => _isListening = false);
      if (_sourceController.text.isNotEmpty) {
        _performTranslation();
      }
      return;
    }

    if (_speech == null) {
      _initSpeech();
      return;
    }

    bool available = await _speech!.initialize();
    if (!available) return;

    setState(() => _isListening = true);

    // المحرر العلوي يستخدم اللغة في الزر الذي ناحية اليمين (وهو _langFrom)
    _speech!.listen(
      onResult: (result) {
        setState(() => _sourceController.text = result.recognizedWords);
      },
      localeId: _langFrom == 'ar' ? 'ar_SA' : 'en_US',
    );
  }

  Future<void> _performTranslation() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final response = await http.post(
        Uri.parse('https://translate.googleapis.com/translate_a/single'),
        body: {
          'client': 'gtx',
          'sl': _langFrom,
          'tl': _langTo,
          'dt': 't',
          'q': _sourceController.text,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() => _translatedController.text = data[0][0][0]);
      }
    } catch (e) {
      setState(() => _translatedController.text = _sourceController.text);
    }
    setState(() => _isTranslating = false);
  }

  void _speakTranslation() {
    if (_translatedController.text.isNotEmpty) {
      Provider.of<TTSService>(context, listen: false)
          .speak(_translatedController.text, language: _langTo);
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _sourceController.text = '📂 ملف: ${result.files.single.name}');
        _performTranslation();
      }
    } catch (e) {
      // Silent
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sourceController.dispose();
    _translatedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);
    final tts = Provider.of<TTSService>(context);
    final List<String> langCodes = langService.getLanguageCodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('حوار مترجم', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // شعار
              Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.greenAccent.withOpacity(0.5), width: 1.5),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/scorpion_icon.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // صف اللغات: [اليمين: لغة المصدر] [تبديل] [اليسار: لغة الهدف]
              Row(
                children: [
                  // اللغة المصدر - ناحية اليمين
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2838),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.4)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: langCodes.contains(_langFrom) ? _langFrom : 'ar',
                          dropdownColor: const Color(0xFF0D1B2A),
                          style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
                          isExpanded: true,
                          items: langCodes.map((code) => DropdownMenuItem(
                            value: code,
                            child: Text(langService.getLanguageName(code), style: const TextStyle(color: Colors.white, fontSize: 12)),
                          )).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _langFrom = v);
                              _saveLanguages();
                            }
                          },
                        ),
                      ),
                    ),
                  ),

                  // زر التبديل
                  IconButton(
                    icon: const Icon(Icons.swap_horiz, color: Colors.amberAccent, size: 30),
                    onPressed: _swapLanguages,
                    tooltip: 'تبديل اللغات',
                  ),

                  // اللغة الهدف - ناحية اليسار
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2838),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.amber.withOpacity(0.4)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: langCodes.contains(_langTo) ? _langTo : 'en',
                          dropdownColor: const Color(0xFF0D1B2A),
                          style: const TextStyle(color: Colors.amberAccent, fontSize: 12),
                          isExpanded: true,
                          items: langCodes.map((code) => DropdownMenuItem(
                            value: code,
                            child: Text(langService.getLanguageName(code), style: const TextStyle(color: Colors.white, fontSize: 12)),
                          )).toList(),
                          onChanged: (v) {
                            if (v != null) {
                              setState(() => _langTo = v);
                              _saveLanguages();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // المايك الكبير في المنتصف
              GestureDetector(
                onTap: _startListening,
                child: AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: _isListening
                              ? [Colors.redAccent, Colors.red.shade900]
                              : [Colors.greenAccent, Colors.green.shade900],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.redAccent : Colors.greenAccent)
                                .withOpacity(0.3 + _pulseController.value * 0.3),
                            blurRadius: 20 + _pulseController.value * 15,
                            spreadRadius: 3 + _pulseController.value * 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: Colors.white, size: 40,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isListening ? '🟢 جارٍ الاستماع (اضغط للإيقاف)' : '🎤 اضغط للبدء',
                style: TextStyle(color: _isListening ? Colors.greenAccent : Colors.white38, fontSize: 12),
              ),
              const SizedBox(height: 14),

              // المحرر العلوي (النص المصدر)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: TextField(
                        controller: _sourceController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.5),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'النص الأصلي يظهر هنا...',
                          hintStyle: TextStyle(color: Colors.white24),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isListening ? Icons.mic : Icons.mic_none,
                              color: _isListening ? Colors.redAccent : Colors.greenAccent,
                              size: 22,
                            ),
                            onPressed: _startListening,
                          ),
                          // دبوس لرفع الملفات الصوتية
                          IconButton(
                            icon: const Icon(Icons.push_pin, color: Colors.orangeAccent, size: 22),
                            onPressed: _pickAudioFile,
                            tooltip: 'رفع ملف صوتي للترجمة',
                          ),
                          const Spacer(),
                          if (_sourceController.text.isNotEmpty)
                            TextButton.icon(
                              onPressed: _isTranslating ? null : _performTranslation,
                              icon: _isTranslating
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(Icons.translate, size: 16),
                              label: const Text('ترجمة'),
                              style: TextButton.styleFrom(foregroundColor: Colors.greenAccent),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // المحرر السفلي (الترجمة)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 150),
                      child: TextField(
                        controller: _translatedController,
                        maxLines: null,
                        style: const TextStyle(color: Colors.amberAccent, fontSize: 15, height: 1.5),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                          hintText: 'الترجمة ستظهر هنا...',
                          hintStyle: TextStyle(color: Colors.white24),
                        ),
                        readOnly: true,
                      ),
                    ),
                    if (_translatedController.text.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(Icons.volume_up, color: tts.isSpeaking ? Colors.cyanAccent : Colors.greenAccent, size: 22),
                              onPressed: _speakTranslation,
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.white70, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: _translatedController.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ تم النسخ')),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.content_copy, color: Colors.amberAccent, size: 20),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                  text: 'ترجم هذا النص بواسطه ميرور اسكربيون\n\n${_translatedController.text}',
                                ));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('✅ تم النسخ مع التوقيع')),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              const Opacity(
                opacity: 0.2,
                child: Text(
                  "Mirror Scorpion • v2",
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
