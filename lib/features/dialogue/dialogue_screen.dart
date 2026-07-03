import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/services/tts_service.dart';
import '../core/services/ai_service.dart';
import '../core/widgets/shared_widgets.dart';
import '../core/services/database_service.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String _voice = 'Seif';
  bool _showWm = true;
  final List<String> _voices = ['Seif', 'Salma', 'Sama', 'Sara', 'User'];

  @override
  void initState() {
    super.initState();
    _messages.add({'role': 'assistant', 'content': '🦂 مرحباً! أنا Mirror Scorpion. كيف يمكنني مساعدتك؟'});
  }

  Future<void> _send() async {
    if (_msgCtrl.text.trim().isEmpty) return;
    final userMsg = _msgCtrl.text.trim();
    setState(() { _messages.add({'role': 'user', 'content': userMsg}); _isLoading = true; });
    _msgCtrl.clear();
    _scrollDown();

    try {
      final ai = context.read<AiService>();
      String resp;
      try { resp = await ai.getAIResponse(userMsg); }
      catch (_) { resp = await _fallback(userMsg); }
      setState(() { _messages.add({'role': 'assistant', 'content': resp}); _isLoading = false; });
      _scrollDown();
    } catch (e) {
      setState(() { _messages.add({'role': 'assistant', 'content': '⚠️ خطأ: $e'}); _isLoading = false; });
    }
  }

  Future<String> _fallback(String msg) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (msg.contains('ترجم')) return 'يمكنني الترجمة! اكتب النص.';
    if (msg.contains('سلام') || msg.contains('hello')) return 'وعليكم السلام! 🦂';
    return 'شكراً لرسالتك. أنا Mirror Scorpion 🦂. هل لديك سؤال؟';
  }

  void _speak(String text, String lang) {
    if (_voice == 'User') {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎤 صوت المستخدم')));
      return;
    }
    context.read<TtsService>().speak(text, lang, _voice);
  }

  void _scrollDown() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollCtrl.hasClients) _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    });
  }

  void _clear() { setState(() { _messages.clear(); _messages.add({'role': 'assistant', 'content': '🦂 مرحباً!'}); }); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🦂 محادثة ذكية'), actions: [
        IconButton(icon: Icon(_showWm ? Icons.visibility : Icons.visibility_off), onPressed: () => setState(() => _showWm = !_showWm)),
        IconButton(icon: const Icon(Icons.delete_outline), onPressed: _clear),
      ]),
      body: Column(children: [
        Expanded(child: ListView.builder(
          controller: _scrollCtrl, padding: const EdgeInsets.all(16),
          itemCount: _messages.length + (_isLoading ? 1 : 0),
          itemBuilder: (ctx, i) {
            if (i == _messages.length) return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
            final msg = _messages[i]; final isUser = msg['role'] == 'user';
            return Align(
              alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUser ? Colors.blue.shade100 : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16).copyWith(
                    bottomLeft: isUser ? const Radius.circular(4) : null,
                    bottomRight: !isUser ? const Radius.circular(4) : null,
                  ),
                ),
                constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(msg['content']!, style: const TextStyle(fontSize: 16)),
                  if (!isUser && _showWm) const Padding(padding: EdgeInsets.only(top: 4), child: WatermarkText(fontSize: 9)),
                  if (!isUser) SpeakerButton(voice: _voice, onPressed: () => _speak(msg['content']!, 'ar'), size: 24),
                ]),
              ),
            );
          },
        )),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            const Text('🎤 '),
            DropdownButton<String>(value: _voice, underline: const SizedBox(),
              items: _voices.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (v) => setState(() => _voice = v!)),
            const Spacer(),
            if (_showWm) const WatermarkText(fontSize: 10),
          ]),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Theme.of(context).cardColor, boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 4, offset: const Offset(0, -2))]),
          child: SafeArea(child: Row(children: [
            Expanded(child: TextField(
              controller: _msgCtrl, textDirection: TextDirection.rtl,
              decoration: const InputDecoration(hintText: 'اكتب رسالتك...', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
              onSubmitted: (_) => _send(),
            )),
            const SizedBox(width: 8),
            IconButton(icon: const Icon(Icons.send), color: Theme.of(context).primaryColor, onPressed: _send),
          ])),
        ),
      ]),
    );
  }
}
