import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'home_screen.dart';
import '../providers/language_provider.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  String? selectedGuess;
  bool hasGuessed = false;
  late final List<String> guessOptions;

  @override
  void initState() {
    super.initState();
    final game = Provider.of<GameProvider>(context, listen: false);
    final lang = Provider.of<LanguageProvider>(context, listen: false);
    guessOptions = _generateGuessOptions(game, lang);
  }

  List<String> _generateGuessOptions(GameProvider game, LanguageProvider lang) {
    final correct = game.secretWord;
    List<String> allWords = [];
    bool isCustom = false;
    if (game.currentCategory != null) {
      if (game.categoryOptions.isNotEmpty &&
          game.categoryOptions.first is String) {
        isCustom = true;
      }
    }
    if (isCustom) {
      allWords = List<String>.from(game.categoryOptions);
    } else {
      allWords = List<String>.from(game.categoryOptions);
    }
    if (correct == null || allWords.isEmpty) return [];
    final wrongs = allWords
        .where((w) => w.toLowerCase() != correct.toLowerCase())
        .toList();
    wrongs.shuffle();
    final options = [correct, ...wrongs.take(3)];
    options.shuffle();
    return options;
  }

  void _playAgain() {
    final game = Provider.of<GameProvider>(context, listen: false);
    game.reset(); // Make sure your GameProvider has a reset() method
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final game = Provider.of<GameProvider>(context);
    final lang = Provider.of<LanguageProvider>(context);
    bool caught = game.wasImposterCaught;
    // String imposterName = game.players[game.outOfTheLoopIndex!];

    final int? imposterIdx = game.outOfTheLoopIndex;
    final String imposterName =
        (imposterIdx != null && imposterIdx < game.players.length)
        ? game.players[imposterIdx]
        : "Unknown";

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t("results")),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // Impostor result sentence at the TOP
            Padding(
              padding: const EdgeInsets.only(
                top: 24.0,
                left: 16,
                right: 16,
                bottom: 8,
              ),
              child: Text(
                caught
                    ? '${lang.t('the_imposter_was')} $imposterName.\n${lang.t('win')} ${lang.t('members')}'
                    : '${lang.t('the_imposter')} $imposterName ${lang.t('win')}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: caught ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      // Reveal the mole section
                      Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                imposterName,
                                style: TextStyle(
                                  fontSize: 28,
                                  color: Colors.deepPurple.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      // Mole guessing section
                      Card(
                        color: Colors.amber.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                "$imposterName,  ${lang.t("guess")}!",
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                lang.t("secret_word"),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Card(
                                color: Colors.deepPurple.shade50,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        "${lang.t("category")}:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        game.currentCategory ?? "Unknown",
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.deepPurple,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),
                              // Show 4 options: 1 correct, 3 random wrong
                              Column(
                                children: guessOptions.map((option) {
                                  bool isCorrect =
                                      option.toLowerCase() ==
                                      game.secretWord?.toLowerCase();
                                  return ChoiceButton(
                                    option: option,
                                    isCorrect: isCorrect,
                                    hasGuessed: hasGuessed,
                                    onTap: () {
                                      if (!hasGuessed) {
                                        setState(() {
                                          selectedGuess = option;
                                          game.submitMoleGuess(option);
                                          hasGuessed = true;
                                        });
                                      }
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Only one Play Again button at the bottom, always visible
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 16.0,
                  left: 16.0,
                  right: 16.0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () {
                      game.reset();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                        (route) => false,
                      );
                    },
                    child: Text(
                      lang.t("play_again"),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChoiceButton extends StatefulWidget {
  final String option;
  final bool isCorrect;
  final bool hasGuessed;
  final VoidCallback onTap;

  const ChoiceButton({
    super.key,
    required this.option,
    required this.isCorrect,
    required this.hasGuessed,
    required this.onTap,
  });

  @override
  State<ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<ChoiceButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    bool showResult = widget.hasGuessed;

    return MouseRegion(
      onEnter: (_) {
        if (!widget.hasGuessed) setState(() => isHovered = true);
      },
      onExit: (_) {
        if (!widget.hasGuessed) setState(() => isHovered = false);
      },
      child: Align(
        alignment: Alignment.center,
        child: GestureDetector(
          // Putting GestureDetector here makes the ENTIRE box clickable
          onTap: widget.hasGuessed ? null : widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(
              minWidth: 200, // Added minWidth to make a better target
              maxWidth: 360,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: showResult
                  ? (widget.isCorrect
                        ? Colors.green.shade400
                        : Colors.red.shade400)
                  : (isHovered ? Colors.deepPurple.shade50 : Colors.white),
              border: Border.all(
                color: isHovered && !showResult
                    ? Colors.deepPurple.shade700
                    : Colors.deepPurple,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: isHovered && !showResult
                  ? [
                      BoxShadow(
                        color: Colors.deepPurple.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            // Removed Transform/Scale logic
            child: Text(
              widget.option,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: widget.isCorrect && showResult
                    ? FontWeight.bold
                    : FontWeight.w600,
                color: showResult
                    ? Colors.white
                    : (isHovered ? Colors.deepPurple.shade700 : Colors.black87),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
