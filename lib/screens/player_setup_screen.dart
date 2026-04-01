import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import './reveal_screen.dart'; // Add the path t
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/language_provider.dart';

class PlayerSetupScreen extends StatelessWidget {
  final String? selectedCategory;
  const PlayerSetupScreen({super.key, this.selectedCategory});

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final TextEditingController controller = TextEditingController();
    final lang = Provider.of<LanguageProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(Provider.of<LanguageProvider>(context).t("members")),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: lang.t("add_new_member"),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
                  onPressed: () {
                    game.addPlayer(controller.text);
                    controller.clear();
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                lang.t("saved_members"),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: game.players.length,
              itemBuilder: (context, i) => ListTile(
                leading: const Icon(Icons.person),
                title: Text(game.players[i]),
                trailing: IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () => game.removePlayer(i),
                ),
              ),
            ),
          ),
          // Only show Start button if we have 3+ players
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: game.players.length >= 3
                        ? Colors.deepPurple
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: game.players.length >= 3
                      ? () => _loadAndStart(context, game)
                      : null,
                  child: Text(
                    lang.t("start_round"),
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadAndStart(BuildContext context, GameProvider game) async {
    final String response = await rootBundle.loadString(
      'assets/categories.json',
    );
    final Map<String, dynamic> data = Map<String, dynamic>.from(
      json.decode(response),
    );

    // load custom categories from prefs
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('custom_categories');
    if (raw != null) {
      final Map<String, dynamic> custom = Map<String, dynamic>.from(
        json.decode(raw),
      );
      custom.forEach((k, v) {
        if (data.containsKey(k)) {
          // Merge custom words into existing category
          final cat = data[k];
          if (cat is Map && v is Map) {
            for (final lang in ["en", "ar"]) {
              if (v[lang] is List && cat[lang] is List) {
                final existingLower = (cat[lang] as List)
                    .map((e) => e.toString().toLowerCase())
                    .toSet();
                for (var w in v[lang]) {
                  if (!existingLower.contains(w.toString().toLowerCase())) {
                    (cat[lang] as List).add(w);
                  }
                }
              }
            }
          }
        } else {
          data[k] = v;
        }
      });
    }

    // If a category was chosen earlier, force it; otherwise pick random as before
    if (selectedCategory != null && data.containsKey(selectedCategory)) {
      final categoryData = data[selectedCategory];
      final chosen = <String, List<dynamic>>{
        selectedCategory!: (categoryData['ar'] as List<dynamic>?) ?? [],
      };
      game.startGame(chosen);
    } else {
      final Map<String, List<dynamic>> allCats = {};
      data.forEach((k, v) {
        allCats[k] = (v['ar'] as List<dynamic>?) ?? [];
      });
      game.startGame(allCats);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RevealScreen()),
    );
  }
}
