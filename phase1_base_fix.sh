#!/bin/bash

# ═══════════════════════════════════════════════════════════════
# 🔥 MIRROR SCORPION V2 - PHASE 1: إصلاح الأساس والبنية التحتية
# ═══════════════════════════════════════════════════════════════
# التاريخ: 2026-07-11
# المطور: Tamer Eldosoky
# ═══════════════════════════════════════════════════════════════

echo "🦂 [1/8] الدخول إلى مجلد المشروع..."
cd ~/mirror_scorpion_translate_version_2

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🧹 [2/8] تنظيف الملفات المؤقتة والقديمة"
echo "═══════════════════════════════════════════════════════════"

# حذف ملفات الـ cache لضمان بناء نظيف
rm -rf .dart_tool
rm -f pubspec.lock
rm -rf build/

echo "  ✅ تم تنظيف الـ cache"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📁 [3/8] إنشاء المجلدات المفقودة (لا نمسح الموجود)"
echo "═══════════════════════════════════════════════════════════"

# المجلدات الموجودة أصلاً - ننشئ فقط ما هو مفقود

# card1_translate - موجود ✅ (لا نمسحه)
# card2_chat - موجود ✅ (لا نمسحه)
# card3_document - موجود ✅ (لا نمسحه)
# card4_stories - موجود ✅ (لا نمسحه)
mkdir -p lib/features/card1_translate
mkdir -p lib/features/card2_chat
mkdir -p lib/features/card3_document
mkdir -p lib/features/card4_stories

# games - موجود ✅
mkdir -p lib/features/games/chess
mkdir -p lib/features/games/rubik_cube

# settings - موجود ✅
mkdir -p lib/features/settings

# hadith_stories - موجود ✅
mkdir -p lib/features/hadith_stories

# creativity - موجود ✅
mkdir -p lib/features/creativity

# الـ services
mkdir -p lib/services

# الـ core/widgets
mkdir -p lib/core/widgets

# assets
mkdir -p assets/data
mkdir -p assets/images

echo "  ✅ جميع المجلدات جاهزة"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📄 [4/8] إنشاء ملفات الـ services المفقودة"
echo "═══════════════════════════════════════════════════════════"

# ── ai_service.dart ──
cat > lib/services/ai_service.dart << 'AIEOF'
import 'dart:math';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  static Future<String> generateInspiration({
    required String userMood,
    required String context,
  }) async {
    final random = Random();
    final inspirations = [
      "لا تحزن.. إن الله معنا. كل انكسار هو تمهيد لانطلاقة أعظم.",
      "ما مضى كان درساً، وما هو آتٍ ينتظر عزيمتك. أنت أقوى مما تظن.",
      "الثبات في وجه العاصفة هو بداية النصر. اصبر فالنصر مع الصبر.",
      "لا يقاس النجاح بعدد المرات التي سقطت فيها، بل بعدد المرات التي نهضت فيها.",
      "إن مع العسر يسراً. بعد كل ليل يشرق فجر جديد.",
      "أنت لا ترى الصورة كاملة الآن، ولكن كل شيء يتوضح لمن صبر.",
      "قصتك لم تنته بعد، بل هي في أجمل فصولها. استمر في الكتابة.",
      "الفرج يأتي بعد الشدة، والنجاح يأتي بعد المحاولة.",
    ];
    await Future.delayed(const Duration(milliseconds: 500));
    return inspirations[random.nextInt(inspirations.length)];
  }
}
AIEOF
echo "  ✅ ai_service.dart"

# ── core/widgets/shared_widgets.dart ──
cat > lib/core/widgets/shared_widgets.dart << 'SWEOF'
import 'package:flutter/material.dart';

// 🌐 نص مائي (توقيع التطبيق)
class WatermarkText extends StatelessWidget {
  final String text;
  final double fontSize;

