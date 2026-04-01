import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'category_editor_screen.dart';
import '../providers/language_provider.dart';
import 'category_selection_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    // Reset game state when returning to home
    //   game.reset();
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.deepPurple.shade800, Colors.deepPurple.shade400],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology_alt, size: 100, color: Colors.white),
            const SizedBox(height: 20),
            Text(
              lang.t('app_title'),
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            Text(
              lang.t('subtitle'),
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategorySelectionScreen(),
                  ),
                );
              },
              child: Text(
                lang.t('start_game'),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CategoryEditorScreen(),
                  ),
                );
              },
              child: Text(
                lang.t('edit_categories'),
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20),
            // ... (language toggle removed)
          ],
        ),
      ),
    );
  }
}
