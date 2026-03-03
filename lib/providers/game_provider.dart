import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GamePhase { setup, revealing, voting, results }

class GameProvider extends ChangeNotifier {
  List<String> players = [];
  String? secretWord;
  String? currentCategory;
  int? outOfTheLoopIndex;
  int currentPlayerIndex = 0;
  GamePhase phase = GamePhase.setup;

  Map<int, int> votes = {};
  int? votedOutIndex;
  bool wasImposterCaught = false;
  String? moleGuess;
  List<String> categoryOptions = [];

  Map<String, dynamic> categories = {};

  GameProvider() {
    loadPlayers();
  }

  Future<void> savePlayers() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('saved_players', players);
  }

  Future<void> loadPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    players = prefs.getStringList('saved_players') ?? [];
    notifyListeners();
  }

  void addPlayer(String name) {
    if (name.isNotEmpty) {
      players.add(name);
      savePlayers();
      notifyListeners();
    }
  }

  void removePlayer(int index) {
    players.removeAt(index);
    savePlayers();
    notifyListeners();
  }

  void startGame(Map<String, List<dynamic>> categories) {
    final random = Random();
    currentCategory = categories.keys.elementAt(
      random.nextInt(categories.length),
    );
    List<dynamic> words = categories[currentCategory]!;
    secretWord = words[random.nextInt(words.length)];

    // Store all category options and shuffle them
    categoryOptions = List<String>.from(words.map((w) => w.toString()));
    categoryOptions.shuffle();

    outOfTheLoopIndex = random.nextInt(players.length);
    currentPlayerIndex = 0;
    phase = GamePhase.revealing;
    notifyListeners();
  }

  void nextPlayer() {
    if (currentPlayerIndex < players.length - 1) {
      currentPlayerIndex++;
    } else {
      // After all players revealed, start voting
      currentPlayerIndex = 0;
      phase = GamePhase.voting;
    }
    notifyListeners();
  }

  void submitVote(int targetIndex) {
    votes[currentPlayerIndex] = targetIndex;
    if (votes.length == players.length) {
      // Voting complete, calculate results
      _calculateVotingResult();
    } else {
      currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    }
    notifyListeners();
  }

  void _calculateVotingResult() {
    Map<int, int> tally = {};
    for (var target in votes.values) {
      tally[target] = (tally[target] ?? 0) + 1;
    }

    votedOutIndex = tally.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    wasImposterCaught = (votedOutIndex == outOfTheLoopIndex);
    phase = GamePhase.results;
    notifyListeners();
  }

  void submitMoleGuess(String guess) {
    moleGuess = guess;
    notifyListeners();
  }

  void reset() {
    phase = GamePhase.setup;
    votes.clear();
    secretWord = null;
    currentCategory = null;
    outOfTheLoopIndex = null;
    votedOutIndex = null;
    wasImposterCaught = false;
    moleGuess = null;
    categoryOptions = [];
    currentPlayerIndex = 0;
    notifyListeners();
  }
}
