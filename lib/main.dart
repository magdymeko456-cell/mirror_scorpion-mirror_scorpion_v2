import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/services/tts_service.dart';
import 'core/services/ai_service.dart';
import 'core/services/database_service.dart';
import 'core/services/floating_bubble_service.dart';
import 'core/services/background_service.dart';
import 'core/services/language_service.dart';
import 'core/services/overlay_service.dart';
import 'core/services/premium_verification_service.dart';
import 'core/services/shared_preferences_service.dart';
import 'features/splash/splash_screen.dart';
import 'features/home_screen.dart';
import 'features/translate/translate_screen.dart';
import 'features/dialogue/dialogue_screen.dart';
import 'features/document/document_screen.dart';
import 'features/hadith_stories/hadith_stories_screen.dart';
import 'features/games/games_screen.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = SharedPreferencesService.instance;
  await prefs.init();
  
  final dbService = DatabaseService();
  await dbService.init();
  
  final ttsService = TtsService();
  final aiService = AiService();
  final bubbleService = FloatingBubbleService();
  final overlayService = OverlayService();
  final backgroundService = BackgroundService();
  final languageService = LanguageService();
  final premiumService = PremiumVerificationService();
  final themeProvider = ThemeProvider();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        Provider.value(value: ttsService),
        Provider.value(value: aiService),
        ChangeNotifierProvider.value(value: dbService),
        Provider.value(value: bubbleService),
        Provider.value(value: overlayService),
        Provider.value(value: backgroundService),
        Provider.value(value: languageService),
        Provider.value(value: premiumService),
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
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: '🦂 Mirror Scorpion',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeProvider.themeMode,
          initialRoute: '/splash',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/splash':
                return MaterialPageRoute(builder: (_) => const SplashScreen());
              case '/home':
                return MaterialPageRoute(builder: (_) => const HomeScreen());
              case '/translate':
                return MaterialPageRoute(builder: (_) => const TranslateScreen());
              case '/dialogue':
                return MaterialPageRoute(builder: (_) => const DialogueScreen());
              case '/document':
                return MaterialPageRoute(builder: (_) => const DocumentScreen());
              case '/stories':
                return MaterialPageRoute(builder: (_) => const HadithStoriesScreen());
              case '/games':
                return MaterialPageRoute(builder: (_) => const GamesScreen());
              case '/settings':
                return MaterialPageRoute(builder: (_) => const SettingsScreen());
              default:
                return MaterialPageRoute(builder: (_) => const HomeScreen());
            }
          },
        );
      },
    );
  }
}
