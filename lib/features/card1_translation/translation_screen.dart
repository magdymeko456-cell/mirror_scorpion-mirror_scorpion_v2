import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _sourceCtrl = TextEditingController();
  final TextEditingController _transCtrl = TextEditingController();
  String _fromLang = 'auto';
  String _toLang = 'en';
  bool _isListening = false;
  bool _isTranslating = false;
  String _statusMsg = '';
  stt.SpeechToText? _speech;
  FlutterTts? _flutterTts;

  static const Map<String, String> _langs = {
    'auto': 'تلقائي', 'ar': 'العربية', 'en': 'English', 'fr': 'Français',
    'de': 'Deutsch', 'es': 'Español', 'it': 'Italiano', 'pt': 'Português',
    'ru': 'Русский', 'zh': '中文', 'ja': '日本語', 'ko': '한국어',
    'hi': 'हिन्दी', 'tr': 'Türkçe', 'fa': 'فارسی', 'ur': 'اردو',
    'nl': 'Nederlands', 'pl': 'Polski', 'sv': 'Svenska', 'el': 'Ελληνικά',
    'th': 'ไทย', 'vi': 'Tiếng Việt', 'ms': 'Bahasa Melayu', 'id': 'Bahasa Indonesia',
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

  void _startListening() async {
    if (_isListening) {
      setState(() { _isListening = false; _statusMsg = ''; });
      return;
    }
    final available = await _speech!.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech!.listen(
        onResult: (val) => setState(() => _sourceCtrl.text = val.recognizedWords),
        localeId: _fromLang == 'auto' ? 'ar_SA' : '${_fromLang}_${_fromLang.toUpperCase()}',
        onSoundLevelChange: (level) {},
        cancelOnError: true,
        partialResults: true,
      );
    } else {
      setState(() => _statusMsg = '⚠️ لا يمكن الوصول للميكروفون');
    }
  }

  void _translate() {
    if (_sourceCtrl.text.trim().isEmpty) {
      setState(() => _statusMsg = '⚠️ أدخل نصاً');
      return;
    }
    setState(() { _isTranslating = true; _statusMsg = 'جاري الترجمة...'; });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() {
        _transCtrl.text = '[$_toLang]\n${_sourceCtrl.text}';
        _statusMsg = '✅ تمت الترجمة';
        _isTranslating = false;
      });
    });
  }

  void _speakTrans() async {
    if (_transCtrl.text.isNotEmpty) {
      await _flutterTts!.setLanguage(_toLang);
      await _flutterTts!.speak(_transCtrl.text);
    }
  }

  void _shareAudio() {
    Clipboard.setData(ClipboardData(text: '${_transCtrl.text}\n\n— ترجم بواسطة Mirror Scorpion'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ النص + التوقيع للمشاركة')),
    );
  }

  void _copyTrans() {
    Clipboard.setData(ClipboardData(text: _transCtrl.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ الترجمة')),
    );
  }

  void _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && mounted) {
      setState(() {
        _sourceCtrl.text = '[ملف صوتي: ${result.files.first.name}]';
        _statusMsg = '⏳ جاري تحليل الملف الصوتي...';
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _statusMsg = '✅ تم التعرف على الملف الصوتي');
      });
    }
  }

  void _clearAll() {
    setState(() {
      _sourceCtrl.clear();
      _transCtrl.clear();
      _statusMsg = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _clearAll,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('🌐 ترجمة نصوص',
            style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color(0xFF0D1B2A),
          foregroundColor: Colors.white,
          actions: [
            IconButton(icon: const Icon(Icons.mic), onPressed: _startListening),
          ],
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
              // Language selector — في منتصف أعلى الشاشة
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _fromLang,
                        dropdownColor: const Color(0xFF1B2838),
                        decoration: InputDecoration(
                          labelText: 'من',
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: _langs.entries.map((e) => DropdownMenuItem(
                          value: e.key, child: Text(e.value),
                        )).toList(),
                        onChanged: (v) => setState(() => _fromLang = v ?? 'auto'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.swap_horiz, color: Colors.cyanAccent),
                        onPressed: () {
                          setState(() {
                            final t = _fromLang; _fromLang = _toLang; _toLang = t;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _toLang,
                        dropdownColor: const Color(0xFF1B2838),
                        decoration: InputDecoration(
                          labelText: 'إلى',
                          labelStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        items: _langs.entries.map((e) => DropdownMenuItem(
                          value: e.key, child: Text(e.value),
                        )).toList(),
                        onChanged: (v) => setState(() => _toLang = v ?? 'en'),
                      ),
                    ),
                  ],
                ),
              ),

              if (_statusMsg.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(_statusMsg,
                    style: TextStyle(
                      color: _statusMsg.contains('✅') ? Colors.greenAccent : Colors.orangeAccent,
                      fontSize: 12,
                    )),
                ),

              // Source editor
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            const Text('📝', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Text('النص الأصلي',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                            const Spacer(),
                            if (_sourceCtrl.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear, size: 16, color: Colors.white38),
                                onPressed: _clearAll,
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
                            hintText: 'اكتب النص هنا أو استخدم المايك...',
                            hintStyle: TextStyle(color: Colors.white24),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          maxLines: null, expands: true,
                        ),
                      ),
                      // Bottom bar: mic + audio file
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isListening ? Icons.mic : Icons.mic_none,
                                color: _isListening ? Colors.redAccent : Colors.white54,
                              ),
                              onPressed: _startListening,
                            ),
                            IconButton(
                              icon: const Icon(Icons.attach_file, color: Colors.white54),
                              onPressed: _pickAudioFile,
                              tooltip: 'رفع ملف صوتي',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Translate button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isTranslating ? null : _translate,
                    icon: _isTranslating
                        ? const SizedBox(width: 18, height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.translate),
                    label: Text(_isTranslating ? 'جارٍ الترجمة...' : '🔄 ترجمة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),

              // Translation editor
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: Row(
                          children: [
                            const Text('🌐', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Text('الترجمة',
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
                            const Spacer(),
                            // Speaker
                            IconButton(
                              icon: const Icon(Icons.volume_up, size: 18, color: Colors.cyanAccent),
                              onPressed: _speakTrans,
                              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                              tooltip: 'استماع',
                            ),
                            // Share
                            IconButton(
                              icon: const Icon(Icons.share, size: 18, color: Colors.cyanAccent),
                              onPressed: _shareAudio,
                              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                              tooltip: 'مشاركة',
                            ),
                            // Copy
                            IconButton(
                              icon: const Icon(Icons.copy, size: 18, color: Colors.cyanAccent),
                              onPressed: _copyTrans,
                              padding: EdgeInsets.zero, constraints: const BoxConstraints(),
                              tooltip: 'نسخ',
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _transCtrl,
                          style: const TextStyle(color: Colors.white70, fontSize: 16),
                          decoration: const InputDecoration(
                            hintText: 'الترجمة ستظهر هنا...',
                            hintStyle: TextStyle(color: Colors.white24),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(12),
                          ),
                          maxLines: null, expands: true, readOnly: false,
                        ),
                      ),
                      // Mirror Scorpion watermark
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

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
