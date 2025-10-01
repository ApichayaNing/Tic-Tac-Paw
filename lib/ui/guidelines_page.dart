import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_scaffold.dart';

class GuidelinesPage extends StatelessWidget {
  const GuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'How to Play',
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Same background as Game page
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/game_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Soft warm tint for readability
          Container(color: const Color(0xFF7A5C43).withOpacity(0.06)),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title bubble
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 6)),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Text('📖 ', style: TextStyle(fontSize: 18)),
                            Text('Tic-Tac-Paw — Guidelines',
                                style: GoogleFonts.slackey(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black87,
                                )),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _CardSection(
                    title: 'How to Win',
                    bullets: const [
                      'Make a line of three (horizontal, vertical, or diagonal).',
                      'Board is 3×3. Tap an empty cell to place your mark.',
                      'If all 9 cells are filled and no line is made → it’s a draw.',
                    ],
                    icon: Icons.emoji_events_outlined,
                  ),

                  _CardSection(
                    title: 'Your Team & Mark',
                    bullets: const [
                      'Pick Team Cat or Team Dog.',
                      'Choose your mark: X or O.',
                      'The AI plays as the opposite team/mark.',
                    ],
                    icon: Icons.pets_outlined,
                  ),

                  _CardSection(
                    title: 'Difficulty Modes',
                    bullets: const [
                      'Easy: AI picks random legal moves.',
                      'Medium: first move random, then alternates random ↔ strategy.',
                      'Hard: always strategy: block wins, create forks, take center, opposite corner, corners, else any.',
                    ],
                    icon: Icons.speed_outlined,
                  ),

                  _CardSection(
                    title: 'Undo & New Round',
                    bullets: const [
                      'Undo rewinds a full turn: your last move + the AI move.',
                      'New Round clears the board (scores are kept).',
                    ],
                    icon: Icons.undo,
                  ),

                  _CardSection(
                    title: 'Scores & Persistence',
                    bullets: const [
                      'Wins/Losses/Draws are saved between app runs.',
                      'Reset Scores clears just the totals.',
                      'Reset Game returns to the welcome page and resets the session.',
                    ],
                    icon: Icons.insights_outlined,
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  final String title;
  final List<String> bullets;
  final IconData icon;

  const _CardSection({
    required this.title,
    required this.bullets,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: const Color(0xFF6D4C41)),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.slackey(fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ]),
          const SizedBox(height: 8),
          ...bullets.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(b, style: const TextStyle(height: 1.35))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
