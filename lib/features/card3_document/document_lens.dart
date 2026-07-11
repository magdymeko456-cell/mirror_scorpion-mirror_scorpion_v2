import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';

class DocumentLensScreen extends StatefulWidget {
  const DocumentLensScreen({super.key});

  @override
  State<DocumentLensScreen> createState() => _DocumentLensScreenState();
}

class _DocumentLensScreenState extends State<DocumentLensScreen> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  OnDeviceTranslator? _translator;
  String _recognizedText = '';
  String _translatedText = '';
  bool _isProcessing = false;
  String _targetLanguage = 'en';
  String _sourceLanguage = 'ar';

  final List<Map<String, String>> _languages = [
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'en', 'name': 'English'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'tr', 'name': 'Türkçe'},
    {'code': 'fa', 'name': 'فارسی'},
    {'code': 'ur', 'name': 'اردو'},
    {'code': 'it', 'name': 'Italiano'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'zh', 'name': '中文'},
  ];

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final lang = context.read<LanguageService>();
    final saved = await lang.getLastUsedLanguages();
    if (saved != null && mounted) {
      setState(() => _targetLanguage = saved['target'] ?? 'en');
    }
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      _showMessage('خطأ في الكاميرا: $e');
    }
  }

  Future<void> _captureAndTranslate() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFile(File(image.path));
      final recognized = await _textRecognizer.processImage(inputImage);

      setState(() => _recognizedText = recognized.text);

      // ترجمة النص
      if (recognized.text.isNotEmpty) {
        await _translateText(recognized.text);
      }

      // حفظ اللغة
      final lang = context.read<LanguageService>();
      await lang.saveLastUsedLanguages(
        source: _sourceLanguage,
        target: _targetLanguage,
      );
    } catch (e) {
      _showMessage('خطأ في المعالجة: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _translateText(String text) async {
    setState(() {
      _translatedText = '🔤 [ترجمة]: $text\n\n💡 المعاينة - الترجمة الفعلية تتطلب نموذج ML Kit محمل.';
    });
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      builder: (context) {
        return SizedBox(
          height: 500,
          child: ListView.builder(
            itemCount: _languages.length,
            itemBuilder: (context, index) {
              final lang = _languages[index];
              return ListTile(
                title: Text(lang['name']!, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _targetLanguage = lang['code']!);
                  Navigator.pop(context);
                },
              );
            },
          ),
        );
      },
    );
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF1B2838)),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1B2838),
        title: const Text('🔍 عدسة جوجل', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate, color: Colors.cyanAccent),
            onPressed: _showLanguagePicker,
            tooltip: 'تغيير اللغة',
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── الكاميرا ──
          if (_cameraController != null && _cameraController!.value.isInitialized)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            ),
          // ── الإطار ──
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.cyanAccent, width: 3),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          // ── نتائج الترجمة (في الأسفل) ──
          if (_translatedText.isNotEmpty)
            Positioned(
              bottom: 120,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2838).withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الترجمة:',
                      style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _translatedText,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          // ── زر الترجمة وزر اللغة ──
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // زر اللغة
                FloatingActionButton(
                  heroTag: 'lang',
                  backgroundColor: const Color(0xFF1B2838),
                  onPressed: _showLanguagePicker,
                  child: Text(
                    _targetLanguage.toUpperCase(),
                    style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
                  ),
                ),
                // زر الالتقاط
                FloatingActionButton.large(
                  heroTag: 'capture',
                  backgroundColor: _isProcessing ? Colors.grey : Colors.cyanAccent,
                  onPressed: _isProcessing ? null : _captureAndTranslate,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Icon(Icons.camera, color: Colors.white, size: 36),
                ),
                // زر الصوت
                FloatingActionButton(
                  heroTag: 'speak',
                  backgroundColor: const Color(0xFF1B2838),
                  onPressed: () {
                    if (_translatedText.isNotEmpty) {
                      context.read<TTSService>().speak(_translatedText, languageCode: _targetLanguage);
                    }
                  },
                  child: const Icon(Icons.volume_up, color: Colors.cyanAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
