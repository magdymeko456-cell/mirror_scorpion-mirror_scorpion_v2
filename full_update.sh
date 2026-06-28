#!/bin/bash

# =============================================
# Mirror Scorpion - Full Update Script
# كل التعديلات في كود واحد متكامل
# =============================================

# المتغيرات
REPO="https://github.com/magdymeko456-cell/mirror_scorpion_translate_version_2.git"
DIR="mirror_scorpion_update"

# استنساخ المستودع
git clone $REPO $DIR
cd $DIR

# =============================================
# 1. ملف main.dart - مُحدّث بالكامل
# =============================================
cat > lib/main.dart << 'MAIN_EOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/utils/r_bridge.dart';
import 'core/theme/theme_provider.dart';
import 'services/database_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/tts_service.dart';
import 'services/premium_verification_service.dart';
import 'services/language_service.dart';
import 'services/background_service.dart';
import 'services/language_download_service.dart';
import 'services/ai_enhanced_service.dart';
import 'features/home_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/about/about_app_screen.dart';
import 'features/admin/key_generator_screen.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card2_dialogue/dialogue_screen.dart';
import 'features/card3_document/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/games/chess/chess_screen.dart';
import 'features/games/rubik_cube/rubik_cube_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    initializeRVariables();
  } catch (e) {
    debugPrint('⚠ Bridge initialization warning: $e');
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final themeProvider = ThemeProvider();
  final databaseService = DatabaseService();
  final floatingBubbleService = FloatingBubbleService();
  final premiumService = PremiumVerificationService();
  final ttsService = TTSService();
  final languageService = LanguageService();
  final backgroundService = BackgroundService();
  final languageDownloadService = LanguageDownloadService();
  final aiEnhancedService = AIEnhancedService();

  try {
    debugPrint('🚀 Initializing core services...');
    await databaseService.loadAllData();
    await floatingBubbleService.initialize();
    await premiumService.initialize();
    await languageService.initialize();
    await backgroundService.initialize();
    await languageDownloadService.initialize();
    await aiEnhancedService.initialize();
    debugPrint('✅ All services initialized successfully');
  } catch (e) {
    debugPrint('⚠ Service initialization warning: $e');
  }

  // اكتشاف لغة الجهاز وضبطها كافتراضي
  final deviceLang = languageService.getDeviceLanguage();
  final supportedCodes = languageService.getLanguageCodes();
  if (supportedCodes.contains(deviceLang)) {
    await languageService.setCurrentLanguage(deviceLang);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: databaseService),
        ChangeNotifierProvider.value(value: floatingBubbleService),
        ChangeNotifierProvider.value(value: ttsService),
        ChangeNotifierProvider.value(value: premiumService),
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider.value(value: backgroundService),
        ChangeNotifierProvider.value(value: languageDownloadService),
        ChangeNotifierProvider.value(value: aiEnhancedService),
      ],
      child: const MirrorScorpionApp(),
    ),
  );
}

class MirrorScorpionApp extends StatelessWidget {
  const MirrorScorpionApp({super.key});

  @override
  Widget build(BuildContext context) {
    final langService = Provider.of<LanguageService>(context);
    final deviceLang = langService.getDeviceLanguage();
    final locale = Locale(deviceLang);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Mirror Scorpion',
          debugShowCheckedModeBanner: false,
          theme: themeProvider.themeData,
          locale: locale,
          supportedLocales: const [
            Locale('ar'),
            Locale('en'),
            Locale('fr'),
            Locale('de'),
            Locale('es'),
          ],
          localizationsDelegates: const [
            DefaultMaterialLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => const HomeScreen(),
            '/translate': (context) => const TextTranslationScreen(),
            '/dialogue': (context) => const DialogueTranslationScreen(),
            '/document': (context) => const DocumentTranslationScreen(),
            '/stories': (context) => const StoriesScreen(),
            '/chess': (context) => const ChessScreen(),
            '/rubik': (context) => const RubikCubeScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/about': (context) => const AboutAppScreen(),
            '/admin_gen': (context) => const KeyGeneratorScreen(),
          },
        );
      },
    );
  }
}
MAIN_EOF

