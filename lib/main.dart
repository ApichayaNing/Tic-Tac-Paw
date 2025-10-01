import 'package:flutter/material.dart';
import 'ui/welcome_page.dart';
import 'ui/team_page.dart';
import 'ui/pick_mark_page.dart';
import 'ui/difficulty_page.dart';
import 'ui/game_page.dart';
import 'ui/guidelines_page.dart';

void main() {
  runApp(const TicTacToeApp());
}

class TicTacToeApp extends StatelessWidget {
  const TicTacToeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const WelcomePage(),
        '/team': (_) => const TeamPage(),
        '/pickMark': (_) => const PickMarkPage(),
        '/difficulty': (_) => const DifficultyPage(),
        '/game': (_) => const GamePage(),
        '/guide': (context) => const GuidelinesPage(),
      },
    );
  }
}
