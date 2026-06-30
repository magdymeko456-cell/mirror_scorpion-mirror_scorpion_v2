import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final TextEditingController _sourceCtrl = TextEditingController();
  final TextEditingController _transCtrl = TextEditingController();
  String _rightLang = 'en';   // اللغة المصدر — دائماً المحرر العلوي يستخدم الزر جهة اليمين
  String _leftLang = 'ar';    // اللغة الهدف — المحرر السفلي يترجم إليها
  bool _isListening = false;
  bool _isTranslating = false;
  stt.SpeechToText? _speech;
  FlutterTts? _flutterTts;

  static const Map<String, String> _langs = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français',
    'de': 'Deutsch', 'es': 'Español', 'it': 'Italiano',
    'pt': 'Português', 'ru': 'Русский', 'zh': '中文',
    'ja': '日本語', 'ko': '한국어', 'hi': 'हिन्दी',
    'tr': 'Türkçe', 'fa': 'فارسی', 'ur': 'اردو',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  @override
  void dispose() {
    _sourceCtrl.dispose();
    _transCtrl.dispose();
    super.dispose();
  }

  void _startListening() {
    if (_isListening) {
      // إذا كان المستخدم يضغط على المايك مرة أخرى — مسح واستقبال جديد
      setState(() {
        _isListening = false;
        _sourceCtrl.clear();
        _transCtrl.clear();
      });
      return;
    }
    _speech!.initialize().then((available) {
      if (available) {
        setState(() => _isListening = true);
        // المحرر العلوي يستخدم اللغة في الزر اليمين (rightLang)
        _speech!.listen(
          onResult: (val) => setState(() => _sourceCtrl.text = val.recognizedWords),
          localeId: '${_rightLang}_${_rightLang.toUpperCase()}',
          partialResults: true,
          cancelOnError: true,
        );
      }
    });
  }

  void _translate() {
    if (_sourceCtrl.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() {
        _transCtrl.text = '$_sourceCtrl.text';
        _isTranslating = false;
      });
    });
  }

  void _swap() {
    setState(() {
      final t = _rightLang; _rightLang = _leftLang; _leftLang = t;
      // المحرر العلوي يظل يستخدم الزر اليمين دائماً
    });
  }

  void _speak() async {
    if (_transCtrl.text.isNotEmpty) {
      await _flutterTts!.setLanguage(_leftLang);
      await _flutterTts!.speak(_transCtrl.text);
    }
  }

  void _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && mounted) {
      setState(() {
        _sourceCtrl.text = '[ملف صوتي: ${result.files.first.name}]';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _translate();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('💬 حوار مترجم',
          style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // Source editor (top) — يستخدم لغة الزر اليمين
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          Text('🎤',
                            style: TextStyle(color: _isListening ? Colors.redAccent : Colors.white54)),
                          const SizedBox(width: 8),
                          Text(_langs[_rightLang] ?? _rightLang,
                            style: const TextStyle(color: Colors.white54, fontSize: 13)),
                          const Spacer(),
                          if (_sourceCtrl.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 16, color: Colors.white38),
                              onPressed: () {
                                setState(() { _sourceCtrl.clear(); _transCtrl.clear(); });
                              },
                              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _sourceCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'سيظهر هنا ما تلتقطه...',
                          hintStyle: TextStyle(color: Colors.white24),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                        maxLines: null, expands: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Controls row: right lang + swap + mic + left lang
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  // اللغة المصدر (اليمين) — المحرر العلوي يستخدمها
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _rightLang,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1B2838),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: _langs.entries.map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value),
                          )).toList(),
                          onChanged: (v) => setState(() => _rightLang = v ?? 'en'),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Swap button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.swap_horiz, color: Colors.cyanAccent),
                      onPressed: _swap,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Mic button — كبير الحجم
                  Container(
                    decoration: BoxDecoration(
                      color: _isListening
                          ? Colors.redAccent.withOpacity(0.2)
                          : Colors.cyan.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        color: _isListening ? Colors.redAccent : Colors.cyanAccent,
                        size: 28,
                      ),
                      onPressed: _startListening,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // اللغة الهدف (اليسار) — يترجم إليها
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _leftLang,
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1B2838),
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          items: _langs.entries.map((e) => DropdownMenuItem(
                            value: e.key, child: Text(e.value),
                          )).toList(),
                          onChanged: (v) => setState(() => _leftLang = v ?? 'ar'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Audio file pin
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.push_pin, color: Colors.white38, size: 18),
                    onPressed: _pickAudio,
                    tooltip: 'رفع ملف صوتي للترجمة',
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Translation editor (bottom)
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Row(
                        children: [
                          Text('🌐',
                            style: TextStyle(color: Colors.white.withOpacity(0.7))),
                          const SizedBox(width: 8),
                          Text(_langs[_leftLang] ?? _leftLang,
                            style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.volume_up, size: 18, color: Colors.cyanAccent),
                            onPressed: _speak,
                            padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                            tooltip: 'نطق الترجمة',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _transCtrl,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'الترجمة...',
                          hintStyle: TextStyle(color: Colors.white24),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                        maxLines: null, expands: true, readOnly: false,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(bottom: 4, right: 12),
                      child: Text('🦂 Mirror Scorpion',
                        style: TextStyle(color: Colors.white.withOpacity(0.15), fontSize: 10),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
