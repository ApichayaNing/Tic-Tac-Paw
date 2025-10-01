import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';
import 'team_page.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          const DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/welcome_bg.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Start button at bottom
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // solid red box
                      foregroundColor: Colors.white, // white text
                      padding: const EdgeInsets.symmetric(
                        horizontal: 50,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 6,
                    ),
                    onPressed: () {
                      Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const TeamPage()), // 👈 go to TeamPage
                      );
                    },
                    child: Text(
                      "Start Game",
                      style: GoogleFonts.slackey(  
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
