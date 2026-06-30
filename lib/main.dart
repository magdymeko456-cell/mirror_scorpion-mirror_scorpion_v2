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
import 'services/background_service.dart';
import 'core/theme/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => LanguageService()),
      ChangeNotifierProvider(create: (_) => FloatingBubbleService()),
      ChangeNotifierProvider(create: (_) => TTSService()),
      ChangeNotifierProvider(create: (_) => DatabaseService()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AIService()),
      ChangeNotifierProvider(create: (_) => BackgroundService()),
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
