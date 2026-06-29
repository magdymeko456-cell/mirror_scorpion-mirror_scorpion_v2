import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/widgets/floating_bubble_overlay.dart';
import 'features/splash_screen.dart';
import 'features/home_screen.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card1_translation/dialogue_screen.dart';
import 'features/card1_translation/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/games/chess_screen.dart';
import 'features/games/rubik_screen.dart';
import 'features/settings/settings_screen.dart';
import 'services/language_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/tts_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final languageService = LanguageService();
  await languageService.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider(create: (_) => FloatingBubbleService()),
        ChangeNotifierProvider(create: (_) => TTSService()),
      ],
      child: const MirrorScorpionApp(),
    ),
  );
}

class MirrorScorpionApp extends StatelessWidget {
  const MirrorScorpionApp({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingBubbleOverlay(
      child: MaterialApp(
        title: 'Mirror Scorpion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        initialRoute: '/splash',
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/': (context) => const HomeScreen(),
          '/translate': (context) => const TextTranslationScreen(),
          '/dialogue': (context) => const DialogueScreen(),
          '/document': (context) => const DocumentScreen(),
          '/stories': (context) => const StoriesScreen(),
          '/chess': (context) => const ChessScreen(),
          '/rubik': (context) => const RubikScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
