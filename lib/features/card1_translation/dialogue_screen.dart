import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});
  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final TextEditingController _sourceCtrl = TextEditingController();
  final TextEditingController _targetCtrl = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isTranslating = false;

  // الزر الأيمن دائماً هو لغة المصدر (المتحدث)
  String _rightLang = 'ar';
  String _leftLang = 'en';

  static const Map<String, String> _langs = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'es': 'Español',
    'de': 'Deutsch', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
    'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'tr': 'Türkçe',
    'ur': 'اردو', 'fa': 'فارسی', 'hi': 'हिन्दी', 'bn': 'বাংলা',
    'id': 'Bahasa Indonesia', 'ms': 'Bahasa Melayu',
  };

  String _langName(String c) => _langs[c] ?? c;

  void _swapLanguages() {
    setState(() {
      final t = _rightLang; _rightLang = _leftLang; _leftLang = t;
    });
  }

  @override
  void initState() { super.initState(); _speech = stt.SpeechToText(); }

  @override
  void dispose() {
    _speech.stop(); _sourceCtrl.dispose(); _targetCtrl.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ يرجى منح إذن الميكروفون')));
      return;
    }
    // مسح المحررين عند الضغط على المايك مرة أخرى
    if (_sourceCtrl.text.isNotEmpty || _targetCtrl.text.isNotEmpty) {
      _sourceCtrl.clear();
      _targetCtrl.clear();
    }
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
    if (_sourceCtrl.text.trim().isNotEmpty) _translateDialog();
  }

  Future<void> _translateDialog() async {
    if (_sourceCtrl.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() {
        _targetCtrl.text = '[${_langName(_leftLang)}]\n\n${_sourceCtrl.text}';
        _isTranslating = false;
      });
    }
  }

  void _speakTranslation() {
    if (_targetCtrl.text.isNotEmpty) {
      context.read<TTSService>().speak(_targetCtrl.text);
    }
  }

  // دبوس لرفع الملفات الصوتية
  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio, allowMultiple: false,
    );
    if (result != null && result.files.isNotEmpty) {
      _sourceCtrl.clear();
      _targetCtrl.clear();
      _sourceCtrl.text = '📁 ${result.files.single.name}\nجاري معالجة...';
      await Future.delayed(const Duration(seconds: 2));
      _sourceCtrl.text = 'نص الملف الصوتي: ${result.files.single.name}';
      _translateDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦂 حوار مترجم'),
        backgroundColor: const Color(0xFF0D1B2A),
        foregroundColor: Colors.teal,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
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
                // ووترمارك
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  color: Colors.teal.withOpacity(0.1),
                  child: const Text('🦂 ميرور سكربيون',
                      style: TextStyle(fontSize: 10, color: Colors.teal),
                      textAlign: TextAlign.center),
                ),
                const SizedBox(height: 8),
                // المحرر العلوي (النص الأصلي)
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: _sourceCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 16),
                        decoration: const InputDecoration(
                          hintText: 'النص الأصلي...',
                          hintStyle: TextStyle(color: Colors.white30),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                        maxLines: null,
                        expands: true,
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // أزرار اللغات والميكروفون
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      // الزر الأيسر - لغة الترجمة إليها
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.green.withOpacity(0.4)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _leftLang,
                              dropdownColor: const Color(0xFF1B2838),
                              style: const TextStyle(color: Colors.green, fontSize: 14),
                              isExpanded: true,
                              items: _langs.entries.map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value, style: const TextStyle(color: Colors.green, fontSize: 12)),
                              )).toList(),
                              onChanged: (v) { if (v != null) setState(() => _leftLang = v); },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // سهم التبديل
                      GestureDetector(
                        onTap: _swapLanguages,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade700.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.swap_horiz, color: Colors.amber, size: 28),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // الميكروفون - بحجم جيد (60)
                      GestureDetector(
                        onTapDown: (_) => _startListening(),
                        onTapUp: (_) => _stopListening(),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _isListening ? Colors.red.withOpacity(0.2) : Colors.white.withOpacity(0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isListening ? Colors.red : Colors.white38,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none,
                            color: _isListening ? Colors.red : Colors.white70,
                            size: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // الزر الأيمن - لغة المتحدث
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.blue.withOpacity(0.4)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _rightLang,
                              dropdownColor: const Color(0xFF1B2838),
                              style: const TextStyle(color: Colors.blue, fontSize: 14),
                              isExpanded: true,
                              items: _langs.entries.map((e) => DropdownMenuItem(
                                value: e.key,
                                child: Text(e.value, style: const TextStyle(color: Colors.blue, fontSize: 12)),
                              )).toList(),
                              onChanged: (v) { if (v != null) setState(() => _rightLang = v); },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // المحرر السفلي (الترجمة)
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                                hintText: 'الترجمة...',
                                hintStyle: TextStyle(color: Colors.white30),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16),
                              ),
                              maxLines: null,
                              expands: true,
                              textAlign: TextAlign.right,
                              readOnly: true,
                            ),
                          ),
                          // الأيقونات أسفل الترجمة
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // دبوس رفع ملفات صوت
                              IconButton(
                                icon: const Icon(Icons.attach_file, color: Colors.orange, size: 22),
                                onPressed: _pickAudioFile,
                              ),
                              // اسبيكر لنطق الترجمة
                              IconButton(
                                icon: const Icon(Icons.volume_up, color: Colors.green, size: 22),
                                onPressed: _speakTranslation,
                              ),
                              // ترجمة يدوية
                              if (_isTranslating)
                                const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                              else
                                IconButton(
                                  icon: const Icon(Icons.translate, color: Colors.blue, size: 22),
                                  onPressed: _translateDialog,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
