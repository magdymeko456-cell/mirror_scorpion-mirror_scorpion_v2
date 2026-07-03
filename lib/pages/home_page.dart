import 'package:flutter/material.dart';
import 'text_translation_page.dart';
import 'voice_translation_page.dart';
import 'document_page.dart';
import 'stories_page.dart';
import 'games_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const TextTranslationPage(),
    const VoiceTranslationPage(),
    const DocumentPage(),
    const StoriesPage(),
    const GamesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: Theme.of(context).colorScheme.surface,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.translate, color: Colors.grey[400]),
              selectedIcon: Icon(Icons.translate, color: Theme.of(context).colorScheme.primary),
              label: 'ترجمة نصية',
            ),
            NavigationDestination(
              icon: Icon(Icons.headset_mic, color: Colors.grey[400]),
              selectedIcon: Icon(Icons.headset_mic, color: Theme.of(context).colorScheme.primary),
              label: 'حوار مترجم',
            ),
            NavigationDestination(
              icon: Icon(Icons.description, color: Colors.grey[400]),
              selectedIcon: Icon(Icons.description, color: Theme.of(context).colorScheme.primary),
              label: 'مستندات',
            ),
            NavigationDestination(
              icon: Icon(Icons.auto_stories, color: Colors.grey[400]),
              selectedIcon: Icon(Icons.auto_stories, color: Theme.of(context).colorScheme.primary),
              label: 'قصص',
            ),
            NavigationDestination(
              icon: Icon(Icons.sports_esports, color: Colors.grey[400]),
              selectedIcon: Icon(Icons.sports_esports, color: Theme.of(context).colorScheme.primary),
              label: 'ألعاب',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings, color: Colors.grey[400]),
              selectedIcon: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
              label: 'إعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
