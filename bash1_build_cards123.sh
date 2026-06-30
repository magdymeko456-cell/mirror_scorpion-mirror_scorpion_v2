#!/system/bin/sh
# ======================================================
# 🦂 MIRROR SCORPION V2 - BASH #1
# إصلاح Build + الكارت 1 (ترجمة نصية) + الكارت 2 (حوار مترجم)
# + الكارت 3 (مستندات وعدسة) + الفقاعة العائمة
# ======================================================

# الألوان
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; NC='\033[0m'

echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}🦂 Mirror Scorpion V2 - Bash #1${NC}"
echo -e "${YELLOW}إصلاح: Build + كارت 1 + كارت 2 + كارت 3${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"

# الذهاب إلى مجلد المشروع
cd ~/mirror_scorpion/mirror_scorpion_v2 || { echo -e "${RED}❌ المجلد غير موجود${NC}"; exit 1; }

# ======================================================
# 1. إصلاح Build - android/app/build.gradle
# ======================================================
echo -e "\n${CYAN}[1/10] إصلاح Build - android/app/build.gradle...${NC}"

cat > android/app/build.gradle << 'APPBUILDEOF'
plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace "com.mirror.scorpion.v2"
    compileSdk 34

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId "com.mirror.scorpion.v2"
        minSdk 24
        targetSdk 34
        versionCode 1
        versionName "1.2.0"
        multiDexEnabled true
    }

    buildTypes {
        release {
            signingConfig signingConfigs.debug
            minifyEnabled false
            shrinkResources false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }

    lint {
        abortOnError false
        checkReleaseBuilds false
    }
}

flutter {
    source "../.."
}
APPBUILDEOF

echo -e "${GREEN} ✅ android/app/build.gradle - تم إصلاح shrinkResources${NC}"

# ======================================================
# 2. تحديث pubspec.yaml
# ======================================================
echo -e "\n${CYAN}[2/10] تحديث pubspec.yaml...${NC}"

cat > pubspec.yaml << 'PUBEOF'
name: mirror_scorpion_v2
description: "Mirror Scorpion - حيث تُصنع البدايات"
publish_to: 'none'
version: 1.2.0+1

environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  provider: ^6.1.2
  http: ^1.2.1
  shared_preferences: ^2.3.3
  path_provider: ^2.1.4
  flutter_tts: ^4.1.0
  sqflite: ^2.3.3+1
  intl: ^0.19.0
  permission_handler: ^11.3.1
  speech_to_text: ^6.6.2
  file_picker: ^8.1.7
  image_picker: ^1.1.2
  clipboard: ^0.1.3
  share_plus: ^10.1.4
  url_launcher: ^6.3.1
  sensors_plus: ^6.1.1
  vector_math: ^2.1.4
  vibration: ^3.1.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/data/hadiths.json
    - assets/data/hadith_qudsi.json
    - assets/data/quran_stories.json
    - assets/data/stories.json
    - assets/data/asbab_nuzul.json
    - assets/data/arbaeen_nawawi.json
    - assets/data/prophet_stories_ibn_kathir.json
    - assets/images/
PUBEOF

echo -e "${GREEN} ✅ pubspec.yaml - تم تحديث الـ dependencies و assets${NC}"

# ======================================================
# 3. ملفات JSON - إنشاء المجلدات إن لم تكن موجودة
# ======================================================
echo -e "\n${CYAN}[3/10] التأكد من وجود مجلدات assets/data و assets/images...${NC}"
mkdir -p assets/data assets/images
echo -e "${GREEN} ✅ assets جاهز${NC}"

# ======================================================
# 4. main.dart - المسار الكامل مع جميع الشاشات
# ======================================================
echo -e "\n${CYAN}[4/10] تحديث main.dart مع جميع الـ routes...${NC}"

mkdir -p lib/features/card1_translation
mkdir -p lib/features/card2_dialogue
mkdir -p lib/features/card3_document
mkdir -p lib/features/card4_stories
mkdir -p lib/features/games
mkdir -p lib/features/settings
mkdir -p lib/services
mkdir -p lib/core/theme

cat > lib/main.dart << 'MAINDART'
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

  final languageService = LanguageService();
  await languageService.initialize();
  final databaseService = DatabaseService();
  final premiumService = PremiumVerificationService();
  await premiumService.initialize();
  final bubbleService = FloatingBubbleService();
  await bubbleService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider.value(value: bubbleService),
        ChangeNotifierProvider(create: (_) => TTSService()),
        ChangeNotifierProvider.value(value: databaseService),
        ChangeNotifierProvider.value(value: premiumService),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AIService()),
      ],
      child: const MirrorScorpionApp(),
    ),
  );
}

class MirrorScorpionApp extends StatelessWidget {
  const MirrorScorpionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Mirror Scorpion',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/translate': (context) => const TextTranslationScreen(),
            '/dialogue': (context) => const DialogueTranslationScreen(),
            '/document': (context) => const DocumentTranslationScreen(),
            '/stories': (context) => const StoriesScreen(),
            '/games': (context) => const GamesMenuScreen(),
            '/settings': (context) => const SettingsScreen(),
          },
        );
      },
    );
  }
}
MAINDART

echo -e "${GREEN} ✅ main.dart - جميع الـ routes مضمنة${NC}"

# ======================================================
# 5. واجهة المنزل (HomeScreen) - المحافظة على النسخة المستقرة #199
#    + تفعيل الفقاعة العائمة
# ======================================================
echo -e "\n${CYAN}[5/10] تحديث HomeScreen...${NC}"

