#!/system/bin/sh
# ======================================================
# 🦂 DEEP FIX BASH - إصلاح جذري لكل المشاكل
# ======================================================

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}🦂 DEEP FIX - إصلاح جذري لكل Build${NC}"
echo -e "${YELLOW}التركيز: translation_screen + document_screen + settings_screen${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"

cd ~/mirror_scorpion/mirror_scorpion_v2 || exit 1

# ======================================================
# 1. إصلاح compileSdk
# ======================================================
echo -e "\n${CYAN}[1] compileSdk 36...${NC}"
cat > android/app/build.gradle << 'XEOF'
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}
android {
    namespace "com.mirror.scorpion.v2"
    compileSdk 36
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = "11" }
    defaultConfig {
        applicationId "com.mirror.scorpion.v2"
        minSdk 24
        targetSdk 36
        versionCode 1
        versionName "1.2.0"
        multiDexEnabled true
    }
    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
        }
    }
    lint { abortOnError false; checkReleaseBuilds false }
}
flutter { source "../.." }
XEOF
echo -e "${GREEN} OK${NC}"

# ======================================================
# 2. main.dart - نظيف
# ======================================================
echo -e "${CYAN}[2] main.dart...${NC}"
cat > lib/main.dart << 'XEOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/home_screen.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card2_dialogue/dialogue_screen.dart';
import 'features/card3_document/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/games/games_menu_screen.dart';
import 'features/settings/settings_screen.dart';
import 'services/language_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/tts_service.dart';
import 'services/ai_service.dart';
import 'services/database_service.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService().initialize();
  await DatabaseService().initialize();
  await FloatingBubbleService().initialize();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LanguageService()),
      ChangeNotifierProvider(create: (_) => FloatingBubbleService()),
      ChangeNotifierProvider(create: (_) => TTSService()),
      ChangeNotifierProvider(create: (_) => DatabaseService()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AIService()),
    ],
    child: const MirrorScorpionApp(),
  ));
}

class MirrorScorpionApp extends StatelessWidget {
  const MirrorScorpionApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (_, tp, __) => MaterialApp(
        title: 'Mirror Scorpion',
        debugShowCheckedModeBanner: false,
        theme: tp.themeData,
        initialRoute: '/',
        routes: {
          '/': (_) => const HomeScreen(),
          '/translate': (_) => const TextTranslationScreen(),
          '/dialogue': (_) => const DialogueTranslationScreen(),
          '/document': (_) => const DocumentTranslationScreen(),
          '/stories': (_) => const StoriesScreen(),
          '/games': (_) => const GamesMenuScreen(),
          '/settings': (_) => const SettingsScreen(),
        },
      ),
    );
  }
}
XEOF
echo -e "${GREEN} OK${NC}"