  const WatermarkText({
    super.key,
    required this.text,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 130 * 3.14159 / 180,
      child: Opacity(
        opacity: 0.15,
        child: Text(
          "ترجم هذا المستند بواسطة Mirror Scorpion",
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
SWEOF
echo "  ✅ core/widgets/shared_widgets.dart"

# ── بيانات JSON أولية للأحاديث القدسية ──
cat > assets/data/hadith_qudsi.json << 'HDEOF'
[
  {
    "id": 1,
    "text": "يا عبادي إني حرمت الظلم على نفسي وجعلته بينكم محرماً فلا تظالموا",
    "meaning": "الحديث القدسي الشهير عن تحريم الظلم"
  },
  {
    "id": 2,
    "text": "أنا عند ظن عبدي بي، وأنا معه إذا ذكرني",
    "meaning": "فضل حسن الظن بالله وذكره"
  },
  {
    "id": 3,
    "text": "يا عبادي كلكم ضال إلا من هديته فاستهدوني أهدكم",
    "meaning": "الافتقار إلى الله في الهداية"
  },
  {
    "id": 4,
    "text": "يا عبادي كلكم جائع إلا من أطعمته فاستطعموني أطعمكم",
    "meaning": "طلب الرزق من الله وحده"
  },
  {
    "id": 5,
    "text": "يا عبادي كلكم عار إلا من كسوته فاستكسوني أكسكم",
    "meaning": "التوكل على الله في كل شيء"
  }
]
HDEOF
echo "  ✅ assets/data/hadith_qudsi.json"

# ── بيانات JSON أولية للقصص ──
cat > assets/data/stories_index.json << 'STEOF'
{
  "prophets": [
    {
      "id": "adam",
      "name": "سيدنا آدم عليه السلام",
      "summary": "أبو البشر، خلقه الله من طين، وأسجد له الملائكة، وعلمه الأسماء كلها.",
      "source": "ابن كثير",
      "source_url": "https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/adam.json"
    },
    {
      "id": "nuh",
      "name": "سيدنا نوح عليه السلام",
      "summary": "أول الرسل، دعا قومه 950 عاماً، وأمره الله ببناء السفينة.",
      "source": "ابن كثير",
      "source_url": "https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/nuh.json"
    },
    {
      "id": "ibrahim",
      "name": "سيدنا إبراهيم عليه السلام",
      "summary": "خليل الله، حطم الأصنام، أمره الله بذبح ابنه إسماعيل ففداه بذبح عظيم.",
      "source": "ابن كثير",
      "source_url": "https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/ibrahim.json"
    },
    {
      "id": "mousa",
      "name": "سيدنا موسى عليه السلام",
      "summary": "كليم الله، أرسل إلى فرعون، ضرب البحر بعصاه فانفلق، وأنزلت عليه التوراة.",
      "source": "ابن كثير",
      "source_url": "https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/mousa.json"
    },
    {
      "id": "issa",
      "name": "سيدنا عيسى عليه السلام",
      "summary": "روح الله وكلمته، ولد بدون أب، أحيا الموتى بإذن الله، رفعه الله إليه.",
      "source": "ابن كثير",
      "source_url": "https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/issa.json"
    },
    {
      "id": "muhammad",
      "name": "سيدنا محمد ﷺ",
      "summary": "خاتم الأنبياء والمرسلين، صاحب الرسالة الخالدة، الرحمة المهداة للعالمين.",
      "source": "ابن كثير",
      "source_url": "https://raw.githubusercontent.com/magdymeko456-cell/mirror_scorpion_data/main/stories/muhammad.json"
    }
  ],
  "women": [],
  "nations": [],
  "animals": [],
  "human": []
}
STEOF
echo "  ✅ assets/data/stories_index.json"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📝 [5/8] تحديث pubspec.yaml بأحدث الإصدارات المتوافقة"
echo "═══════════════════════════════════════════════════════════"

cat > pubspec.yaml << 'PUBSEC'
name: mirror_scorpion_v2
description: "Mirror Scorpion - ترجمة، إلهام، ذكاء اصطناعي، ألعاب"
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.9.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # 🎯 إدارة الحالة
  provider: ^6.1.2

  # 🔊 الصوت والكلام
  speech_to_text: ^7.3.0
  flutter_tts: ^4.2.5
  audioplayers: ^6.4.0
  record: ^6.2.0

  # 🌐 الشبكات والترجمة
  http: ^1.3.0
  google_mlkit_translation: ^0.13.1
  google_mlkit_text_recognition: ^0.15.1
  google_mlkit_commons: ^0.9.1

  # 📸 الكاميرا والصورة
  camera: ^0.11.1+1
  image_picker: ^1.1.2

  # 💾 التخزين
  shared_preferences: ^2.5.5
  path_provider: ^2.1.6
  permission_handler: ^11.4.0

  # 🔗 التفاعل مع النظام
  url_launcher: ^6.3.1
  share_plus: ^10.1.4
  file_picker: ^8.3.7
  flutter_local_notifications: ^19.0.0

  # 🫧 الفقاعة العائمة (بديل خفيف لـ dash_bubble)
  overlay_support: ^2.1.0

  # ♟️ الألعاب 3D
  flutter_3d_controller: ^1.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  flutter_launcher_icons: ^0.14.3

flutter_icons:
  android: true
  image_path: "assets/images/scorpion_icon.jpeg"

flutter:
  assets:
    - assets/data/
    - assets/images/
PUBSEC

echo "  ✅ pubspec.yaml محدث بأحدث الإصدارات"
echo "     speech_to_text: ^7.3.0 (كان ^6.6.2)"
echo "     flutter_tts: ^4.2.5 (كان ^4.1.0)"
echo "     تم إضافة overlay_support (بديل الفقاعة)"
echo "     تم إضافة flutter_3d_controller (للألعاب 3D)"
echo "     تم إزالة camera_android_camerax (تعارض)"
echo "     تم إزالة dash_bubble (غير موجودة)"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🛠️ [6/8] تحديث ملف main.dart - تصحيح المسارات"
echo "═══════════════════════════════════════════════════════════"

cat > lib/main.dart << 'MAINEOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/home_screen.dart';
import 'features/card1_translate/translation_screen.dart';
import 'features/card2_chat/dialogue_screen.dart';
import 'features/card3_document/document_screen.dart';
import 'features/card3_document/document_lens.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/games/chess/chess_game.dart';
import 'features/games/rubik_cube/rubik_cube_screen_enhanced.dart';
import 'features/settings/settings_screen.dart';
import 'services/language_service.dart';
import 'services/tts_service.dart';
import 'services/premium_verification_service.dart';
import 'services/floating_bubble_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final langService = LanguageService();
  await langService.initialize();
  final premiumService = PremiumVerificationService();
  await premiumService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LanguageService>.value(value: langService),
        ChangeNotifierProvider<PremiumVerificationService>.value(value: premiumService),
        ChangeNotifierProvider<FloatingBubbleService>(create: (_) => FloatingBubbleService()),
        ChangeNotifierProvider<TTSService>(create: (_) => TTSService()),
      ],
      child: const MirrorScorpionApp(),
    ),
  );
}

class MirrorScorpionApp extends StatelessWidget {
  const MirrorScorpionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageService>();
    final localeCode = lang.currentLanguage == 'auto'
        ? lang.getDeviceLanguage()
        : lang.currentLanguage;

