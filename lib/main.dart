import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'features/home_screen.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card2_dialogue/dialogue_screen.dart';
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