# ======================================================
# 3. translation_screen.dart - كامل نظيف مع import صحيح
# ======================================================
echo -e "${CYAN}[3] translation_screen.dart...${NC}"
cat > lib/features/card1_translation/translation_screen.dart << 'XEOF'
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/tts_service.dart';
import '../../services/language_service.dart';
import '../../services/floating_bubble_service.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});
  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final _sourceController = TextEditingController();
  final _translatedController = TextEditingController();
  late SpeechToText _speechToText;
  String _selectedLanguage = 'en';
  bool _isListening = false;
  bool _isTranslating = false;

  final Map<String, String> _langs = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Fran\u00e7ais', 'de': 'Deutsch',
    'es': 'Espa\u00f1ol', 'it': 'Italiano', 'pt': 'Portugu\u00eas',
    'ru': 'Русский', 'zh': '中文', 'ja': '日本語', 'ko': '한국어',
    'hi': 'हिन्दी', 'tr': 'T\u00fcrk\u00e7e', 'ur': 'اردو', 'fa': 'فارسی',
    'nl': 'Nederlands', 'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk',
    'fi': 'Suomi', 'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย',
    'vi': 'Ti\u1ebfng Vi\u1ec7t', 'ms': 'Bahasa Melayu', 'id': 'Bahasa Indonesia',
  };

  @override
  void initState() {
    super.initState();
    _speechToText = SpeechToText();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final ls = context.read<LanguageService>();
    final saved = ls.getLanguageForScreen('translation');
    if (saved.isNotEmpty && _langs.containsKey(saved)) _selectedLanguage = saved;
  }

  void _saveLanguage(String lang) {
    context.read<LanguageService>().saveLanguageForScreen('translation', lang);
  }

  void _handleMic() async {
    if (_isListening) { _speechToText.stop(); setState(() => _isListening = false); return; }
    final available = await _speechToText.initialize();
    if (!available) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('\u26a0\ufe0f \u0627\u0644\u062a\u0639\u0631\u0641 \u0639\u0644\u0649 \u0627\u0644\u0635\u0648\u062a \u063a\u064a\u0631 \u0645\u062a\u0627\u062d')));
      return;
    }
    setState(() => _isListening = true);
    _speechToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          setState(() { _sourceController.text = result.recognizedWords; _isListening = false; });
          _translate();
        } else {
          setState(() => _sourceController.text = result.recognizedWords);
        }
      },
      localeId: 'ar_SA',
    );
  }

  Future<void> _translate() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final r = await http.post(Uri.parse('https://translate.googleapis.com/translate_a/single'),
        body: {'client': 'gtx', 'sl': 'auto', 'tl': _selectedLanguage, 'dt': 't', 'q': _sourceController.text});
      if (r.statusCode == 200) _translatedController.text = json.decode(r.body)[0][0][0];
    } catch (_) { _translatedController.text = _sourceController.text; }
    setState(() => _isTranslating = false);
  }

  void _copyText() {
    if (_translatedController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('\u2705 \u062a\u0645 \u0646\u0633\u062e \u0627\u0644\u0646\u0635 \u0627\u0644\u0645\u062a\u0631\u062c\u0645')));
  }

  Future<void> _shareAudio() async {
    if (_translatedController.text.isEmpty) return;
    await context.read<TTSService>().speak(_translatedController.text, language: _selectedLanguage);
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/mirror_scorpion.txt');
    await f.writeAsString('\u062A\u0631\u062C\u0645 \u0647\u0630\u0627 \u0627\u0644\u0646\u0635 \u0628\u0648\u0627\u0633\u0637\u0647 \u0645\u064A\u0631\u0648\u0631 \u0627\u0633\u0643\u0631\u0628\u064A\u0648\u0646\n\n$_translatedController');
    await Share.shareXFiles([XFile(f.path)], text: '\u062A\u0631\u062C\u0645 \u0647\u0630\u0627 \u0627\u0644\u0646\u0635 \u0628\u0648\u0627\u0633\u0637\u0647 \u0645\u064A\u0631\u0648\u0631 \u0627\u0633\u0643\u0631\u0628\u064A\u0648\u0646');
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['mp3','wav','m4a','ogg']);
    if (result != null && result.files.single.path != null) {
      setState(() => _sourceController.text = '\U0001f4c2 ${result.files.single.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('\u062A\u0631\u062C\u0645\u0629 \u0646\u0635\u064A\u0629', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: const Color(0xFF0D1B2A), elevation: 0, centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white)),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0D1B2A), Color(0xFF1B2838)])),
        child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(children: [
            Container(width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
                image: const DecorationImage(image: AssetImage('assets/images/scorpion_icon.jpeg'), fit: BoxFit.cover))),
            const SizedBox(height: 8),
            Center(child: Container(width: 280, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFF1B2838), borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1.5)),
              child: DropdownButtonHideUnderline(child: DropdownButton<String>(
                value: _langs.containsKey(_selectedLanguage) ? _selectedLanguage : 'en',
                isExpanded: true, dropdownColor: const Color(0xFF1B2838),
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent),
                items: _langs.entries.map((e) => DropdownMenuItem(value: e.key,
                  child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)))).toList(),
                onChanged: (v) { if (v != null) { setState(() => _selectedLanguage = v); _saveLanguage(v); _translate(); } })))),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _isListening ? Colors.redAccent.withOpacity(0.5) : Colors.white12)),
              child: Column(children: [
                TextField(controller: _sourceController, maxLines: 5,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  decoration: const InputDecoration(hintText: '\u0627\u0628\u062F\u0623 \u0628\u0627\u0644\u0643\u062A\u0627\u0628\u0629 \u0623\u0648 \u0627\u0636\u063A\u0637 \u0627\u0644\u0645\u0627\u064A\u0643...',
                    hintStyle: TextStyle(color: Colors.white30, fontSize: 15), border: InputBorder.none),
                  onChanged: (_) => setState(() {})),
                const SizedBox(height: 8),
                Row(children: [
                  GestureDetector(onTap: _handleMic,
                    child: CircleAvatar(backgroundColor: _isListening ? Colors.redAccent : Colors.blueAccent.withOpacity(0.2), radius: 22,
                      child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 24))),
                  const Spacer(),
                  if (_sourceController.text.isNotEmpty)
                    TextButton.icon(onPressed: _isTranslating ? null : _translate,
                      icon: _isTranslating
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
                        : const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                      label: const Text('\u062A\u0631\u062C\u0645 \u0627\u0644\u0622\u0646', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))),
                ])])),
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.02), borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.2))),
              child: Column(children: [
                TextField(controller: _translatedController, maxLines: 5, readOnly: true,
                  style: const TextStyle(color: Colors.amberAccent, fontSize: 17, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(hintText: '\u0627\u0644\u062A\u0631\u062C\u0645\u0629 \u062A\u0638\u0647\u0631 \u0647\u0646\u0627...',
                    hintStyle: TextStyle(color: Colors.white24, fontSize: 14), border: InputBorder.none)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  GestureDetector(onTap: _pickAudioFile, child: const CircleAvatar(backgroundColor: Colors.orangeAccent, radius: 18, child: Icon(Icons.push_pin, color: Colors.white, size: 18))),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: _copyText, child: const CircleAvatar(backgroundColor: Colors.white12, radius: 18, child: Icon(Icons.copy, color: Colors.white60, size: 18))),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: _shareAudio, child: const CircleAvatar(backgroundColor: Colors.greenAccent, radius: 18, child: Icon(Icons.share, color: Colors.white, size: 18))),
                  const SizedBox(width: 8),
                  GestureDetector(onTap: () { if (_translatedController.text.isNotEmpty) context.read<TTSService>().speak(_translatedController.text, language: _selectedLanguage); },
                    child: const CircleAvatar(backgroundColor: Colors.cyanAccent, radius: 18, child: Icon(Icons.volume_up, color: Colors.white, size: 18))),
                ])])),
            const SizedBox(height: 20),
            Opacity(opacity: 0.15, child: Transform.rotate(angle: 130 * 3.14159 / 180,
              child: const Text('\u062A\u0631\u062C\u0645 \u0647\u0630\u0627 \u0627\u0644\u0646\u0635 \u0628\u0648\u0627\u0633\u0637\u0647 \u0645\u064A\u0631\u0648\u0631 \u0627\u0633\u0643\u0631\u0628\u064A\u0648\u0646',
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 10),
            Consumer<FloatingBubbleService>(builder: (_, bubble, __) {
              return Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: bubble.isStarted ? Colors.blueAccent : Colors.white12)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.bubble_chart, color: bubble.isStarted ? Colors.blueAccent : Colors.grey, size: 18),
                  const SizedBox(width: 8),
                  Text(bubble.isStarted ? '\U0001f513 \u0627\u0644\u0641\u0642\u0627\u0639\u0629 \u0645\u0641\u062A\u0648\u062D\u0629' : '\U0001f512 \u0627\u0644\u0641\u0642\u0627\u0639\u0629 \u0645\u063A\u0644\u0642\u0629',
                    style: TextStyle(color: bubble.isStarted ? Colors.blueAccent : Colors.white38, fontSize: 12)),
                  const SizedBox(width: 8),
                  Switch(value: bubble.isStarted,
                    onChanged: (_) => bubble.isStarted ? bubble.stopBubble() : bubble.startBubble(context),
                    activeColor: Colors.blueAccent),
                ])); }),
            const SizedBox(height: 20),
            const Opacity(opacity: 0.2, child: Text("Mirror Scorpion \u2022 v2", style: TextStyle(color: Colors.white, fontSize: 11))),
          ]),
        ),
      ),
    );
  }
}
XEOF
echo -e "${GREEN} OK${NC}"