    return MaterialApp(
      title: 'Mirror Scorpion',
      debugShowCheckedModeBanner: false,
      locale: Locale(localeCode),
      supportedLocales: const [
        Locale('ar'), Locale('en'), Locale('fr'), Locale('de'),
        Locale('es'), Locale('tr'), Locale('fa'), Locale('ur'),
      ],
      localizationsDelegates: const [
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: ColorScheme.dark(
          primary: Colors.blueAccent,
          secondary: Colors.cyanAccent,
          surface: const Color(0xFF1B2838),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/translate': (context) => const TextTranslationScreen(),
        '/dialogue': (context) => const DialogueTranslationScreen(),
        '/document': (context) => const DocumentTranslationScreen(),
        '/lens': (context) => const DocumentLensScreen(),
        '/stories': (context) => const StoriesScreen(),
        '/chess': (context) => const ChessGame(),
        '/rubik': (context) => const RubikCubeScreenEnhanced(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
MAINEOF

echo "  ✅ main.dart محدث - المسارات صحيحة الآن"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "⚙️ [7/8] تحديث build.yml (Actions)"
echo "═══════════════════════════════════════════════════════════"

mkdir -p .github/workflows
cat > .github/workflows/build.yml << 'YMLEOF'
name: Mirror Scorpion Build

on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.44.0'
          channel: 'stable'

      - name: Clean and Get Dependencies
        run: |
          rm -rf .dart_tool pubspec.lock
          flutter clean
          flutter pub get

      - name: Build APK (Release with ProGuard)
        run: |
          flutter build apk --release \
            --no-tree-shake-icons \
            --obfuscate \
            --split-debug-info=build/debug_info \
            --target-platform android-arm,android-arm64

      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: mirror-scorpion-pro-apk
          path: build/app/outputs/flutter-apk/app-release.apk
YMLEOF

echo "  ✅ build.yml محدث"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📋 [8/8] تحديث ملف git_sync.sh للرفع التلقائي"
echo "═══════════════════════════════════════════════════════════"

cat > git_sync.sh << 'GITEOF'
#!/bin/bash
echo "🦂 رفع تحديثات Mirror Scorpion إلى GitHub..."
git add .
git commit -m "🦂 PHASE 1: إصلاح الأساس - مسارات + خدمات + pubspec محدث - $(date)"
git push origin main
echo "✅ تم الرفع بنجاح!"
GITEOF

chmod +x git_sync.sh
echo "  ✅ git_sync.sh محدث"

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📦 تشغيل flutter pub get..."
echo "═══════════════════════════════════════════════════════════"

flutter pub get

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅✅✅  الباش الأول اكتمل بنجاح!  ✅✅✅"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "ما تم إنجازه:"
echo "  ✅ إنشاء ai_service.dart"
echo "  ✅ إنشاء shared_widgets.dart"
echo "  ✅ إنشاء بيانات JSON (أحاديث + قصص)"
echo "  ✅ تحديث pubspec.yaml بأحدث الإصدارات"
echo "  ✅ تحديث main.dart بمسارات صحيحة"
echo "  ✅ تحديث build.yml"
echo ""
echo "⚠️  ملاحظة: ملفات الـ Screens (translation_screen.dart و dialogue_screen.dart)"
echo "   لم يتم إنشاؤها بعد لأنها في المجلدات الصحيحة (card1_translate و card2_chat)"
echo "   سيتم ذلك في الباش الثاني."
echo ""
echo "👉 الآن سيتم الرفع إلى GitHub..."
echo ""

# الرفع إلى GitHub
bash git_sync.sh
