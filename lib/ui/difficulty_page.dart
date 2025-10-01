import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/enums.dart';   // Team, Mark, Difficulty, GameArgs
import 'app_scaffold.dart';

class DifficultyPage extends StatefulWidget {
  const DifficultyPage({super.key});

  @override
  State<DifficultyPage> createState() => _DifficultyPageState();
}

class _DifficultyPageState extends State<DifficultyPage> {
  late Team _team;
  late Mark _mark;

  Difficulty? _chosen;
  String _bubble = "Choose your challenge: Easy, Medium, or Hard?";
  int _key = 0; // re-triggers typewriter

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Expecting arguments: {'team': Team, 'mark': Mark}
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    _team = (args?['team'] as Team?) ?? Team.cat;
    _mark = (args?['mark'] as Mark?) ?? Mark.x;

    _bubble = "Choose your challenge: Easy (random), "
        "Medium (random ↔ logic), or Hard (always logic).";
    _key++;
  }

  void _pick(Difficulty d) {
    setState(() {
      _chosen = d;
      switch (d) {
        case Difficulty.easy:
          _bubble = "🥧 Easy: The AI plays random legal moves only.";
          break;
        case Difficulty.medium:
          _bubble = "⚖️ Medium: Starts random, then alternates random ↔ strategy each turn.";
          break;
        case Difficulty.hard:
          _bubble = "🧠 Hard: Uses the full strategy on every move.";
          break;
      }
      _key++;
    });
  }

  void _startMatch() {
  if (_chosen == null) return;
  Navigator.pushNamed(
    context,
    '/game', // go to game page, not back to difficulty
    arguments: {
      'team': _team,       // correct: Team
      'mark': _mark,       // correct: Mark
      'difficulty': _chosen, // correct: Difficulty
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.slackey(
      fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87,
    );

    return AppScaffold(
      title: 'Choose Difficulty',
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/arena_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Chat bubble
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.70),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 6)),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("💬 ", style: TextStyle(fontSize: 18)),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Tic-Tac-Paw", style: titleStyle),
                                  const SizedBox(height: 4),
                                  _Typewriter(
                                    key: ValueKey(_key),
                                    text: _bubble,
                                    charDelay: const Duration(milliseconds: 65),
                                    caretColor: Colors.red,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      height: 1.35,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Buttons (wide & slim like Team/PickMark pages)
                  _DiffButton(
                    title: "Easy",
                    subtitle: "AI chooses random legal moves only.",
                    color: const Color(0xFF66BB6A),      // green
                    border: const Color(0xFF43A047),
                    selected: _chosen == Difficulty.easy,
                    onTap: () => _pick(Difficulty.easy),
                  ),
                  const SizedBox(height: 12),

                  _DiffButton(
                    title: "Medium",
                    subtitle: "First random move, then alternates random ↔ strategy.",
                    color: const Color(0xFFFFCA28),      // amber
                    border: const Color(0xFFF9A825),
                    selected: _chosen == Difficulty.medium,
                    onTap: () => _pick(Difficulty.medium),
                  ),
                  const SizedBox(height: 12),

                  _DiffButton(
                    title: "Hard",
                    subtitle: "Always uses the full strategy every turn.",
                    color: const Color(0xFFEF5350),      // red
                    border: const Color(0xFFE53935),
                    selected: _chosen == Difficulty.hard,
                    onTap: () => _pick(Difficulty.hard),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _chosen == null ? null : _startMatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: Colors.red.withOpacity(0.35),
                        disabledForegroundColor: Colors.white70,
                        textStyle: GoogleFonts.slackey(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      child: const Text("Start Match"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------- UI pieces ---------- */

class _DiffButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final Color border;
  final bool selected;
  final VoidCallback onTap;

  const _DiffButton({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.border,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? border : Colors.black26, width: selected ? 3 : 1),
          boxShadow: [
            BoxShadow(
              color: (selected ? border : Colors.black26).withOpacity(0.35),
              blurRadius: selected ? 10 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              title == "Easy"
                  ? Icons.sentiment_satisfied_alt
                  : title == "Medium"
                      ? Icons.auto_mode
                      : Icons.psychology_alt,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$title  ",
                      style: GoogleFonts.slackey(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900),
                    ),
                    TextSpan(
                      text: subtitle,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* --- tiny typewriter used in the bubble --- */
class _Typewriter extends StatefulWidget {
  final String text;
  final Duration charDelay;
  final TextStyle style;
  final Color caretColor;
  const _Typewriter({
    super.key,
    required this.text,
    this.charDelay = const Duration(milliseconds: 30),
    required this.style,
    this.caretColor = Colors.black,
  });

  @override
  State<_Typewriter> createState() => _TypewriterState();
}

class _TypewriterState extends State<_Typewriter> {
  int _i = 0;
  Timer? _timer;
  bool _blink = true;
  Timer? _blinkTimer;

  @override
  void initState() {
    super.initState();
    _start();
    _blinkTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      if (mounted) setState(() => _blink = !_blink);
    });
  }

  void _start() {
    _timer?.cancel();
    _i = 0;
    _timer = Timer.periodic(widget.charDelay, (t) {
      if (_i < widget.text.length) {
        setState(() => _i++);
      } else {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = widget.text.substring(0, _i);
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(text: shown, style: widget.style),
          if (_i < widget.text.length)
            TextSpan(
              text: _blink ? "|" : " ",
              style: widget.style.copyWith(color: widget.caretColor, fontWeight: FontWeight.w900),
            ),
        ],
      ),
    );
  }
}