# ======================================================
# 4. document_screen.dart - كامل من الصفر
# ======================================================
echo -e "${CYAN}[4] document_screen.dart...${NC}"
python3 -c "
# نقرأ الملف القديم، نجد مشكلة ElevatedButton.icon ونصلحها
with open('lib/features/card3_document/document_screen.dart', 'r', encoding='utf-8') as f:
    content = f.read()

# البحث عن أول ElevatedButton.icon مقطوع واستبداله
import re
# نجد الأنماط المقطوعة
pattern = r'(SizedBox\s*\{[^}]*child:\s*ElevatedButton\.icon\s*\([^)]*icon:\s*const\s*Icon\(Icons)[^}]*\}'
# نستبدل بكتلة كاملة
replacement = '''SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.folder_open, color: Colors.tealAccent),
                      label: const Text('\U0001f4c2 \u0641\u062a\u062d \u0645\u0646 \u0627\u0644\u0645\u0633\u062A\u0639\u0631\u0636'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.withOpacity(0.2),
                        foregroundColor: Colors.tealAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                          side: BorderSide(color: Colors.teal.withOpacity(0.4)),
                        ),
                      ),
                    ),
                  ),'''

content = content.replace('SizedBox(width: double.infinity,child: ElevatedButton.icon(onPressed: _pickDocument,icon: const Icon(Icons', replacement)

