import 'dart:async';
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_scaffold.dart';
import '../logic/enums.dart';

class TeamPage extends StatefulWidget {
  const TeamPage({super.key});
  @override
  State<TeamPage> createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage> {
  Team? _selected;

  // Bubble message + key to restart typing on change
  String _bubbleMessage = "Are you a cool cat or a good doggo? Pick your team!";
  int _msgKey = 0;

  void _pick(Team t) {
    setState(() {
      _selected = t;
      _bubbleMessage = t == Team.cat
          ? "😼 Meow! We will win this time!"
          : "🐶 Woof! Best choice everrr!";
      _msgKey++; // restart the typing animation
    });
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = GoogleFonts.slackey(
      fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black87,
    );

    return AppScaffold(
      title: 'Choose Your Team',
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background
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
              // kToolbarHeight ensures the bubble sits clearly below the AppBar
              padding: const EdgeInsets.fromLTRB(16, kToolbarHeight + 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ===== Chat bubble just under AppBar =====
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
                                  _TypewriterText(
                                    key: ValueKey(_msgKey),
                                    text: _bubbleMessage,
                                    charDelay: const Duration(milliseconds: 65), // slower typing
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

                  // ===== Slim, wide blue vs red buttons (match black box height) =====
                  Row(
                    children: [
                      Expanded(
                        child: _TeamBoxButton(
                          label: "Team Cat",
                          onTap: () => _pick(Team.cat),
                          selected: _selected == Team.cat,
                          bg: const Color(0xFF42A5F5),      // BLUE 400
                          border: const Color(0xFF1E88E5),  // BLUE 600
                          textColor: Colors.white,
                          height: 64, // << same feel as the black box
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _TeamBoxButton(
                          label: "Team Dog",
                          onTap: () => _pick(Team.dog),
                          selected: _selected == Team.dog,
                          bg: const Color(0xFFEF5350),      // RED 400
                          border: const Color(0xFFE53935),  // RED 600
                          textColor: Colors.white,
                          height: 64, // << same feel as the black box
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 50, // slimmer continue
                    child: ElevatedButton(
                      onPressed: _selected == null ? null : () {
                      if (_selected != null) {
                      Navigator.pushNamed(context, '/pickMark', arguments: _selected);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.red.withOpacity(0.35),
                        disabledForegroundColor: Colors.white70,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        textStyle: GoogleFonts.slackey(fontSize: 20, fontWeight: FontWeight.w700),
                        elevation: 4,
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

/// Single-line typewriter
class _TypewriterText extends StatefulWidget {
  final String text;
  final Duration charDelay;
  final Color caretColor;
  final TextStyle style;

  const _TypewriterText({
    super.key,
    required this.text,
    this.charDelay = const Duration(milliseconds: 30),
    this.caretColor = Colors.black,
    required this.style,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
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


class _TeamBoxButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final Color bg;
  final Color border;
  final Color textColor;
  final double height;

  const _TeamBoxButton({
    required this.label,
    required this.onTap,
    required this.selected,
    required this.bg,
    required this.border,
    required this.textColor,
    this.height = 64, 
  });

  @override
  State<_TeamBoxButton> createState() => _TeamBoxButtonState();
}

class _TeamBoxButtonState extends State<_TeamBoxButton> {
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
          curve: Curves.easeOut,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.bg,
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
            style: GoogleFonts.slackey(
              fontSize: 18, 
              color: widget.textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
