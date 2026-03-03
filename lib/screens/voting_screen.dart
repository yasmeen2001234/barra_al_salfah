import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'result_screen.dart';
import '../providers/language_provider.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);

    // Handle case where currentPlayerIndex might be out of bounds
    if (game.currentPlayerIndex >= game.players.length) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    String currentVoter = game.players[game.currentPlayerIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t("time_to_vote")),
        automaticallyImplyLeading: false,
      ),
      body: Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
          // Check if voting is complete

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "$currentVoter, ${lang.t("who_is_the_imposter")}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: gameProvider.players.length,
                  itemBuilder: (context, index) {
                    // Prevent voting for yourself
                    if (index == gameProvider.currentPlayerIndex) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 5,
                      ),
                      child: ListTile(
                        tileColor: Colors.deepPurple.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        title: Text(
                          gameProvider.players[index],
                          textAlign: TextAlign.center,
                        ),
                        onTap: () {
                          gameProvider.submitVote(index);
                          if (gameProvider.phase == GamePhase.results) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ResultScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
