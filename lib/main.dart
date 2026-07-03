import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/tts_service.dart';
import 'services/ai_service.dart';
import 'services/database_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/premium_verification_service.dart';
import 'services/language_service.dart';
import 'services/background_service.dart';
import 'services/language_download_service.dart';
import 'core/theme/theme_provider.dart';
import 'features/home_screen.dart';
import 'features/translate/translate_screen.dart';
import 'features/dialogue/dialogue_screen.dart';
import 'features/document/document_screen.dart';
import 'features/hadith_stories/hadith_stories_screen.dart';
import 'features/games/games_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/about/about_app_screen.dart';
import 'features/admin/key_generator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LanguageService().initialize();
  await BackgroundService().initialize();
  await LanguageDownloadService().initialize();
  runApp(const MirrorScorpionApp());
}

class MirrorScorpionApp extends StatelessWidget {
  const MirrorScorpionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TTSService()),
        ChangeNotifierProvider(create: (_) => DatabaseService()),
        ChangeNotifierProvider(create: (_) => FloatingBubbleService()),
        ChangeNotifierProvider(create: (_) => PremiumVerificationService()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
        ChangeNotifierProvider(create: (_) => BackgroundService()),
        ChangeNotifierProvider(create: (_) => LanguageDownloadService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Mirror Scorpion Translate',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
            ),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            locale: const Locale('ar'),
            home: const HomeScreen(),
            routes: {
              '/translate': (context) => const TranslateScreen(),
              '/dialogue': (context) => const DialogueScreen(),
              '/document': (context) => const DocumentScreen(),
              '/stories': (context) => const HadithStoriesScreen(),
              '/games': (context) => const GamesScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/about': (context) => const AboutAppScreen(),
              '/admin_gen': (context) => const KeyGeneratorScreen(),
            },
          );
        },
      ),
    );
  }
}
