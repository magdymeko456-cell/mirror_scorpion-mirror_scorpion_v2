import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/language_service.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});
  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  String _targetLang = 'en';
  bool _isListening = false;
  bool _isTranslating = false;

  static const _langs = {
    'ar': '🇸🇦 العربية', 'en': '🇬🇧 English', 'fr': '🇫🇷 Français',
    'de': '🇩🇪 Deutsch', 'es': '🇪🇸 Español', 'tr': '🇹🇷 Türkçe',
    'ur': '🇵🇰 اردو', 'fa': '🇮🇷 فارسی', 'zh': '🇨🇳 中文',
    'ja': '🇯🇵 日本語',
  };

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(String text, {bool isUser = true, String? translated}) {
    setState(() => _messages.add({
      'text': text,
      'isUser': isUser,
      'translated': translated,
      'time': DateTime.now().toString().substring(11, 16),
    }));
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  Future<void> _translateAndRespond(String text) async {
    if (text.trim().isEmpty) return;
    _addMessage(text, isUser: true);
    setState(() => _isTranslating = true);

    try {
      final resp = await http.post(
        Uri.parse('https://libretranslate.com/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': text, 'source': 'auto', 'target': _targetLang, 'format': 'text'}),
      ).timeout(const Duration(seconds: 10));
      if (resp.statusCode == 200) {
        final data = jsonDecode(utf8.decode(resp.bodyBytes));
        final translated = data['translatedText'] as String? ?? text;
        _addMessage(translated, isUser: false, translated: text);
        Provider.of<TTSService>(context, listen: false).speak(translated, language: _targetLang);
      }
    } catch (_) {
      _addMessage(_targetLang == 'ar' ? 'عذراً، حدث خطأ في الترجمة' : 'Translation error', isUser: false);
    }
    setState(() => _isTranslating = false);
  }

  void _handleMic() async {
    if (_isListening) {
      _isListening = false;
      await _speech.stop();
      return;
    }
    final available = await _speech.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        if (result.finalResult) {
          _translateAndRespond(result.recognizedWords);
          setState(() => _isListening = false);
        }
      });
    }
  }

  void _sendText() {
    final text = _msgController.text.trim();
    if (text.isNotEmpty) {
      _msgController.clear();
      _translateAndRespond(text);
    }
  }

  Future<void> _pickAudioFile() async {
    // محاكاة رفع ملف — في الإصدار الكامل سيستخدم file_picker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('📁 رفع الملفات الصوتية قيد التطوير — قريباً')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('محادثة مترجمة 💬', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF0D1B2A),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.cyanAccent),
            onSelected: (v) => setState(() => _targetLang = v),
            itemBuilder: (_) => _langs.entries.map((e) => PopupMenuItem(
              value: e.key,
              child: Text(e.value, style: TextStyle(color: _targetLang == e.key ? Colors.amber : Colors.white)),
            )).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.forum, size: 60, color: Colors.cyanAccent.withOpacity(0.3)),
                      const SizedBox(height: 12),
                      Text('ابدأ المحادثة بالكتابة أو المايك', style: TextStyle(color: Colors.white38, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text('الهدف: ${_langs[_targetLang] ?? 'English'}', style: TextStyle(color: Colors.cyanAccent.withOpacity(0.5), fontSize: 12)),
                    ]),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[i];
                      final isUser = msg['isUser'] as bool;
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.blueAccent.withOpacity(0.15) : Colors.cyanAccent.withOpacity(0.08),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(isUser ? 16 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 16),
                            ),
                            border: Border.all(color: (isUser ? Colors.blueAccent : Colors.cyanAccent).withOpacity(0.2)),
                          ),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(msg['text'] as String, style: const TextStyle(color: Colors.white, fontSize: 15)),
                            if (msg['translated'] != null) ...[
                              const SizedBox(height: 4),
                              Container(height: 1, color: Colors.white12),
                              const SizedBox(height: 4),
                              Text(msg['translated'] as String, style: TextStyle(color: Colors.cyanAccent.withOpacity(0.6), fontSize: 12, fontStyle: FontStyle.italic)),
                            ],
                            const SizedBox(height: 4),
                            Text(msg['time'] as String, style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10)),
                          ]),
                        ),
                      );
                    },
                  ),
          ),
          if (_isTranslating)
            const LinearProgressIndicator(backgroundColor: Colors.white12, valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent)),
          // Input area
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: Row(children: [
              // Mic button
              GestureDetector(
                onTap: _handleMic,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: _isListening ? Colors.redAccent : Colors.blueAccent.withOpacity(0.2),
                  child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 22),
                ),
              ),
              const SizedBox(width: 8),
              // Audio file button
              GestureDetector(
                onTap: _pickAudioFile,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.tealAccent.withOpacity(0.15),
                  child: const Icon(Icons.attach_file, color: Colors.white70, size: 20),
                ),
              ),
              const SizedBox(width: 8),
              // Text field
              Expanded(
                child: TextField(
                  controller: _msgController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'اكتب رسالتك...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onSubmitted: (_) => _sendText(),
                ),
              ),
              const SizedBox(width: 8),
              // Send button
              GestureDetector(
                onTap: _sendText,
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.cyanAccent.withOpacity(0.2),
                  child: const Icon(Icons.send_rounded, color: Colors.cyanAccent, size: 22),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
