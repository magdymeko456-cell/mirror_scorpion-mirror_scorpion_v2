import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/language_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/ai_service.dart';
import 'services/offline_translation_service.dart';
import 'services/tts_service.dart';
import 'services/translation_service.dart';
import 'services/premium_verification_service.dart';
import 'features/home_screen.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card1_translation/dialogue_screen.dart';
import 'features/card1_translation/document_screen.dart';
import 'features/card3_inspiration/inspiration_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/card5_games/chess_screen.dart';
import 'features/card5_games/rubik_screen.dart';
import 'features/settings/settings_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MirrorScorpionApp());
}

class MirrorScorpionApp extends StatelessWidget {
  const MirrorScorpionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageService()..initialize()),
        ChangeNotifierProvider(create: (_) => FloatingBubbleService()..initialize()),
        ChangeNotifierProvider(create: (_) => AIService()..initialize()),
        ChangeNotifierProvider(create: (_) => OfflineTranslationService()..initialize()),
        ChangeNotifierProvider(create: (_) => TTSService()),
        ChangeNotifierProvider(create: (_) => PremiumVerificationService()..initialize()),
        ChangeNotifierProvider(create: (_) => TranslationService()..initialize()),
      ],
      child: MaterialApp(
        title: '🦂 Mirror Scorpion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal), useMaterial3: true),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/translate': (context) => const TranslationScreen(),
          '/dialogue': (context) => const DialogueScreen(),
          '/document': (context) => const DocumentScreen(),
          '/inspiration': (context) => const InspirationScreen(),
          '/stories': (context) => const StoriesScreen(),
          '/chess': (context) => const ChessScreen(),
          '/rubik': (context) => const RubikScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
      ),
    );
  }
}