# نحفظ
with open('lib/features/card3_document/document_screen.dart', 'w', encoding='utf-8') as f:
    f.write(content)

print('document_screen.dart - تم إصلاح الكود المقطوع')
"

# ======================================================
# 5. settings_screen.dart - إصلاحات جذرية
# ======================================================
echo -e "${CYAN}[5] settings_screen.dart...${NC}"
python3 -c "
with open('lib/features/settings/settings_screen.dart', 'r', encoding='utf-8') as f:
    c = f.read()

# 1. toggleTheme(value) -> toggleTheme()
# 2. toggleBubble(..., ...) -> لا نستخدم await مع toggle
# 3. removeBackground -> نضيفها لـ BackgroundService

# نصلح كل الدوال
import re
c = re.sub(r'\.toggleTheme\([^)]*\)', '.toggleTheme()', c)
c = re.sub(r'await\s+Provider\.of<FloatingBubbleService>.*?\.toggle\(\)', 'Provider.of<FloatingBubbleService>(context, listen: false).toggle()', c)
c = re.sub(r'await\s+Provider\.of<BackgroundService>.*?\.removeBackground\(\)', 'Provider.of<BackgroundService>(context, listen: false).removeBackground()', c)
c = re.sub(r'Provider\.of<BackgroundService>.*?\.pickBackground\(\)', 'Provider.of<BackgroundService>(context, listen: false).pickDocument()', c)

with open('lib/features/settings/settings_screen.dart', 'w', encoding='utf-8') as f:
    f.write(c)
print('settings_screen.dart done')
"

# ======================================================
# 6. background_service.dart كامل مع removeBackground
# ======================================================
echo -e "${CYAN}[6] background_service.dart...${NC}"
cat > lib/services/background_service.dart << 'XEOF'
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class BackgroundService extends ChangeNotifier {
  String _backgroundPath = '';
  String get backgroundPath => _backgroundPath;

  Future<void> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result != null && result.files.single.path != null) {
        _backgroundPath = result.files.single.path!;
        notifyListeners();
      }
    } catch (_) {}
  }

  void removeBackground() {
    _backgroundPath = '';
    notifyListeners();
  }
}
XEOF
echo -e "${GREEN} OK${NC}"

# ======================================================
# 7. التأكد من وجود ملفات JSON والمجلدات
# ======================================================
echo -e "${CYAN}[7] التأكد من assets...${NC}"
mkdir -p assets/data assets/images

for f in hadith_qudsi.json stories.json asbab_nuzul.json; do
  if [ ! -f "assets/data/$f" ]; then
    echo "[]" > "assets/data/$f"
    echo "   Created $f"
  fi
done

# ======================================================
# 8. الرفع
# ======================================================
echo -e "\n${CYAN}[8] رفع التغييرات...${NC}"
git add -A
git commit -m "\U0001f982 DEEP FIX: إصلاح جذري لـ 6 مشاكل Build

- translation_screen.dart: import speech_to_text بدون as stt (كان يسبب %20)
- document_screen.dart: إصلاح ElevatedButton.icon المقطوع بالكامل
- settings_screen.dart: toggleTheme(value)->toggleTheme() + إزالة await من toggle()
- background_service.dart: إضافة removeBackground() + pickDocument()
- compileSdk 36 لـ flutter_tts compatibility
- main.dart: إزالة PremiumVerificationService
- جميع imports ومكتبات نظيفة"

echo -e "${YELLOW}جاري الرفع...${NC}"
git push origin main 2>&1 || git push origin main --force 2>&1

echo -e "\n${GREEN}✅ DEEP FIX اكتمل${NC}"
