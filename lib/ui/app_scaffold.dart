import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:google_fonts/google_fonts.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
  });

  void _goHome(BuildContext context) {
    // Return to WelcomePage and clear the stack
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  void _goGuidelines(BuildContext context) {
    Navigator.pushNamed(context, '/guide');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: Text(title, style: GoogleFonts.slackey(fontSize: 20)),
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
            tooltip: 'Menu',
          ),
        ),
      ),
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tic-Tac-Paw', style: GoogleFonts.slackey(fontSize: 24)),
                    const SizedBox(height: 6),
                    const Text('Quick navigation', style: TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home_outlined),
                title: const Text('Home'),
                onTap: () => _goHome(context),
              ),
              ListTile(
                leading: const Icon(Icons.menu_book_outlined),
                title: const Text('Game Guidelines'),
                onTap: () => _goGuidelines(context),
              ),
            ],
          ),
        ),
      ),
      body: child,
    );
  }
}
