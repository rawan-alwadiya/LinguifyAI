import 'package:LinguifyAI/models/bn_screen.dart';
import 'package:LinguifyAI/screens/app/brevity_bot_screen.dart';
import 'package:LinguifyAI/screens/app/chat_pro_ai_screen.dart';
import 'package:LinguifyAI/screens/app/explore_words_screen.dart';
import 'package:LinguifyAI/screens/app/grammar_guru_screen.dart';
import 'package:LinguifyAI/screens/app/object_lens_screen.dart';
import 'package:LinguifyAI/screens/app/translation_screen.dart';
import 'package:flutter/material.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({super.key});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {

  int _currentIndex= 0;

  final List<BnScreen> _screens = <BnScreen>[
    const BnScreen(widget: TranslationScreen(), title: 'Translate'),
    const BnScreen(widget: ExploreWordsScreen(), title: 'Explore'),
    const BnScreen(widget: ObjectLensScreen(), title: 'Object Lens'),
    const BnScreen(widget: GrammarGuruScreen(), title: 'Grammar Guru'),
    const BnScreen(widget: BrevityBotScreen(), title: 'BrevityBot'),
    const BnScreen(widget: ChatProAiScreen(), title: 'ChatPro AI'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex].widget,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // Set the type to fixed
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            backgroundColor: Color(0xff2D2B4E),
            // backgroundColor: Color(0xFF243A73),
            selectedItemColor: Colors.white,
            selectedIconTheme: const IconThemeData(size: 28),
            unselectedItemColor: Colors.grey.shade300,
            onTap: (int currentIndex){
              setState(() => _currentIndex = currentIndex);
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.translate_outlined), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.games_outlined), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.image_search_sharp), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.spellcheck), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.chat_outlined), label: ''),
            ],
          ),
        ),
      ),
    );
  }
}