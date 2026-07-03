import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/tts_service.dart';
import 'core/services/ai_service.dart';
import 'core/services/database_service.dart';
import 'core/services/floating_bubble_service.dart';
import 'core/services/language_service.dart';
import 'core/services/premium_verification_service.dart';
import 'features/splash_screen.dart';
import 'features/home_screen.dart';
import 'features/translate/translate_screen.dart';
import 'features/dialogue/dialogue_screen.dart';
import 'features/document/document_screen.dart';
import 'features/hadith_stories/hadith_stories_screen.dart';
import 'features/games/games_screen.dart';
import 'features/settings/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MultiProvider(providers: [
    Provider(create: (_) => TtsService()),
    Provider(create: (_) => AiService()),
    ChangeNotifierProvider(create: (_) => DatabaseService()),
    Provider(create: (_) => FloatingBubbleService()),
    ChangeNotifierProvider(create: (_) => LanguageService()),
    Provider(create: (_) => PremiumVerificationService()),
  ], child: const MirrorApp()));
}

class MirrorApp extends StatelessWidget {
  const MirrorApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: '🦂 Mirror Scorpion', debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(primaryColor: const Color(0xFF1A237E), scaffoldBackgroundColor: const Color(0xFF0D1B2A), appBarTheme: const AppBarTheme(backgroundColor: Color(0xFF1A237E))),
    initialRoute: '/splash',
    onGenerateRoute: (s) {
      switch (s.name) {
        case '/splash': return MaterialPageRoute(builder: (_) => const SplashScreen());
        case '/home': return MaterialPageRoute(builder: (_) => const HomeScreen());
        case '/translate': return MaterialPageRoute(builder: (_) => const TranslateScreen());
        case '/dialogue': return MaterialPageRoute(builder: (_) => const DialogueScreen());
        case '/document': return MaterialPageRoute(builder: (_) => const DocumentScreen());
        case '/stories': return MaterialPageRoute(builder: (_) => const HadithStoriesScreen());
        case '/games': return MaterialPageRoute(builder: (_) => const GamesScreen());
        case '/settings': return MaterialPageRoute(builder: (_) => const SettingsScreen());
        default: return MaterialPageRoute(builder: (_) => const HomeScreen());
      }
    },
  );
}