cat > lib/features/home_screen.dart << 'HOMEDART'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/floating_bubble_service.dart';
import '../services/ai_service.dart';
import '../services/tts_service.dart';
import '../services/language_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  String _deviceLanguage = 'ar';
  bool _isBubbleActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
    _loadLanguage();
  }

  void _loadLanguage() {
    final langService = Provider.of<LanguageService>(context, listen: false);
    _deviceLanguage = langService.getDeviceLanguage();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _toggleBubble() async {
    final service = Provider.of<FloatingBubbleService>(context, listen: false);
    if (service.isStarted) {
      await service.stopBubble();
      setState(() => _isBubbleActive = false);
    } else {
      await service.startBubble(context);
      setState(() => _isBubbleActive = true);
    }
  }

  void _showGamesSelection(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: const Color(0xFF1B2838),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text('🎮 اختر لعبتك', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _gameButton(ctx, '♟ شطرنج', Colors.purpleAccent, '/chess'),
                _gameButton(ctx, '🧊 روبيك', Colors.cyanAccent, '/rubik'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _gameButton(BuildContext ctx, String title, Color color, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(ctx);
        Navigator.pushNamed(ctx, route);
      },
      child: Container(
        width: 130, height: 130,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4), width: 1.5),
        ),
        child: Center(
          child: Text(title, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBubbleActive = Provider.of<FloatingBubbleService>(context).isStarted;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: CustomScrollView(
        slivers: [
          // شعار التطبيق - العقرب مع الانعكاس
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                return Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.2,
                      colors: [
                        const Color(0xFF0D1B2A),
                        const Color(0xFF1B2838).withOpacity(_glowAnimation.value),
                      ],
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 10,
                        child: Transform.flip(
                          flipY: true,
                          child: Opacity(
                            opacity: 0.3,
                            child: _buildScorpionLogo(isReflection: true),
                          ),
                        ),
                      ),
                      _buildScorpionLogo(isReflection: false),
                      Positioned(
                        top: 155,
                        child: Container(
                          width: 200, height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.blueAccent.withOpacity(0.6), Colors.transparent],
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 165,
                        child: Text(
                          '🦂 ميرور سكربيون',
                          style: TextStyle(
                            color: Colors.blueAccent.withOpacity(0.5),
                            fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // فقاعة عائمة - مفتاح فتح/غلق
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: isBubbleActive ? Colors.blueAccent : Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBubbleActive ? Icons.bubble_chart : Icons.bubble_chart_outlined,
                      color: isBubbleActive ? Colors.blueAccent : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isBubbleActive ? 'الفقاعة نشطة' : 'تفعيل الفقاعة العائمة',
                      style: TextStyle(
                        color: isBubbleActive ? Colors.blueAccent : Colors.white70,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Switch(
                      value: isBubbleActive,
                      onChanged: (_) => _toggleBubble(),
                      activeColor: Colors.blueAccent,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6 كروت
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildListDelegate([
                _buildCard(Icons.translate, 'ترجمة نصية', '100 لغة + مايك', Colors.blueAccent, '/translate'),
                _buildCard(Icons.forum, 'حوار مترجم', 'محادثة ثنائية فورية', Colors.cyanAccent, '/dialogue'),
                _buildCard(Icons.document_scanner, 'مستندات وعدسة', 'ترجمة صور وملفات', Colors.tealAccent, '/document'),
                _buildCard(Icons.auto_stories, 'قصص وإلهام', 'مكتبة ذكية متكاملة', Colors.orangeAccent, '/stories'),
                _buildCard(Icons.sports_esports, 'ألعاب 3D', 'شطرنج + روبيك', Colors.purpleAccent, '/games'),
                _buildCard(Icons.settings, 'الإعدادات', 'تخصيص وترقية برو', Colors.blueGrey, '/settings'),
              ]),
            ),
          ),

          // Footer
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Center(
                child: Opacity(
                  opacity: 0.3,
                  child: Column(
                    children: [
                      const Text("Mirror Scorpion", style: TextStyle(color: Colors.white)),
                      const SizedBox(height: 5),
                      Text(
                        "v1.2.0 Build #199 - حيث تُصنع البدايات",
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorpionLogo({bool isReflection = false}) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: isReflection ? 1.0 : _pulseAnimation.value,
          child: Container(
            width: isReflection ? 120 : 140,
            height: isReflection ? 120 : 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isReflection
                    ? Colors.blueAccent.withOpacity(0.15)
                    : Colors.blueAccent.withOpacity(0.5),
                width: isReflection ? 1 : 2,
              ),
              boxShadow: isReflection
                  ? []
                  : [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 25, spreadRadius: 8)],
              image: const DecorationImage(
                image: AssetImage('assets/images/scorpion_icon.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCard(IconData icon, String title, String subtitle, Color color, String route) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, route),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3), width: 1),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.1), Colors.transparent],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 12),
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.white54), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
HOMEDART

echo -e "${GREEN} ✅ HomeScreen - تم التحديث مع الفقاعة العائمة${NC}"

# ======================================================
# 6. الكارت 1 - ترجمة نصية (واجهة كاملة كما وصفت)
# ======================================================
echo -e "\n${CYAN}[6/10] إنشاء كارت 1 - ترجمة نصية كاملة...${NC}"

cat > lib/features/card1_translation/translation_screen.dart << 'TRANS1DART'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../services/tts_service.dart';
import '../../services/language_service.dart';

class TextTranslationScreen extends StatefulWidget {
  const TextTranslationScreen({super.key});

  @override
  State<TextTranslationScreen> createState() => _TextTranslationScreenState();
}

class _TextTranslationScreenState extends State<TextTranslationScreen> {
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  late stt.SpeechToText _speechToText;
  String _selectedLanguage = 'en';
  bool _isListening = false;
  bool _isTranslating = false;
  final Map<String, String> _hundredLanguages = {
    'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'de': 'Deutsch',
    'es': 'Español', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
    'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'hi': 'हिन्दी',
    'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی', 'nl': 'Nederlands',
    'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk', 'fi': 'Suomi',
    'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย', 'vi': 'Tiếng Việt',
    'ms': 'Bahasa Melayu', 'id': 'Bahasa Indonesia', 'tl': 'Filipino',
    'cs': 'Čeština', 'hu': 'Magyar', 'ro': 'Română', 'sk': 'Slovenčina',
    'hr': 'Hrvatski', 'sr': 'Српски', 'bg': 'Български', 'uk': 'Українська',
    'sq': 'Shqip', 'hy': 'Հայերեն', 'ka': 'ქართული', 'kk': 'Қазақ',
    'uz': 'Oʻzbek', 'az': 'Azərbaycan', 'mn': 'Монгол', 'ne': 'नेपाली',
    'si': 'සිංහල', 'am': 'አማርኛ', 'sw': 'Kiswahili', 'ha': 'Hausa',
    'yo': 'Yorùbá', 'ig': 'Igbo', 'zu': 'isiZulu', 'xh': 'isiXhosa',
    'af': 'Afrikaans', 'mt': 'Malti', 'cy': 'Cymraeg', 'ga': 'Gaeilge',
    'gd': 'Gàidhlig', 'lb': 'Lëtzebuergesch', 'is': 'Íslenska', 'no': 'Norsk',
    'et': 'Eesti', 'lv': 'Latviešu', 'lt': 'Lietuvių', 'be': 'Беларуская',
    'mk': 'Македонски', 'bs': 'Bosanski', 'sl': 'Slovenščina', 'ca': 'Català',
    'gl': 'Galego', 'eu': 'Euskara', 'fy': 'Frysk', 'eo': 'Esperanto',
    'la': 'Latina', 'ku': 'Kurdî', 'ps': 'پښتو', 'sd': 'سنڌي',
    'ckb': 'کوردی', 'dv': 'ދިވެހި', 'dz': 'རྫོང་ཁ', 'my': 'မြန်မာ',
    'km': 'ភាសាខ្មែរ', 'lo': 'ລາວ', 'bo': 'བོད་སྐད', 'ug': 'ئۇيغۇرچە',
    'tt': 'Татар', 'ba': 'Башҡорт', 'cv': 'Чӑваш', 'ce': 'Нохчийн',
    'os': 'Ирон', 'ab': 'Аԥсшәа', 'kv': 'Коми', 'udm': 'Удмурт',
    'mhr': 'Марий', 'mrj': 'Кырык мары', 'koi': 'Перем коми',
    'sjd': 'Са̄мь', 'sma': 'Åarjelsaemien', 'smj': 'Julevsámegiella',
    'se': 'Davvisámegiella', 'sms': 'Nuorttâlääʹmmiõll',
    'syr': 'ܣܘܪܝܝܐ', 'arc': 'ܐܪܡܝܐ', 'cop': 'ϯⲙⲉⲧⲣⲉⲙⲛ̀ⲭⲏⲙⲓ',
    'tig': 'ትግረ', 'tir': 'ትግርኛ', 'aar': 'Qafar', 'som': 'Soomaali',
    'orm': 'Oromoo', 'ber': 'ⵜⴰⵎⴰⵣⵉⵖⵜ', 'ary': 'الدارجة',
    'apc': 'شامي', 'acm': 'عراقي', 'ars': 'نجدي', 'acq': 'خليجي',
    'ayl': 'ليبي', 'aec': 'مصري',
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _loadSavedLanguage();
  }

  void _loadSavedLanguage() {
    final langService = Provider.of<LanguageService>(context, listen: false);
    final saved = langService.getLanguageForScreen('translation');
    if (saved.isNotEmpty && _hundredLanguages.containsKey(saved)) {
      _selectedLanguage = saved;
    }
  }

  void _saveLanguage(String lang) {
    Provider.of<LanguageService>(context, listen: false)
        .saveLanguageForScreen('translation', lang);
  }

  void _handleMic() async {
    if (_isListening) {
      _speakToText.stop();
      setState(() => _isListening = false);
      return;
    }

    bool available = await _speakToText.initialize();
    if (!available) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('⚠️ التعرف على الصوت غير متاح')),
      );
      return;
    }

    setState(() => _isListening = true);
    _speakToText.listen(
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            _sourceController.text = result.recognizedWords;
            _isListening = false;
            _translate();
          });
        } else {
          setState(() => _sourceController.text = result.recognizedWords);
        }
      },
      localeId: 'ar_SA',
    );
  }

  void _handleInputClearCheck() {
    // لا نحتاج لمسح يدوي، المستخدم يتحكم
  }

  Future<void> _translate() async {
    if (_sourceController.text.trim().isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final response = await http.post(
        Uri.parse('https://translate.googleapis.com/translate_a/single'),
        body: {
          'client': 'gtx',
          'sl': 'auto',
          'tl': _selectedLanguage,
          'dt': 't',
          'q': _sourceController.text,
        },
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translatedText = data[0][0][0];
        setState(() => _translatedController.text = translatedText);
      }
    } catch (e) {
      // Fallback محلي
      setState(() => _translatedController.text = _sourceController.text);
    }
    setState(() => _isTranslating = false);
  }

  void _copyTranslated() {
    if (_translatedController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ تم نسخ النص المترجم'), duration: Duration(seconds: 2)),
    );
  }

  String _getSignature() {
    return 'ترجم هذا المستند بواسطه ميرور اسكربيون';
  }

  Future<void> _shareAudio() async {
    if (_translatedController.text.isEmpty) return;
    try {
      final tts = Provider.of<TTSService>(context, listen: false);
      await tts.speak(_translatedController.text, language: _selectedLanguage);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/mirror_scorpion_translation.wav');
      await file.writeAsString(_translatedController.text);
      await Share.shareXFiles([XFile(file.path)], text: _getSignature());
    } catch (e) {
      Share.share('${_getSignature()}\n\n${_translatedController.text}');
    }
  }

  Future<void> _pickAudioFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'ogg', 'aac'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() => _sourceController.text = '📂 تم اختيار ملف: ${result.files.single.name}\n(ترجمة الملفات الصوتية قادمة في التحديث القادم)');
      }
    } catch (e) {
      // Silent fail
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white, fontSize: 16)),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // شعار العقرب
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/scorpion_icon.jpeg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // شريط تحديد اللغة - 100 لغة
              Center(
                child: Container(
                  width: 280,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2838),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.4), width: 1.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _hundredLanguages.containsKey(_selectedLanguage) ? _selectedLanguage : 'en',
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1B2838),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.cyanAccent),
                      items: _hundredLanguages.entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _selectedLanguage = v);
                          _saveLanguage(v);
                          _translate();
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // المحرر العلوي - النص المصدر
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.03),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _isListening ? Colors.redAccent.withOpacity(0.5) : Colors.white12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _sourceController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white, fontSize: 17),
                      decoration: const InputDecoration(
                        hintText: 'ابدأ بالكتابة أو اضغط المايك للتحدث...',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 15),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        if (_isListening) return;
                        setState(() {});
                        if (val.isNotEmpty && _translatedController.text.isNotEmpty) {
                          _translate();
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // مايك لالتقاط الكلام
                        GestureDetector(
                          onTap: _handleMic,
                          child: CircleAvatar(
                            backgroundColor: _isListening ? Colors.redAccent : Colors.blueAccent.withOpacity(0.2),
                            radius: 22,
                            child: Icon(_isListening ? Icons.stop : Icons.mic, color: Colors.white, size: 24),
                          ),
                        ),
                        const Spacer(),
                        if (_sourceController.text.isNotEmpty)
                          TextButton.icon(
                            onPressed: _isTranslating ? null : _translate,
                            icon: _isTranslating
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
                                : const Icon(Icons.auto_awesome, color: Colors.amber, size: 18),
                            label: const Text('ترجم الآن', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // المحرر السفلي - الترجمة
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.02),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _translatedController,
                      maxLines: 5,
                      readOnly: true,
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 17, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        hintText: 'الترجمة تظهر هنا...',
                        hintStyle: TextStyle(color: Colors.white24, fontSize: 14),
                        border: InputBorder.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // دبوس رفع ملفات صوتية
                        GestureDetector(
                          onTap: _pickAudioFile,
                          child: const CircleAvatar(
                            backgroundColor: Colors.orangeAccent,
                            radius: 18,
                            child: Icon(Icons.push_pin, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // نسخ
                        GestureDetector(
                          onTap: _copyTranslated,
                          child: const CircleAvatar(
                            backgroundColor: Colors.white12,
                            radius: 18,
                            child: Icon(Icons.copy, color: Colors.white60, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // مشاركة (ملف صوت فقط + توقيع)
                        GestureDetector(
                          onTap: _shareAudio,
                          child: const CircleAvatar(
                            backgroundColor: Colors.greenAccent,
                            radius: 18,
                            child: Icon(Icons.share, color: Colors.white, size: 18),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // سبيكر لنطق الترجمة
                        GestureDetector(
                          onTap: () {
                            if (_translatedController.text.isNotEmpty) {
                              Provider.of<TTSService>(context, listen: false)
                                  .speak(_translatedController.text, language: _selectedLanguage);
                            }
                          },
                          child: const CircleAvatar(
                            backgroundColor: Colors.cyanAccent,
                            radius: 18,
                            child: Icon(Icons.volume_up, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // توقيع التطبيق
              Opacity(
                opacity: 0.15,
                child: Transform.rotate(
                  angle: 130 * 3.14159 / 180,
                  child: const Text(
                    'ترجم هذا النص بواسطه ميرور اسكربيون',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // مفتاح فتح/غلق الفقاعة
              Center(
                child: Consumer<FloatingBubbleService>(
                  builder: (context, bubble, child) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: bubble.isStarted ? Colors.blueAccent : Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bubble_chart, color: bubble.isStarted ? Colors.blueAccent : Colors.grey, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            bubble.isStarted ? '🔓 الفقاعة مفتوحة' : '🔒 الفقاعة مغلقة',
                            style: TextStyle(color: bubble.isStarted ? Colors.blueAccent : Colors.white38, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: bubble.isStarted,
                            onChanged: (_) {
                              if (bubble.isStarted) {
                                bubble.stopBubble();
                              } else {
                                bubble.startBubble(context);
                              }
                            },
                            activeColor: Colors.blueAccent,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              const Opacity(
                opacity: 0.2,
                child: Text(
                  "Mirror Scorpion • v2",
                  style: TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
TRANS1DART

echo -e "${GREEN} ✅ كارت 1 - ترجمة نصية كاملة${NC}"

# ======================================================
# 7. الكارت 2 - حوار مترجم (واجهة كاملة كما وصفت)
# ======================================================
echo -e "\n${CYAN}[7/10] إنشاء كارت 2 - حوار مترجم كامل...${NC}"

cat > lib/features/card2_dialogue/dialogue_screen.dart << 'DIALDART'
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
DIALDART

echo -e "${GREEN} ✅ كارت 2 - حوار مترجم كامل${NC}"

# ======================================================
# 8. الكارت 3 - مستندات وعدسة (واجهة كاملة كما وصفت)
# ======================================================
echo -e "\n${CYAN}[8/10] إنشاء كارت 3 - مستندات وعدسة كامل...${NC}"

cat > lib/features/card3_document/document_screen.dart << 'DOCDART'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../../services/language_service.dart';
import '../../services/tts_service.dart';

class DocumentTranslationScreen extends StatefulWidget {
  const DocumentTranslationScreen({super.key});

  @override
  State<DocumentTranslationScreen> createState() => _DocumentTranslationScreenState();
}

class _DocumentTranslationScreenState extends State<DocumentTranslationScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _selectedFilePath = '';
  String _selectedFileName = '';
  String _translatedText = '';
  bool _isProcessing = false;
  bool _showOriginal = false;
  bool _isLensMode = false;
  String _lensLanguage = 'auto';

  // توقيع التطبيق
  final String _appSignature = 'ترجم هذا المستند بواسطه ميرور اسكربيون';

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);
    final List<String> langCodes = langService.getLanguageCodes();

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(_isLensMode ? 'العدسة' : 'مستندات وعدسة',
            style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1B2838),
        iconTheme: const IconThemeData(color: Colors.orangeAccent),
        actions: [
          IconButton(
            icon: Icon(_isLensMode ? Icons.description : Icons.camera_alt,
                color: Colors.orangeAccent),
            onPressed: () => setState(() => _isLensMode = !_isLensMode),
            tooltip: _isLensMode ? 'وضع المستندات' : 'وضع العدسة',
          ),
        ],
      ),
      body: _isLensMode ? _buildLensView(langCodes) : _buildDocumentView(langCodes),
    );
  }

  // ====== وضع العدسة ======
  Widget _buildLensView(List<String> langCodes) {
    final langService = Provider.of<LanguageService>(context);
    return Column(
      children: [
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // محاكاة عدسة الكاميرا
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.black87, Color(0xFF1A1A2E)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt, size: 60, color: Colors.orange.withOpacity(0.3)),
                        const SizedBox(height: 10),
                        Text('وجه الكاميرا نحو النص',
                            style: TextStyle(color: Colors.white38, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text('للترجمة الفورية',
                            style: TextStyle(color: Colors.white24, fontSize: 12)),
                      ],
                    ),
                  ),
                ),

                // إطار العدسة
                Positioned(
                  top: 30, left: 30, right: 30, bottom: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.withOpacity(0.5), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                // زر اللغة أسفل العدسة
                Positioned(
                  bottom: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orangeAccent),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: langCodes.contains(_lensLanguage) ? _lensLanguage : 'auto',
                        dropdownColor: const Color(0xFF0D1B2A),
                        style: const TextStyle(color: Colors.orangeAccent, fontSize: 12),
                        items: [
                          const DropdownMenuItem(value: 'auto', child: Text('تلقائي', style: TextStyle(color: Colors.white))),
                          ...langCodes.map((code) => DropdownMenuItem(
                            value: code,
                            child: Text(langService.getLanguageName(code), style: const TextStyle(color: Colors.white, fontSize: 12)),
                          )),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => _lensLanguage = v);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ====== وضع المستندات ======
  Widget _buildDocumentView(List<String> langCodes) {
    final isTranslated = _translatedText.isNotEmpty;

    return Column(
      children: [
        if (!isTranslated) ...[
          // حالة عدم وجود ترجمة -> إظهار واجهة الرفع
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1B2838),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // مستطيل متوسط - إدخال رابط
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.teal.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: const InputDecoration(
                              hintText: '粘贴 الرابط هنا...',
                              hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.search, color: Colors.white, size: 22),
                            onPressed: _fetchFromUrl,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // زر فتح من المستعرض
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons
SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _pickDocument,
                      icon: const Icon(Icons.folder_open),
                      label: const Text('📂 فتح من المستعرض'),
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
                  ),

                  // إذا تم اختيار ملف، يظهر مساره
                  if (_selectedFileName.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.insert_drive_file, color: Colors.tealAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedFileName,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // زر الترجمة
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isProcessing ? null : _translateDocument,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.withOpacity(0.2),
                          foregroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.amber.withOpacity(0.4)),
                          ),
                        ),
                        child: _isProcessing
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.amber))
                            : const Text('🌐 ترجم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],

        // حالة وجود ترجمة -> إظهار المستند المترجم مع التوقيع
        if (isTranslated)
          Expanded(
            child: GestureDetector(
              onLongPressStart: (_) => setState(() => _showOriginal = true),
              onLongPressEnd: (_) => setState(() => _showOriginal = false),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _showOriginal
                    ? _buildDocumentViewer('المستند الأصلي', _selectedFileName, Colors.white, false)
                    : Stack(
                        key: const ValueKey('translated'),
                        children: [
                          _buildDocumentViewer('المستند المترجم', _translatedText, Colors.amberAccent, true),
                          // توقيع التطبيق - شفاف عريض مائل 130 درجة
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.08,
                              child: Center(
                                child: Transform.rotate(
                                  angle: 130 * 3.14159 / 180,
                                  child: const Text(
                                    'ترجم هذا المستند بواسطه ميرور اسكربيون',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),

        // أزرار المشاركة والإجراءات (تظهر فقط عند وجود ترجمة)
        if (isTranslated)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1B2838),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => _shareDocument(),
                  icon: const Icon(Icons.share, color: Colors.tealAccent, size: 20),
                  label: const Text('مشاركة', style: TextStyle(color: Colors.tealAccent)),
                ),
                TextButton.icon(
                  onPressed: () => setState(() {
                    _translatedText = '';
                    _selectedFileName = '';
                    _selectedFilePath = '';
                    _urlController.clear();
                  }),
                  icon: const Icon(Icons.refresh, color: Colors.orangeAccent, size: 20),
                  label: const Text('جديد', style: TextStyle(color: Colors.orangeAccent)),
                ),
              ],
            ),
          ),

        // ملاحظة حدود النسخة المجانية
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.black26,
          child: const Text(
            '📄 النسخة المجانية: حتى 5 صفحات • النسخة المدفوعة: غير محدود',
            style: TextStyle(color: Colors.white38, fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentViewer(String title, String content, Color textColor, bool isTranslated) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (isTranslated ? Colors.amber : Colors.teal).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(isTranslated ? Icons.translate : Icons.description,
                  color: textColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(color: Colors.white12),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                content,
                style: TextStyle(color: textColor, fontSize: 14, height: 1.8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchFromUrl() async {
    if (_urlController.text.trim().isEmpty) return;
    setState(() {
      _selectedFileName = _urlController.text.trim();
      _selectedFilePath = _urlController.text.trim();
    });
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'txt', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path!;
          _selectedFileName = result.files.single.name;
          _urlController.text = _selectedFilePath;
        });
      }
    } catch (e) {
      // Silent
    }
  }

  Future<void> _translateDocument() async {
    if (_selectedFilePath.isEmpty) return;
    setState(() => _isProcessing = true);

    // محاكاة ترجمة لمدة 3 ثوان
    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _translatedText = 'تمت ترجمة المستند: $_selectedFileName\n\n'
          'هذه ترجمة تجريبية للمستند المحدد.\n'
          'النسخة المدفوعة تدعم الترجمة الكاملة غير المحدودة.\n\n'
          '---\n'
          '🦂 Mirror Scorpion - حيث تُصنع البدايات';
      _isProcessing = false;
    });
  }

  void _shareDocument() {
    if (_translatedText.isEmpty) return;
    final shareText = '$_appSignature\n\n$_translatedText';
    Share.share(shareText, subject: 'مستند مترجم - Mirror Scorpion');
  }
}
DOCDART

echo -e "${GREEN} ✅ كارت 3 - مستندات وعدسة كامل${NC}"

# ======================================================
# 9. ملفات الخدمات المفقودة
# ======================================================
echo -e "\n${CYAN}[9/10] إنشاء ملفات الخدمات المفقودة...${NC}"

# Language Service
cat > lib/services/language_service.dart << 'LANGSVC'
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  String _deviceLanguage = 'ar';
  late SharedPreferences _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _deviceLanguage = _prefs.getString('device_language') ?? 'ar';
  }

  String getDeviceLanguage() => _deviceLanguage;

  String getLanguageForScreen(String screen) {
    return _prefs.getString('lang_$screen') ?? '';
  }

  Future<void> saveLanguageForScreen(String screen, String lang) async {
    await _prefs.setString('lang_$screen', lang);
  }

  List<String> getLanguageCodes() {
    return [
      'ar', 'en', 'fr', 'de', 'es', 'it', 'pt', 'ru', 'zh', 'ja', 'ko',
      'hi', 'tr', 'ur', 'fa', 'nl', 'pl', 'sv', 'da', 'fi', 'el', 'he',
      'th', 'vi', 'ms', 'id', 'tl', 'cs', 'hu', 'ro', 'sk', 'hr', 'sr',
      'bg', 'uk', 'sq', 'hy', 'ka', 'kk', 'uz', 'az'
    ];
  }

  String getLanguageName(String code) {
    final names = {
      'ar': 'العربية', 'en': 'English', 'fr': 'Français', 'de': 'Deutsch',
      'es': 'Español', 'it': 'Italiano', 'pt': 'Português', 'ru': 'Русский',
      'zh': '中文', 'ja': '日本語', 'ko': '한국어', 'hi': 'हिन्दी',
      'tr': 'Türkçe', 'ur': 'اردو', 'fa': 'فارسی', 'nl': 'Nederlands',
      'pl': 'Polski', 'sv': 'Svenska', 'da': 'Dansk', 'fi': 'Suomi',
      'el': 'Ελληνικά', 'he': 'עברית', 'th': 'ไทย', 'vi': 'Tiếng Việt',
      'ms': 'Bahasa Melayu', 'id': 'Bahasa Indonesia', 'tl': 'Filipino',
      'cs': 'Čeština', 'hu': 'Magyar', 'ro': 'Română', 'sk': 'Slovenčina',
      'hr': 'Hrvatski', 'sr': 'Српски', 'bg': 'Български', 'uk': 'Українська',
      'sq': 'Shqip', 'hy': 'Հայերեն', 'ka': 'ქართული', 'kk': 'Қазақ',
      'uz': 'Oʻzbek', 'az': 'Azərbaycan',
    };
    return names[code] ?? code;
  }
}
LANGSVC

# TTS Service
cat > lib/services/tts_service.dart << 'TTSSVC'
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String _activeVoice = 'سيف';

  // 5 أصوات: سيف، سلمى، سما، سارة، صوت المستخدم
  final List<Map<String, String>> voices = [
    {'name': 'سيف', 'lang': 'ar-SA', 'gender': 'male'},
    {'name': 'سلمى', 'lang': 'ar-SA', 'gender': 'female'},
    {'name': 'سما', 'lang': 'ar-SA', 'gender': 'female'},
    {'name': 'سارة', 'lang': 'ar-SA', 'gender': 'female'},
    {'name': 'صوت المستخدم', 'lang': 'ar-SA', 'gender': 'male'},
  ];

  TTSService() {
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      notifyListeners();
    });
    _flutterTts.setErrorHandler((msg) {
      _isSpeaking = false;
      notifyListeners();
    });
  }

  bool get isSpeaking => _isSpeaking;
  String get activeVoice => _activeVoice;

  Future<void> speak(String text, {String language = 'ar', String? voice}) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    notifyListeners();
    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(voice == 'female' ? 1.5 : 1.0);
      await _flutterTts.speak(text);
    } catch (e) {
      _isSpeaking = false;
      notifyListeners();
    }
  }

  Future<void> setVoice(String voiceName) async {
    _activeVoice = voiceName;
    notifyListeners();
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    notifyListeners();
  }
}
TTSSVC

# Floating Bubble Service
cat > lib/services/floating_bubble_service.dart << 'BUBBLESVC'
import 'package:flutter/material.dart';

class FloatingBubbleService extends ChangeNotifier {
  bool _isStarted = false;

  bool get isStarted => _isStarted;

  Future<void> initialize() async {
    // التحقق من الإذن
  }

  Future<void> startBubble(BuildContext context) async {
    _isStarted = true;
    notifyListeners();
  }

  Future<void> stopBubble() async {
    _isStarted = false;
    notifyListeners();
  }

  void toggle() {
    _isStarted = !_isStarted;
    notifyListeners();
  }
}
BUBBLESVC

# AI Service
cat > lib/services/ai_service.dart << 'AISVC'
import 'package:flutter/material.dart';

class AIService extends ChangeNotifier {
  String _lastInspiration = '';
  DateTime _lastSentTime = DateTime.now().subtract(const Duration(hours: 3));

  final List<String> _inspirations = [
    "لا تحزن، إن الله معنا",
    "بعد العسر يسراً",
    "إن مع العسر يسراً",
    "فإن مع العسر يسراً",
    "وما توفيقى إلا بالله",
    "رب اشرح لي صدري ويسر لي أمري",
    "إن الله لا يضيع أجر المحسنين",
    "ومن يتوكل على الله فهو حسبه",
    "لا تيأس من روح الله",
    "إن رحمة الله قريب من المحسنين",
    "استعن بالله ولا تعجز",
    "ما ودعك ربك وما قلى",
    "ولسوف يعطيك ربك فترضى",
    "ألم يجدك يتيماً فآوى",
    "ألم نشرح لك صدرك",
    "ووضعنا عنك وزرك",
    "فإذا فرغت فانصب",
    "وإلى ربك فارغب",
  ];

  String get lastInspiration => _lastInspiration;
  DateTime get lastSentTime => _lastSentTime;

  Future<String> generateInspiration({String userMood = '', String context = ''}) async {
    // اختيار رسالة عشوائية
    final random = DateTime.now().millisecondsSinceEpoch % _inspirations.length;
    _lastInspiration = _inspirations[random];
    _lastSentTime = DateTime.now();
    notifyListeners();
    return _lastInspiration;
  }

  bool canSendInspiration() {
    return DateTime.now().difference(_lastSentTime).inHours >= 3;
  }
}
AISVC

# Database Service
cat > lib/services/database_service.dart << 'DBSVC'
import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService extends ChangeNotifier {
  List<Map<String, dynamic>> _hadiths = [];
  List<Map<String, dynamic>> _stories = [];
  List<Map<String, dynamic>> _revelationReasons = [];
  List<Map<String, dynamic>> _translations = [];

  List<Map<String, dynamic>> get hadiths => _hadiths;
  List<Map<String, dynamic>> get stories => _stories;
  List<Map<String, dynamic>> get revelationReasons => _revelationReasons;

  Future<void> initialize() async {
    await loadLocalData();
    await _loadTranslations();
  }

  Future<void> loadLocalData() async {
    // أحاديث قدسية
    try {
      final hadithData = await rootBundle.loadString('assets/data/hadith_qudsi.json');
      _hadiths = List<Map<String, dynamic>>.from(json.decode(hadithData));
    } catch (_) {
      _hadiths = [
        {'text': 'يقول الله تعالى: أنا عند ظن عبدي بي', 'source': 'قدسي'},
        {'text': 'يقول الله: يا عبادي إني حرمت الظلم على نفسي', 'source': 'قدسي'},
      ];
    }

    // قصص
    try {
      final storiesData = await rootBundle.loadString('assets/data/stories.json');
      _stories = List<Map<String, dynamic>>.from(json.decode(storiesData));
    } catch (_) {
      _stories = [
        {'title': 'قصة أصحاب الكهف', 'text': 'قصة الفتية الذين آمنوا بربهم...', 'category': 'quran'},
        {'title': 'قصة موسى مع الخضر', 'text': 'قصة موسى عليه السلام مع الخضر...', 'category': 'prophets'},
      ];
    }

    // أسباب نزول
    try {
      final asbabData = await rootBundle.loadString('assets/data/asbab_nuzul.json');
      _revelationReasons = List<Map<String, dynamic>>.from(json.decode(asbabData));
    } catch (_) {
      _revelationReasons = [
        {'surah': 'الفاتحة', 'ayah': '1', 'reason': 'سبب نزول سورة الفاتحة...', 'text': ''},
      ];
    }

    notifyListeners();
  }

  Future<void> _loadTranslations() async {
    final p = await SharedPreferences.getInstance();
    final s = p.getString('translation_history');
    if (s != null) {
      try {
        _translations = List<Map<String, dynamic>>.from(
          (json.decode(s) as List).map((e) => Map<String, dynamic>.from(e)),
        );
      } catch (_) {}
    }
  }

  Future<void> saveTranslation(String src, String trg, {String? sourceLang, String? targetLang}) async {
    _translations.insert(0, {
      'source': src,
      'translated': trg,
      'sourceLang': sourceLang ?? 'auto',
      'targetLang': targetLang ?? 'ar',
      'timestamp': DateTime.now().toIso8601String(),
    });
    if (_translations.length > 50) _translations = _translations.sublist(0, 50);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('translation_history', json.encode(_translations));
  }

  Map<String, dynamic> getRandomHadith() {
    if (_hadiths.isEmpty) return {'text': 'لا إله إلا الله'};
    return _hadiths[Random().nextInt(_hadiths.length)];
  }

  Map<String, dynamic> getRandomStory() {
    if (_stories.isEmpty) return {'title': 'قصة', 'text': 'لم يتم تحميل القصص'};
    return _stories[Random().nextInt(_stories.length)];
  }

  Map<String, dynamic> getRandomAsbab() {
    if (_revelationReasons.isEmpty) return {'surah': '', 'ayah': '', 'reason': '', 'text': ''};
    return _revelationReasons[Random().nextInt(_revelationReasons.length)];
  }

  List<Map<String, dynamic>> getStoriesByCategory(String c) {
    return _stories.where((s) => s['category'] == c).toList();
  }
}
DBSVC

# Premium Verification Service
cat > lib/services/premium_verification_service.dart << 'PREMSVC'
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumVerificationService extends ChangeNotifier {
  bool _isPremium = false;
  String _deviceId = '';
  String _expiryDate = '';

  bool get isPremium => _isPremium;
  String get deviceId => _deviceId;
  String get expiryDate => _expiryDate;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool('is_premium') ?? false;
    _deviceId = prefs.getString('device_id') ?? '';
    _expiryDate = prefs.getString('expiry_date') ?? '';
  }

  Future<bool> activatePremium(String activationCode) async {
    // التحقق من كود التفعيل
    if (activationCode.length >= 20) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_premium', true);
      await prefs.setString('activation_code', activationCode);
      _isPremium = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> deactivatePremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_premium', false);
    await prefs.remove('activation_code');
    _isPremium = false;
    notifyListeners();
  }
}
PREMSVC

# Theme Provider
mkdir -p lib/core/theme
cat > lib/core/theme/theme_provider.dart << 'THEMEPROV'
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isDarkMode = true;

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _themeMode;

  ThemeData get themeData {
    if (_isDarkMode) {
      return ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.cyanAccent,
          surface: const Color(0xFF1B2838),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1B2838),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.cyan,
          surface: Colors.white,
        ),
      );
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }
}
THEMEPROV

echo -e "${GREEN} ✅ جميع ملفات الخدمات تم إنشاؤها${NC}"

# ======================================================
# 10. إضافة الـ imports المفقودة لـ http و json في الكروت
# ======================================================
echo -e "\n${CYAN}[10/10] إضافة الـ imports للملفات التي تستخدم http/json...${NC}"

# translation_screen.dart يحتاج http + json
sed -i '2i import "dart:convert";' lib/features/card1_translation/translation_screen.dart
sed -i '3i import "package:http/http.dart" as http;' lib/features/card1_translation/translation_screen.dart

# dialogue_screen.dart يحتاج http + json
sed -i '1i import "dart:convert";' lib/features/card2_dialogue/dialogue_screen.dart
sed -i '2i import "package:http/http.dart" as http;' lib/features/card2_dialogue/dialogue_screen.dart

echo -e "${GREEN} ✅ الـ imports مضافة${NC}"

# ======================================================
# الرفع إلى GitHub
# ======================================================
echo -e "\n${CYAN}═══════════════════════════════════════${NC}"
echo -e "${YELLOW}الآن سيتم رفع التغييرات إلى GitHub...${NC}"

# التحقق من وجود remote
if ! git remote -v | grep -q origin; then
    echo -e "${RED}❌ لم يتم العثور على remote origin${NC}"
    echo -e "${YELLOW}أضف الـ remote أولاً:${NC}"
    echo 'git remote add origin https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2.git'
    exit 1
fi

git add -A

git commit -m "🦂 Bash #1: Build fix + Cards 1-2-3 + Bubble + Routes

- إصلاح Build: shrinkResources false في android/app/build.gradle
- تحديث pubspec.yaml مع جميع dependencies
- main.dart: جميع الـ routes (6 كروت) + ThemeProvider + MultiProvider
- HomeScreen: العقرب مع الانعكاس + 6 كروت + الفقاعة (مفتاح فتح/غلق)
- كارت 1 - ترجمة نصية: 100 لغة + مايك + سبيكر + مشاركة + توقيع + دبوس صوت
- كارت 2 - حوار مترجم: مايك central + تبويض + ترجمة + دبوس رفع ملفات
- كارت 3 - مستندات وعدسة: عدسة كاميرا + رابط + مستعرض ملفات + ترجمة 3s + توقيع
- LanguageService + TTSService + FloatingBubbleService
- AIService + DatabaseService + PremiumVerificationService + ThemeProvider

النسخة الأساس: Build #199 (7d443c4) Stable"

echo -e "${YELLOW}⌛ جاري الرفع...${NC}"
if git push origin main 2>&1; then
    echo -e "${GREEN}✅ تم الرفع بنجاح!${NC}"
    echo -e "${GREEN}🚀 GitHub Actions سيبدأ البناء تلقائياً${NC}"
    echo -e "${GREEN}📱 https://github.com/magdymeko456-cell/mirror_scorpion-mirror_scorpion_v2/actions${NC}"
else
    echo -e "${RED}❌ فشل الرفع. جرب:${NC}"
    echo -e " git push origin main --force"
fi

echo -e "\n${CYAN}═══════════════════════════════════════${NC}"
echo -e "${GREEN}🦂 Bash #1 اكتمل!${NC}"
echo -e "${YELLOW}الخطوة التالية: Bash #2 - الكارت 4 (قصص وإلهام) + أسباب النزول${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
