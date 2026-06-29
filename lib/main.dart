import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/home_screen.dart';
import 'features/card1_translation/translation_screen.dart';
import 'features/card1_translation/dialogue_screen.dart';
import 'features/card1_translation/document_screen.dart';
import 'features/card4_stories/stories_screen.dart';
import 'features/settings/settings_screen.dart';
import 'services/language_service.dart';
import 'services/tts_service.dart';
import 'services/floating_bubble_service.dart';
import 'services/ai_service.dart';
import 'services/offline_translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final languageService = LanguageService();
  await languageService.initialize();

  final bubbleService = FloatingBubbleService();
  await bubbleService.initialize();

  final aiService = AIService();
  await aiService.initialize();

  final offlineTranslation = OfflineTranslationService();
  await offlineTranslation.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageService),
        ChangeNotifierProvider.value(value: bubbleService),
        ChangeNotifierProvider.value(value: aiService),
        ChangeNotifierProvider.value(value: offlineTranslation),
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/translate': (context) => const TextTranslationScreen(),
        '/dialogue': (context) => const DialogueScreen(),
        '/document': (context) => const DocumentScreen(),
        '/stories': (context) => const StoriesScreen(),
        '/settings': (context) => const SettingsScreen(),
      },
    );
  }
}
