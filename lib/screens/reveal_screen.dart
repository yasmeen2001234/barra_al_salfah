import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'voting_screen.dart';
import '../providers/language_provider.dart';

class RevealScreen extends StatefulWidget {
  const RevealScreen({super.key});

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen> {
  bool isVisible = false;

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    bool isImposter = game.currentPlayerIndex == game.outOfTheLoopIndex;
    bool isLastPlayer = game.currentPlayerIndex == game.players.length - 1;

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${lang.t("player")}: ${game.players[game.currentPlayerIndex]}",
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),

            if (!isVisible)
              ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: Text(lang.t("show_my_role")),
                onPressed: () => setState(() => isVisible = true),
              ),

            if (isVisible) ...[
              Card(
                color: isImposter ? Colors.red.shade100 : Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      Text(
                        isImposter
                            ? lang.t("out_of_the_loop")
                            : "${lang.t("the_word_is")} ${game.secretWord}",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${lang.t("category")} ${game.currentCategory}",
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (isLastPlayer) {
                    // All players revealed, go to voting
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const VotingScreen()),
                    );
                  } else {
                    // Move to next player and hide the word again
                    setState(() => isVisible = false);
                    game.nextPlayer();
                  }
                },
                child: Text(
                  isLastPlayer ? lang.t("start_voting") : lang.t("next_player"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