# =============================================
# 2. ملف AI Enhanced Service - ذكاء اصطناعي متطور
# =============================================
cat > lib/services/ai_enhanced_service.dart << 'AI_ENHANCED_EOF'
import 'dart:math';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// خدمة الذكاء الاصطناعي المُحسّنة - مانوس إنتليجنس
class AIEnhancedService extends ChangeNotifier {
  static final AIEnhancedService _instance = AIEnhancedService._internal();
  factory AIEnhancedService() => _instance;
  AIEnhancedService._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;
  bool _autoInspirationEnabled = false;
  DateTime _lastInspirationTime = DateTime.now().subtract(const Duration(hours: 3));
  
  // تحليل الحالة النفسية
  String _detectedMood = 'محايد';
  String _lastStoryFocus = '';
  int _storyViewCount = 0;
  
  // قواعد بيانات للرسائل الملهمة حسب الحالة
  static const Map<String, List<String>> _moodMessages = {
    'حزين': [
      'أعلم أن الأوقات صعبة، ولكن تذكر أن الله لا يكلف نفساً إلا وسعها. أنت قادر على تخطي هذه المحنة.',
      'كل انكسار هو بداية لانطلاقة أعظم. قال تعالى: {إِنَّ مَعَ الْعُسْرِ يُسْرًا}',
      'لا تيأس، فالنور يأتي بعد الظلام. استعن بالله ولا تعجز.',
      'الدموع ليست ضعفاً، إنها دليل على أن قلبك مازال نابضاً بالحياة.',
      'تذكر: ما كان الله ليجمع بين هم الدنيا وهم الآخرة على عبد مؤمن.',
    ],
    'فرح': [
      'الحمد لله على نعمة الفرح. تذكر أن تبقى متواضعاً في نجاحك، وأن تشكر الله على ما أعطاك.',
      'الفرح الحقيقي هو في مشاركته مع الآخرين. استخدم ما وهبك الله لخدمة من حولك.',
      'لا يغرنك الفرح فتنسى الشكر، ولا يغرنك النجاح فتنسى التواضع.',
      'اجعل فرحك شكراً، ونجاحك تواضعاً، وعطاءك استمراراً.',
    ],
    'قلق': [
      'لا تقلق، فالله يدبر الأمور على أكمل وجه. توكل عليه وستجد الراحة.',
      'القلق لا يغير شيئاً، لكن الثقة بالله تغير كل شيء.',
      'خذ نفساً عميقاً. أنت قادر على التعامل مع هذا الموقف.',
      'قال تعالى: {وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ}',
    ],
    'محايد': [
      'كل يوم هو فرصة جديدة لبداية جديدة. استثمر وقتك في بناء نفسك.',
      'الوقت هو العملة الأغلى التي مُنحت للإنسان. استثمر كل ثانية.',
      'تذكّر دائماً.. قصتك لا تزال تُكتب، والنهاية لم يحن وقتها بعد.',
      'أنت أقوى مما تتصور، وأعظم مما تتخيل.',
    ],
  };

