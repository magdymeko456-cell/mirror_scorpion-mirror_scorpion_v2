import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mirror_scorpion/core/services/tts_service.dart';
import 'package:mirror_scorpion/core/services/ai_service.dart';
import 'package:mirror_scorpion/core/widgets/shared_widgets.dart';
import 'package:mirror_scorpion/core/services/database_service.dart';

class DialogueScreen extends StatefulWidget {
  const DialogueScreen({super.key});

  @override
  State<DialogueScreen> createState() => _DialogueScreenState();
}

class _DialogueScreenState extends State<DialogueScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  String _selectedVoice = 'Seif';
  bool _showWatermark = true;
  String _sourceLang = 'ar';
  String _targetLang = 'en';
  bool _autoTranslate = false;
  bool _isListening = false;

  final List<String> _voices = ['Seif', 'Salma', 'Sama', 'Sara', 'User'];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseService>(context, listen: false).incrementCardUsage('dialogue');
    });
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': '🦂 مرحباً! أنا Mirror Scorpion. كيف يمكنني مساعدتك اليوم؟\nيمكنني الترجمة، الإجابة عن الأسئلة، أو مجرد الدردشة.',
      });
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    final userMsg = _messageController.text.trim();
    setState(() {
      _messages.add({'role': 'user', 'content': userMsg});
      _isLoading = true;
    });
    _messageController.clear();
    _scrollToBottom();

    try {
      final aiService = context.read<AiService>();
      String response;
      try {
        response = await aiService.getAIResponse(userMsg);
      } catch (_) {
        response = await _getFallbackResponse(userMsg);
      }

      if (_autoTranslate && _targetLang != _sourceLang) {
        try {
          final tr = await http.post(
            Uri.parse('https://libretranslate.com/translate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'q': response,
              'source': 'ar',
              'target': _targetLang,
            }),
          );
          if (tr.statusCode == 200) {
            response = jsonDecode(tr.body)['translatedText'];
          }
        } catch (_) {}
      }

      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'content': '⚠️ عذراً، حدث خطأ: $e',
        });
        _isLoading = false;
      });
    }
  }

  Future<String> _getFallbackResponse(String msg) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (msg.contains('ترجم') || msg.contains('translate')) {
      return 'يمكنني الترجمة! اكتب النص الذي تريد ترجمته.';
    }
    if (msg.contains('سلام') || msg.contains('hello') || msg.contains('hi')) {
      return 'وعليكم السلام! كيف يمكنني مساعدتك؟ 🦂';
    }
    return 'شكراً لرسالتك. أنا Mirror Scorpion 🦂، مساعدك الذكي للترجمة والتعلم. هل لديك سؤال محدد؟';
  }

  void _speak(String text, String lang) {
    if (_selectedVoice == 'User') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎤 صوت المستخدم: قم بالتسجيل أولاً')),
      );
      return;
    }
    context.read<TtsService>().speak(text, lang, _selectedVoice);
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _addWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🦂 محادثة ذكية'),
        actions: [
          IconButton(
            icon: Icon(_autoTranslate ? Icons.translate : Icons.translate_outlined),
            tooltip: 'ترجمة تلقائية',
            onPressed: () => setState(() => _autoTranslate = !_autoTranslate),
          ),
          IconButton(
            icon: Icon(_showWatermark ? Icons.visibility : Icons.visibility_off),
            onPressed: () => setState(() => _showWatermark = !_showWatermark),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'مسح المحادثة',
            onPressed: _clearChat,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_autoTranslate)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              color: Colors.amber.shade50,
              child: Row(
                children: [
                  const Text('🌐 ترجمة إلى: '),
                  DropdownButton<String>(
                    value: _targetLang,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'en', child: Text('English')),
                      DropdownMenuItem(value: 'fr', child: Text('Français')),
                      DropdownMenuItem(value: 'tr', child: Text('Türkçe')),
                      DropdownMenuItem(value: 'ur', child: Text('اردو')),
                    ],
                    onChanged: (v) => setState(() => _targetLang = v!),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['content']!,
                          style: const TextStyle(fontSize: 16),
                        ),
                        if (!isUser && _showWatermark)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: WatermarkText(fontSize: 9),
                          ),
                        if (!isUser)
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SpeakerButton(
                                voice: _selectedVoice,
                                onPressed: () => _speak(msg['content']!, 'ar'),
                                size: 24,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text('🎤 الصوت: '),
                DropdownButton<String>(
                  value: _selectedVoice,
                  underline: const SizedBox(),
                  items: _voices.map((v) => DropdownMenuItem(
                    value: v,
                    child: Text(v),
                  )).toList(),
                  onChanged: (v) => setState(() => _selectedVoice = v!),
                ),
                const Spacer(),
                if (_showWatermark)
                  const WatermarkText(fontSize: 10),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(_isListening ? Icons.mic : Icons.mic_none),
                    onPressed: () {
                      setState(() => _isListening = !_isListening);
                    },
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                    onPressed: _sendMessage,
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
