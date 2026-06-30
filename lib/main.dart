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
  await databaseService.initialize();
  final bubbleService = FloatingBubbleService();
  await bubbleService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider.value(value: bubbleService),
        ChangeNotifierProvider(create: (_) => TTSService()),
        ChangeNotifierProvider.value(value: databaseService),
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