  Future initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _autoInspirationEnabled = _prefs.getBool('auto_inspiration') ?? false;
    _lastInspirationTime = DateTime.parse(
      _prefs.getString('last_inspiration_time') ?? DateTime.now().subtract(const Duration(hours: 3)).toIso8601String()
    );
    _isInitialized = true;
    notifyListeners();
  }

  bool get autoInspirationEnabled => _autoInspirationEnabled;
  String get detectedMood => _detectedMood;
  String get lastStoryFocus => _lastStoryFocus;

  Future<void> toggleAutoInspiration(bool value) async {
    _autoInspirationEnabled = value;
    await _prefs.setBool('auto_inspiration', value);
    notifyListeners();
  }

  /// يحلل مزاج المستخدم من النص
  String analyzeMood(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('حزين') || lower.contains('تعب') || lower.contains('ضيق') || 
        lower.contains('alone') || lower.contains('sad') || lower.contains('tired')) {
      return 'حزين';
    }
    if (lower.contains('فرح') || lower.contains('سعيد') || lower.contains('نجاح') || 
        lower.contains('happy') || lower.contains('success')) {
      return 'فرح';
    }
    if (lower.contains('قلق') || lower.contains('خائف') || lower.contains('worried') || 
        lower.contains('anxious') || lower.contains('afraid')) {
      return 'قلق';
    }
    return 'محايد';
  }

  /// توليد رسالة ملهمة
  Future<String> generateInspiration({required String userMood, required String context}) async {
    final mood = analyzeMood(userMood.isNotEmpty ? userMood : _detectedMood);
    _detectedMood = mood;
    final messages = _moodMessages[mood] ?? _moodMessages['محايد']!;
    final random = Random();
    await Future.delayed(Duration(milliseconds: 300 + random.nextInt(500)));
    return messages[random.nextInt(messages.length)] + '\n\n- مانوس إنتليجنس';
  }

  /// التحقق من إمكانية إرسال رسالة ملهمة (مرة كل 3 ساعات)
  bool canSendInspiration() {
    if (!_autoInspirationEnabled) return false;
    return DateTime.now().difference(_lastInspirationTime).inHours >= 3;
  }

  /// تسجيل إرسال رسالة ملهمة
  Future<void> markInspirationSent() async {
    _lastInspirationTime = DateTime.now();
    await _prefs.setString('last_inspiration_time', _lastInspirationTime.toIso8601String());
  }

  /// تتبع القصص التي يقرأها المستخدم
  Future<void> trackStoryView(String storyTitle) async {
    if (_lastStoryFocus == storyTitle) {
      _storyViewCount++;
    } else {
      _lastStoryFocus = storyTitle;
      _storyViewCount = 1;
    }
    await _prefs.setString('last_story_focus', storyTitle);
    await _prefs.setInt('story_view_count', _storyViewCount);
  }

  /// توليد فيديو من نص قصة (API simulation)
  Future<String> generateVideoFromStory(String storyText) async {
    await Future.delayed(const Duration(seconds: 3));
    return 'video_story_${DateTime.now().millisecondsSinceEpoch}.mp4';
  }

  /// الترجمة باستخدام الذكاء الاصطناعي
  Future<String> aiTranslate(String text, String targetLang) async {
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$targetLang&dt=t&q=${Uri.encodeComponent(text)}'
      );
      final http.Response response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data[0] as List).map((e) => e[0] as String).join();
      }
    } catch (e) {
      debugPrint('AI Translate error: $e');
    }
    return text;
  }
}
AI_ENHANCED_EOF

