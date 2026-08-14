import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../services/language_service.dart';
import '../../services/translation_api.dart';
import '../../services/tts_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _resultController = TextEditingController();
  String _langFrom = 'ar';
  String _langTo = 'en';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    final langService = Provider.of<LanguageService>(context, listen: false);
    _langFrom = langService.getLanguageForScreen('text_from');
    _langTo = langService.getLanguageForScreen('text_to');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _resultController.dispose();
    super.dispose();
  }

  void _swapLanguages() {
    setState(() {
      final temp = _langFrom;
      _langFrom = _langTo;
      _langTo = temp;
      final tempText = _textController.text;
      _textController.text = _resultController.text;
      _resultController.text = tempText;
    });
    if (_textController.text.isNotEmpty) _processTranslation();
  }

  /// ترجمة فورية مع تأخير قصير (Debounce) — لا نرسل كل حرف للشبكة
  void _processTranslation() {
    if (_textController.text.trim().isEmpty) return;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), _runTranslation);
  }

  Future<void> _runTranslation() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    final langService = Provider.of<LanguageService>(context, listen: false);

    // المحرك السحابي أولاً (100+ لغة)
    var res = await TranslationApi.translate(text, to: _langTo, from: _langFrom);
    if (res.isEmpty) {
      // فشل الاتصال: الاحتياط الأوفلاين المحفوظ — لا إلغاء لأي خدمة
      res = langService.translateOffline(text, _langFrom, _langTo);
    }
    if (!mounted) return;
    setState(() => _resultController.text = res);
  }

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);
    final tts = Provider.of<TTSService>(context);
    final List langCodes = langService.getLanguageCodes();
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('المترجم النصي الذكي',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.blueAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1B2838),
                        borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: _langFrom,
                        dropdownColor: const Color(0xFF0D1B2A),
                        style: TextStyle(color: Colors.blueAccent),
                        items: langCodes
                            .map((c) => DropdownMenuItem(
                                value: c as String,
                                child: Text(langService.getLanguageName(c),
                                    style:
                                        TextStyle(color: Colors.white))))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _langFrom = v as String);
                          Provider.of<LanguageService>(context, listen: false).saveLanguageForScreen('text_from', v as String);
                          if (_textController.text.isNotEmpty) {
                            _processTranslation();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                IconButton(
                    icon: const Icon(Icons.swap_horiz,
                        color: Colors.amberAccent),
                    onPressed: _swapLanguages),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                        color: const Color(0xFF1B2838),
                        borderRadius: BorderRadius.circular(12)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: _langTo,
                        dropdownColor: const Color(0xFF0D1B2A),
                        style: TextStyle(color: Colors.amberAccent),
                        items: langCodes
                            .map((c) => DropdownMenuItem(
                                value: c as String,
                                child: Text(langService.getLanguageName(c),
                                    style:
                                        TextStyle(color: Colors.white))))
                            .toList(),
                        onChanged: (v) {
                          setState(() => _langTo = v as String);
                          Provider.of<LanguageService>(context, listen: false).saveLanguageForScreen('text_to', v as String);
                          if (_textController.text.isNotEmpty) {
                            _processTranslation();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 5,
              style: TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'اكتب النص هنا للترجمة الفورية...',
                hintStyle: TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Color(0xFF1B2838),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              onChanged: (_) => _processTranslation(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _resultController,
              maxLines: 5,
              readOnly: true,
              style: TextStyle(color: Colors.amberAccent),
              decoration: const InputDecoration(
                hintText: 'الترجمة تظهر هنا تلقائياً...',
                hintStyle: TextStyle(color: Colors.white30),
                filled: true,
                fillColor: Color(0xFF1B2838),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.greenAccent),
                  onPressed: () {
                    if (_resultController.text.isNotEmpty) {
                      tts.speak(_resultController.text);
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white70),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: _resultController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ تم نسخ النص')));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
