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
            theme: themeProvider.themeData,
            darkTheme: themeProvider.themeData,
            locale: const Locale('ar'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ar'),
              Locale('en'),
            ],
            home: const HomeScreen(),
            routes: {
              '/settings': (context) => const SettingsScreen(),
              '/about': (context) => const AboutAppScreen(),
              '/admin_gen': (context) => const KeyGeneratorScreen(),
              '/translate': (context) => const TextTranslationScreen(),
              '/dialogue': (context) => const DialogueTranslationScreen(),
              '/document': (context) => const DocumentTranslationScreen(),
              '/stories': (context) => const StoriesScreen(),
              '/chess': (context) => const ChessGameScreen(),
              '/rubik': (context) => const RubikCubeScreen(),
            },
          );
        },
      ),
    );
  }
}

// استيراد إضافية للـ routes
import 'features/card1_translation/translation_screen.dart';
import 'features/card2_dialogue/dialogue_screen.dart';
import 'features/card3_document/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/games/chess/chess_screen.dart';
import 'features/games/rubik_cube/rubik_screen.dart';