# =============================================
# 3. ملف home_screen.dart - محدث بالكامل مع العقرب والمرآة والفقاعة
# =============================================
cat > lib/features/home_screen.dart << 'HOME_SCREEN_EOF'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/widgets/shared_widgets.dart';
import '../services/floating_bubble_service.dart';
import '../services/ai_enhanced_service.dart';
import '../services/language_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _reflectionController;
  late Animation<double> _reflectionAnimation;
  bool _bubbleActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _reflectionController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _reflectionAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _reflectionController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _reflectionController.dispose();
    super.dispose();
  }

  void _toggleBubble() async {
    final service = Provider.of<FloatingBubbleService>(context, listen: false);
    if (service.isStarted) {
      await service.stopBubble();
      setState(() => _bubbleActive = false);
    } else {
      await service.startBubble(context);
      setState(() => _bubbleActive = service.isStarted);
    }
  }

  void _showAIInspiration() async {
    final aiService = Provider.of<AIEnhancedService>(context, listen: false);
    final inspiration = await aiService.generateInspiration(
      userMood: '',
      context: 'Home Screen',
    );
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 30, height: 30,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage('assets/images/scorpion_icon.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('مانوس إنتليجنس ✨', style: TextStyle(color: Colors.amber, fontSize: 16)),
          ],
        ),
        backgroundColor: const Color(0xFF1B2838),
        content: Text(inspiration, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('شكراً', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bubbleService = Provider.of<FloatingBubbleService>(context);
    final aiService = Provider.of<AIEnhancedService>(context);
    final langService = Provider.of<LanguageService>(context);
    
    bool isBubbleActive = bubbleService.isStarted;
    String deviceLang = langService.getDeviceLanguage();
    String langName = deviceLang == 'ar' ? 'العربية' : 
                       deviceLang == 'en' ? 'English' : deviceLang;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: CustomScrollView(
        slivers: [
          // Floating Bubble Toggle + AI Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // AI Inspiration Button
                  GestureDetector(
                    onTap: _showAIInspiration,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.amber.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Colors.amber, size: 24),
                    ),
                  ),
                  // Device Language Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "🌐 $langName",
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scorpion Logo + Mirror Reflection
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Mirror Reflection (above the logo)
                AnimatedBuilder(
                  animation: _reflectionAnimation,
                  builder: (context, child) {
                    return Transform.flip(
                      flipY: true,
                      child: Opacity(
                        opacity: _reflectionAnimation.value,
                        child: Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blueAccent.withOpacity(0.15),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                            image: const DecorationImage(
                              image: AssetImage('assets/images/scorpion_icon.jpeg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 5),
                // Main Scorpion Logo (pulsing)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 140, height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 25,
                              spreadRadius: 8,
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/images/scorpion_icon.jpeg'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                const Text(
                  'ميرور سكربيون',
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'حيث تُصنع البدايات',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                ),
              ],
            ),
          ),

          // Bubble Toggle Switch
          SliverToBoxAdapter(
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 15),
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

          // 6 Cards Grid
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
                _buildCard(
                  icon: Icons.translate,
                  title: 'ترجمة نصية',
                  subtitle: '100 لغة + مايك',
                  color: Colors.blueAccent,
                  onTap: () => Navigator.pushNamed(context, '/translate'),
                ),
                _buildCard(
                  icon: Icons.forum,
                  title: 'حوار مترجم',
                  subtitle: 'محادثة ثنائية فورية',
                  color: Colors.cyanAccent,
                  onTap: () => Navigator.pushNamed(context, '/dialogue'),
                ),
                _buildCard(
                  icon: Icons.document_scanner,
                  title: 'مستندات وعدسة',
                  subtitle: 'ترجمة صور وملفات',
                  color: Colors.tealAccent,
                  onTap: () => Navigator.pushNamed(context, '/document'),
                ),
                _buildCard(
                  icon: Icons.auto_stories,
                  title: 'قصص وإلهام',
                  subtitle: 'مكتبة ذكية متكاملة',
                  color: Colors.orangeAccent,
                  onTap: () => Navigator.pushNamed(context, '/stories'),
                ),
                _buildCard(
                  icon: Icons.sports_esports,
                  title: 'ألعاب 3D',
                  subtitle: 'شطرنج + روبيك',
                  color: Colors.purpleAccent,
                  onTap: () => _showGamesSelection(context),
                ),
                _buildCard(
                  icon: Icons.settings,
                  title: 'الإعدادات',
                  subtitle: 'تخصيص وترقية برو',
                  color: Colors.blueGrey,
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                ),
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
                      const WatermarkText(text: "Mirror Scorpion"),
                      const SizedBox(height: 5),
                      Text(
                        "v1.0.0 Build Successful",
                        style: TextStyle(color: Colors.white, fontSize: 10),
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

  void _showGamesSelection(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B2838),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('اختر اللعبة', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.grid_view, color: Colors.purpleAccent, size: 32),
              title: const Text('مكعب روبيك 3D', style: TextStyle(color: Colors.white)),
              subtitle: const Text('جميع طرق الحل', style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/rubik');
              },
            ),
            const Divider(color: Colors.white24),
            ListTile(
              leading: const Icon(Icons.castle, color: Colors.purpleAccent, size: 32),
              title: const Text('شطرنج 3D', style: TextStyle(color: Colors.white)),
              subtitle: const Text('لعبة شطرنج احترافية', style: TextStyle(color: Colors.white54)),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/chess');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: const Color(0xFF1B2838),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
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
HOME_SCREEN_EOF

# =============================================
# 4. ملف translation_screen.dart - محدث بالكامل مع كل التفاصيل
# =============================================
cat > lib/features/card1_translation/translation_screen.dart << 'TRANS_EOF'
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/tts_service.dart';
import '../../services/ai_enhanced_service.dart';
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
  bool _hasTranslated = false;

  final Map<String, String> _languages = {
    'af': 'Afrikaans','sq': 'Albanian','am': 'Amharic','ar': 'العربية','hy': 'Armenian','az': 'Azerbaijani',
    'eu': 'Basque','be': 'Belarusian','bn': 'Bengali','bs': 'Bosnian','bg': 'Bulgarian','ca': 'Catalan',
    'ceb': 'Cebuano','ny': 'Chichewa','zh': '中文','co': 'Corsican','hr': 'Croatian','cs': 'Czech',
    'da': 'Danish','nl': 'Dutch','en': 'English','eo': 'Esperanto','et': 'Estonian','tl': 'Filipino',
    'fi': 'Finnish','fr': 'Français','fy': 'Frisian','gl': 'Galician','ka': 'Georgian','de': 'Deutsch',
    'el': 'Greek','gu': 'Gujarati','ht': 'Haitian Creole','ha': 'Hausa','haw': 'Hawaiian','iw': 'Hebrew',
    'hi': 'Hindi','hmn': 'Hmong','hu': 'Hungarian','is': 'Icelandic','ig': 'Igbo','id': 'Indonesian',
    'ga': 'Irish','it': 'Italiano','ja': '日本語','jw': 'Javanese','kn': 'Kannada','kk': 'Kazakh',
    'km': 'Khmer','ko': '한국어','ku': 'Kurdish','ky': 'Kyrgyz','lo': 'Lao','la': 'Latin',
    'lv': 'Latvian','lt': 'Lithuanian','lb': 'Luxembourgish','mk': 'Macedonian','mg': 'Malagasy',
    'ms': 'Malay','ml': 'Malayalam','mt': 'Maltese','mi': 'Maori','mr': 'Marathi','mn': 'Mongolian',
    'my': 'Myanmar','ne': 'Nepali','no': 'Norwegian','or': 'Odia','ps': 'Pashto','fa': 'فارسی',
    'pl': 'Polish','pt': 'Português','pa': 'Punjabi','ro': 'Romanian','ru': 'Русский','sm': 'Samoan',
    'gd': 'Scots Gaelic','sr': 'Serbian','st': 'Sesotho','sn': 'Shona','sd': 'Sindhi','si': 'Sinhala',
    'sk': 'Slovak','sl': 'Slovenian','so': 'Somali','es': 'Español','su': 'Sundanese','sw': 'Swahili',
    'sv': 'Swedish','tg': 'Tajik','ta': 'Tamil','tt': 'Tatar','te': 'Telugu','th': 'ไทย',
    'tr': 'Türkçe','tk': 'Turkmen','uk': 'Ukrainian','ur': 'اردو','ug': 'Uyghur','uz': 'Uzbek',
    'vi': 'Tiếng Việt','cy': 'Welsh','xh': 'Xhosa','yi': 'Yiddish','yo': 'Yoruba','zu': 'Zulu',
  };

  @override
  void initState() {
    super.initState();
    _speechToText = stt.SpeechToText();
    _loadLastLanguage();
  }

  Future<void> _loadLastLanguage() async {
    final langService = Provider.of<LanguageService>(context, listen: false);
    final lastLang = langService.getLanguageForScreen('translation');
    if (lastLang != 'auto' && _languages.containsKey(lastLang)) {
      setState(() => _selectedLanguage = lastLang);
    }
  }

  void _onSourceChanged(String value) {
    if (_hasTranslated && value != _sourceController.text) {
      _sourceController.text = value;
      _sourceController.selection = TextSelection.fromPosition(
        TextPosition(offset: value.length),
      );
    }
    if (value.isNotEmpty && !_isTranslating) {
      _translate();
    }
    if (value.isEmpty) {
      setState(() {
        _translatedController.clear();
        _hasTranslated = false;
      });
    }
  }

  Future<void> _handleMic() async {
    if (_isListening) {
      _speechToText.stop();
      setState(() => _isListening = false);
      if (_sourceController.text.isNotEmpty) _translate();
      return;
    }

    // Clear both editors when starting new recording
    _sourceController.clear();
    _translatedController.clear();
    setState(() => _hasTranslated = false);

    bool available = await _speechToText.initialize();
    if (available) {
      setState(() => _isListening = true);
      _speechToText.listen(
        onResult: (result) {
          setState(() {
            _sourceController.text = result.recognizedWords;
          });
          if (result.finalResult) {
            setState(() => _isListening = false);
            _translate();
          }
        },
        localeId: _getLocaleForLanguage(_selectedLanguage),
      );
    }
  }

  String _getLocaleForLanguage(String lang) {
    final map = {
      'ar': 'ar_SA','en': 'en_US','fr': 'fr_FR','de': 'de_DE','es': 'es_ES','it': 'it_IT',
      'pt': 'pt_BR','ru': 'ru_RU','zh': 'zh_CN','ja': 'ja_JP','ko': 'ko_KR','tr': 'tr_TR',
      'hi': 'hi_IN','nl': 'nl_NL','sv': 'sv_SE','da': 'da_DK','pl': 'pl_PL',
    };
    return map[lang] ?? 'en_US';
  }

  Future<void> _translate() async {
    final text = _sourceController.text.trim();
    if (text.isEmpty) return;
    setState(() => _isTranslating = true);
    try {
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$_selectedLanguage&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translated = (data[0] as List).map((e) => e[0] as String).join();
        setState(() {
          _translatedController.text = translated;
          _hasTranslated = true;
        });
      }
    } catch (e) {
      debugPrint('Translation error: $e');
    }
    setState(() => _isTranslating = false);
  }

  void _shareAudio() {
    if (_translatedController.text.isEmpty) return;
    final signature = "\n\nتمت الترجمة بواسطة ميرور سكربيون";
    final content = _translatedController.text + signature;
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الترجمة مع التوقيع للمشاركة'),
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  void _copyText() {
    if (_translatedController.text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _translatedController.text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ النص المترجم')),
    );
  }

  void _speakTranslation() {
    if (_translatedController.text.isNotEmpty) {
      Provider.of<TTSService>(context, listen: false)
          .speak(_translatedController.text, language: _selectedLanguage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ترجمة نصية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF0D1B2A),
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
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Language Selector - Centered at top
              Center(
                child: Container(
                  width: 220,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedLanguage,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1B2838),
                      icon: const Icon(Icons.language, color: Colors.blueAccent),
                      items: _languages.entries.map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.value, style: const TextStyle(color: Colors.white, fontSize: 13)),
                      )).toList(),
                      onChanged: (v) {
                        setState(() => _selectedLanguage = v!);
                        Provider.of<LanguageService>(context, listen: false)
                            .saveLanguageForScreen('translation', v!);
                        if (_sourceController.text.isNotEmpty) _translate();
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Source Editor (top)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _sourceController,
                      maxLines: 6,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'اكتب النص هنا أو استخدم المايك...',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                      onChanged: _onSourceChanged,
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _isListening ? Icons.stop_circle : Icons.mic,
                            color: _isListening ? Colors.redAccent : Colors.blueAccent,
                            size: 32,
                          ),
                          onPressed: _handleMic,
                        ),
                        const Spacer(),
                        if (_sourceController.text.isNotEmpty)
                          TextButton.icon(
                            icon: const Icon(Icons.translate, color: Colors.amber, size: 20),
                            label: const Text('ترجم', style: TextStyle(color: Colors.amber)),
                            onPressed: _translate,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_isTranslating)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: CircularProgressIndicator(color: Colors.blueAccent, strokeWidth: 2),
                ),

              // Translated Editor (bottom)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _translatedController,
                      maxLines: 6,
                      readOnly: true,
                      style: const TextStyle(color: Colors.amberAccent, fontSize: 18, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        hintText: 'الترجمة ستظهر هنا...',
                        hintStyle: TextStyle(color: Colors.white24),
                        border: InputBorder.none,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Copy button (left)
                        IconButton(
                          icon: const Icon(Icons.copy, color: Colors.white70, size: 22),
                          onPressed: _copyText,
                          tooltip: 'نسخ النص المترجم',
                        ),
                        const Spacer(),
                        // Share button with signature
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.greenAccent, size: 24),
                          onPressed: _shareAudio,
                          tooltip: 'مشاركة مع توقيع ميرور سكربيون',
                        ),
                        // Speaker button
                        IconButton(
                          icon: const Icon(Icons.volume_up, color: Colors.blueAccent, size: 26),
                          onPressed: _speakTranslation,
                          tooltip: 'نطق الترجمة',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Opacity(
                opacity: 0.3,
                child: Text(
                  "Mirror Scorpion Translate",
                  style: TextStyle(color: Colors.white, letterSpacing: 2, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
TRANS_EOF

echo "✅ المرحلة 1: الملفات الأساسية تم إنشاؤها"
