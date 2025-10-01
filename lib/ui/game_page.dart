// lib/ui/game_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../logic/game_logic.dart';   // board + AI (uses 'X'/'O' strings)
import '../logic/enums.dart';        // Team, Mark, Difficulty, GameArgs
import 'app_scaffold.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GameLogic logic;

  // From navigation args (defaults let you open page directly)
  Team team = Team.cat;                 // player's team
  Mark playerMarkEnum = Mark.x;         // player's mark
  Difficulty difficulty = Difficulty.easy;

  // Derived
  String get playerMark => playerMarkEnum == Mark.x ? 'X' : 'O';
  String get aiMark => playerMark == 'X' ? 'O' : 'X';
  Team get aiTeam => team == Team.cat ? Team.dog : Team.cat;

  // Scores (persistent across sessions)
  int wins = 0, losses = 0, draws = 0;

  bool _aiThinking = false;

  @override
  void initState() {
    super.initState();
    logic = GameLogic();
    _loadScores();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is GameArgs) {
      team = args.team;
      playerMarkEnum = args.playerMark;
      difficulty = args.difficulty;
    } else if (args is Map) {
      team = (args['team'] as Team?) ?? team;
      playerMarkEnum = (args['mark'] as Mark?) ?? playerMarkEnum;
      difficulty = (args['difficulty'] as Difficulty?) ?? difficulty;
    }

    // Human always starts — align logic turn to the player's mark
    logic.currentPlayer = playerMark;
  }

  /* ---------------- Persistence ---------------- */

  Future<void> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      wins = prefs.getInt('wins') ?? 0;
      losses = prefs.getInt('losses') ?? 0;
      draws = prefs.getInt('draws') ?? 0;
    });
  }

  Future<void> _saveScores() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('wins', wins);
    await prefs.setInt('losses', losses);
    await prefs.setInt('draws', draws);
  }

  /* ---------------- Interaction ---------------- */

  Future<void> _handleTap(int row, int col) async {
    if (_aiThinking || logic.winner != null) return;
    if (!logic.isValidMove(row, col)) return;

    // Player move
    final placed = logic.makeMove(row, col, playerMark);
    if (!placed) return;
    setState(() {});

    // Outcome?
    if (await _maybeFinishRound()) return;

    // AI move
    await _aiTurn();
  }

  Future<void> _aiTurn() async {
    if (logic.winner != null) return;
    setState(() => _aiThinking = true);

    // Small delay so it feels natural
    await Future.delayed(const Duration(milliseconds: 250));

    final mv = logic.chooseAiMove(difficulty, aiMark, playerMark);
    if (mv != null) {
      logic.makeMove(mv.x, mv.y, aiMark);
    }

    setState(() => _aiThinking = false);
    await _maybeFinishRound();
  }

  Future<bool> _maybeFinishRound() async {
    final w = logic.winner; // 'X', 'O', 'Draw', or null
    if (w == null) return false;

    if (w == 'Draw') {
      draws++;
      await _saveScores();
      _showResult("It's a draw!");
    } else if (w == playerMark) {
      wins++;
      await _saveScores();
      _showResult("You win! 🎉");
    } else {
      losses++;
      await _saveScores();
      _showResult("You lose! 😿");
    }
    setState(() {});
    return true;
  }

  void _showResult(String msg) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        title: Text('Round Over', style: GoogleFonts.slackey()),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _newRound();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void _newRound() {
    logic.reset();
    logic.currentPlayer = playerMark; // human first every round
    setState(() {});
  }

  void _undo() {
    // Undo AI + player if present
    final undone = logic.undoFullTurnVsAI();
    if (undone == 0) return;
    setState(() {});
  }

  Future<void> _resetScores() async {
    wins = 0; losses = 0; draws = 0;
    await _saveScores();
    setState(() {});
  }

  Future<void> _resetGameAndGoHome() async {
    // clear persistent scores
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wins');
    await prefs.remove('losses');
    await prefs.remove('draws');

    // clear current round state
    logic.reset();
    logic.currentPlayer = 'X';

    if (!mounted) return;
    // wipe the stack and land on Welcome
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  /* ---------------- Assets ---------------- */

  // Map board value ('X'/'O') to the right image,
  // using the team who owns that mark (player vs AI).
  // IMPORTANT: paths match your exact filenames (case sensitive).
  String _assetFor(String cellValue) {
    if (cellValue != 'X' && cellValue != 'O') return '';
    final ownerTeam = (cellValue == playerMark) ? team : aiTeam;
    final isCat = ownerTeam == Team.cat;
    final isX = cellValue == 'X';

    if (isCat && isX) return 'assets/images/cat_x.png';
    if (isCat && !isX) return 'assets/images/cat_O.png';
    if (!isCat && isX) return 'assets/images/dog_X.png';
    return 'assets/images/dog_O.png';
  }

  /* ---------------- UI ---------------- */

  @override
  Widget build(BuildContext context) {
    final who = team == Team.cat ? "Team Cat" : "Team Dog";
    final diff = difficulty.name.toUpperCase();

    return AppScaffold(
      title: 'Tic-Tac-Paw',
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image (your bones + fish pattern)
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/game_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Warm tint to help readability on top of the pattern
          Container(color: const Color(0xFF7A5C43).withOpacity(0.06)),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header bubble (message card)
                  _HeaderBubble(
                    title: who,
                    subtitle: "You: $playerMark · $diff",
                    trailing: "W $wins   L $losses   D $draws",
                  ),
                  const SizedBox(height: 12),

                  // Board (3×3)
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: _Board(
                          board: logic.board,
                          onTap: _handleTap,
                          aiThinking: _aiThinking,
                          assetFor: _assetFor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bottom action bar (Undo / New Round) + boxed resets
                  Column(
                    children: [
                      _BottomActions(
                        onUndo: _undo,
                        onNewRound: _newRound,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _resetScores,
                              icon: const Icon(Icons.restore, color: Color(0xFF6D4C41)),
                              label: Text(
                                "Reset Scores",
                                style: GoogleFonts.slackey(
                                  color: const Color(0xFF6D4C41),
                                  fontSize: 15,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFF6D4C41), width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _resetGameAndGoHome,
                              icon: const Icon(Icons.home),
                              label: Text(
                                "Reset Game",
                                style: GoogleFonts.slackey(fontSize: 15, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8D6E63), // warm brown
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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

/* ---------------- UI helper widgets ---------------- */

class _HeaderBubble extends StatelessWidget {
  final String title;
  final String subtitle;
  final String trailing;

  const _HeaderBubble({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 10, offset: Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          const Text("💬", style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.slackey(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: GoogleFonts.slackey(
                      fontSize: 14,
                      color: Colors.black87,
                    )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(trailing,
              style: GoogleFonts.slackey(
                fontSize: 13,
                color: Colors.black87,
              )),
        ],
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onNewRound;

  const _BottomActions({
    required this.onUndo,
    required this.onNewRound,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x22000000), blurRadius: 12, offset: Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onUndo,
              icon: const Icon(Icons.undo, color: Color(0xFF6D4C41)),
              label: Text("Undo",
                  style: GoogleFonts.slackey(
                    color: const Color(0xFF6D4C41),
                    fontSize: 16,
                  )),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6D4C41), width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onNewRound,
              icon: const Icon(Icons.refresh),
              label: Text("New Round",
                  style: GoogleFonts.slackey(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ---------------- Grid widgets ---------------- */

class _Board extends StatelessWidget {
  final List<List<String>> board; // '', 'X', 'O'
  final Future<void> Function(int r, int c) onTap;
  final bool aiThinking;
  final String Function(String cellValue) assetFor;

  const _Board({
    required this.board,
    required this.onTap,
    required this.aiThinking,
    required this.assetFor,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: 9,
      itemBuilder: (_, i) {
        final r = i ~/ 3, c = i % 3;
        return _Cell(
          value: board[r][c],
          onPressed: () => onTap(r, c),
          disabled: board[r][c].isNotEmpty || aiThinking,
          assetFor: assetFor,
        );
      },
    );
  }
}

class _Cell extends StatelessWidget {
  final String value; // '', 'X', 'O'
  final VoidCallback onPressed;
  final bool disabled;
  final String Function(String) assetFor;

  const _Cell({
    required this.value,
    required this.onPressed,
    required this.disabled,
    required this.assetFor,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 254, 228, 191).withOpacity(0.55), // warm cream
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.85), width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, 6)),
            ],
          ),
          child: Center(
            child: isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: Image.asset(
                      assetFor(value),
                      fit: BoxFit.contain,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
