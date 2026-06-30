import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// استيراد الشاشات الحقيقية بناءً على هيكل المجلدات المتاحة
import 'features/home_screen.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card2_dialogue/dialogue_screen.dart';
import 'features/card3_document/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/games/chess/chess_game.dart';
import 'features/games/rubik_cube/rubik_cube_screen_enhanced.dart';
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
        ChangeNotifierProvider<LanguageService>.value(value: languageService),
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
    return MaterialApp(
      title: 'Mirror Scorpion',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/translate': (context) => const TranslationScreen(), // ربط الشاشة الحقيقية
        '/dialogue': (context) => const DialogueScreen(),     // ربط الشاشة الحقيقية
        '/document': (context) => const DocumentScreen(),     // ربط الشاشة الحقيقية
        '/stories': (context) => const StoriesScreen(),       // ربط الشاشة الحقيقية
        '/chess': (context) => const ChessGame(),             // ربط الشاشة الحقيقية
        '/rubik': (context) => const RubikCubeScreenEnhanced(), // ربط الشاشة الحقيقية
        '/settings': (context) => const SettingsScreen(),     // ربط الشاشة الحقيقية
      },
    );
  }
}
