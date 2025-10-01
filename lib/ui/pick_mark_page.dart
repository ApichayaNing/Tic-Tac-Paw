import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../logic/enums.dart';       // Team, Mark, Difficulty, GameArgs (from earlier)
import 'app_scaffold.dart';

class PickMarkPage extends StatefulWidget {
  const PickMarkPage({super.key});

  @override
  State<PickMarkPage> createState() => _PickMarkPageState();
}

class _PickMarkPageState extends State<PickMarkPage> {
  Team _team = Team.cat;            // default if opened from drawer during testing
  Mark? _chosen;
  String _bubble = "Pick your battle mark: X or O?";
  int _key = 0;                     // restart typing on change

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg is Team) _team = arg;
    // set a playful intro based on team
    _bubble = _team == Team.cat
        ? "Pick your battle mark! X scratches or O pounces?"
        : "Pick your battle mark! X barks or O boops?";
    _key++;
  }

  void _select(Mark m) {
    setState(() {
      _chosen = m;
      _bubble = _team == Team.cat
          ? (m == Mark.x ? "😼 Sharp choice: X!" : "😼 Purrfect circle: O!")
          : (m == Mark.x ? "🐶 Big bark energy: X!" : "🐶 Round of a-paws: O!");
      _key++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.slackey(
      fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87,
    );

    return AppScaffold(
      title: 'Choose X or O',
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
                  // Chat bubble just under app bar
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
                                    style: const TextStyle(fontSize: 16, height: 1.35, color: Colors.black87),
                                    caretColor: Colors.red,
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

                  
                  Row(
                    children: [
                      Expanded(
                        child: _MarkBoxButton(
                          label: "Mark X",
                          color: const Color(0xFFEF5350),   // red
                          border: const Color(0xFFE53935),
                          onTap: () => _select(Mark.x),
                          selected: _chosen == Mark.x,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _MarkBoxButton(
                          label: "Mark O",
                          color: const Color(0xFF42A5F5),   // blue
                          border: const Color(0xFF1E88E5),
                          onTap: () => _select(Mark.o),
                          selected: _chosen == Mark.o,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _chosen == null
                          ? null
                          : () {
                              Navigator.pushNamed(
                                context,
                                '/difficulty',
                                arguments: {'team': _team, 'mark': _chosen},
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        disabledBackgroundColor: Colors.red.withOpacity(0.35),
                        disabledForegroundColor: Colors.white70,
                        textStyle: GoogleFonts.slackey(fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      child: const Text("Continue"),
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

/* --- slim animated button --- */
class _MarkBoxButton extends StatefulWidget {
  final String label;
  final Color color;
  final Color border;
  final bool selected;
  final VoidCallback onTap;

  const _MarkBoxButton({
    required this.label,
    required this.color,
    required this.border,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_MarkBoxButton> createState() => _MarkBoxButtonState();
}

class _MarkBoxButtonState extends State<_MarkBoxButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.97 : (widget.selected ? 1.03 : 1.0);
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 64,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: widget.selected ? widget.border : Colors.black26,
              width: widget.selected ? 3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (widget.selected ? widget.border : Colors.black26).withOpacity(0.35),
                blurRadius: widget.selected ? 10 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.slackey(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }
}

/* --- tiny typewriter --- */
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
