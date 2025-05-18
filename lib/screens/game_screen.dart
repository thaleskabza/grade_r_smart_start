import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/child_profile.dart';
import '../models/score.dart';
import '../services/local_storage_service.dart';
import 'results_screen.dart';

class GameScreen extends StatefulWidget {
  final ChildProfile profile;
  const GameScreen({super.key, required this.profile});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

enum Difficulty { easy, medium, difficult }

enum GameType { number, day, sequence, clock }

class _GameScreenState extends State<GameScreen> {
  GameType _selectedGame = GameType.number;
  Difficulty _difficulty = Difficulty.easy;

  int targetNumber = 1;
  int selectedNumber = -1;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  String currentDay = '';
  String nextDay = '';
  String selectedDay = '';

  List<int> _sequence = [];
  int? _missingValue;
  List<int> _sequenceOptions = [];

  late TimeOfDay _targetTime;
  List<String> _timeOptions = [];

  bool? isCorrect;

  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTts();
    _resetGame();
  }

  void _initTts() {
    _flutterTts.setLanguage("en-US");
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.2);
    _flutterTts.awaitSpeakCompletion(true);
  }

  int _getMaxRange() {
    switch (_difficulty) {
      case Difficulty.easy:
        return 5;
      case Difficulty.medium:
        return 10;
      case Difficulty.difficult:
        return 20;
    }
  }

  void _generateNumberTarget() {
    int maxRange = _getMaxRange();
    targetNumber = Random().nextInt(maxRange) + 1;
  }

  void _generateDayTarget() {
    int index = Random().nextInt(_days.length - 1);
    currentDay = _days[index];
    nextDay = _days[index + 1];
  }

  void _generateSequenceGame() {
    int start = Random().nextInt(5) + 1;
    _sequence = List.generate(4, (i) => start + i);
    int missingIndex = Random().nextInt(4);
    _missingValue = _sequence[missingIndex];
    _sequence[missingIndex] = -1;
    _sequenceOptions = [_missingValue!, _missingValue! + 1, _missingValue! - 1]
      ..shuffle();
  }

  void _generateClockGame() {
    final hour = Random().nextInt(12) + 1;
    final minute = [0, 15, 30, 45][Random().nextInt(4)];
    _targetTime = TimeOfDay(hour: hour, minute: minute);
    _timeOptions = [
      _targetTime.format(context),
      TimeOfDay(hour: (hour + 1) % 12 + 1, minute: minute).format(context),
      TimeOfDay(
        hour: (hour + 2) % 12 + 1,
        minute: (minute + 15) % 60,
      ).format(context),
    ]..shuffle();
  }

  void _checkAnswer(dynamic answer) async {
    if (isCorrect != null) return;

    bool correct = false;
    switch (_selectedGame) {
      case GameType.number:
        correct = answer == targetNumber;
        break;
      case GameType.day:
        correct = answer == nextDay;
        break;
      case GameType.sequence:
        correct = answer == _missingValue;
        break;
      case GameType.clock:
        correct = answer == _targetTime.format(context);
        break;
    }

    final String childName =
        widget.profile.name.isNotEmpty ? widget.profile.name : "Learner";

    final score = Score(
      childName: childName,
      gameType: _selectedGame.name,
      difficulty: _difficulty.name,
      isCorrect: correct,
      timestamp: DateTime.now(),
    );

    await LocalStorageService().insertScore(score);

    setState(() {
      isCorrect = correct;
    });

    await _flutterTts.setLanguage('en-ZA');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.awaitSpeakCompletion(true);

    if (correct) {
      await _flutterTts.speak("Congratulations! You got it right!");
    } else {
      await _flutterTts.speak("Oops! Try again. Press play again to continue.");
    }
  }

  void _resetGame() async {
    await _flutterTts.stop();
    await _flutterTts.speak("Replay");

    setState(() {
      isCorrect = null;
      selectedNumber = -1;
      selectedDay = '';
      _missingValue = null;
      _timeOptions = [];

      switch (_selectedGame) {
        case GameType.number:
          _generateNumberTarget();
          break;
        case GameType.day:
          _generateDayTarget();
          break;
        case GameType.sequence:
          _generateSequenceGame();
          break;
        case GameType.clock:
          _generateClockGame();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    int maxRange = _getMaxRange();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Let\'s Play a Game!'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Results',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultsScreen(profile: widget.profile),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const Text("Game: "),
                DropdownButton<GameType>(
                  value: _selectedGame,
                  onChanged: (newGame) {
                    _selectedGame = newGame!;
                    _resetGame();
                  },
                  items:
                      GameType.values
                          .map(
                            (g) => DropdownMenuItem(
                              value: g,
                              child: Text(g.name.toUpperCase()),
                            ),
                          )
                          .toList(),
                ),
                const SizedBox(width: 20),
                if (_selectedGame == GameType.number)
                  DropdownButton<Difficulty>(
                    value: _difficulty,
                    onChanged: (newLevel) {
                      _difficulty = newLevel!;
                      _resetGame();
                    },
                    items:
                        Difficulty.values
                            .map(
                              (d) => DropdownMenuItem(
                                value: d,
                                child: Text(d.name.toUpperCase()),
                              ),
                            )
                            .toList(),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            if (_selectedGame == GameType.number) ...[
              Text(
                'Tap the number $targetNumber',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(maxRange, (i) {
                  int val = i + 1;
                  return ElevatedButton(
                    onPressed:
                        isCorrect == null ? () => _checkAnswer(val) : null,
                    child: Text('$val'),
                  );
                }),
              ),
            ] else if (_selectedGame == GameType.day) ...[
              Text(
                'What day comes after $currentDay?',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children:
                    _days.map((day) {
                      return ElevatedButton(
                        onPressed:
                            isCorrect == null ? () => _checkAnswer(day) : null,
                        child: Text(day),
                      );
                    }).toList(),
              ),
            ] else if (_selectedGame == GameType.sequence) ...[
              const Text(
                'Fill in the missing number:',
                style: TextStyle(fontSize: 22),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    _sequence.map((num) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          num == -1 ? '___' : '$num',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children:
                    _sequenceOptions.map((opt) {
                      return ElevatedButton(
                        onPressed:
                            isCorrect == null ? () => _checkAnswer(opt) : null,
                        child: Text('$opt'),
                      );
                    }).toList(),
              ),
            ] else if (_selectedGame == GameType.clock) ...[
              const Text('What time is it?', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 10),
              const Icon(
                Icons.access_time_filled,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                children:
                    _timeOptions.map((opt) {
                      return ElevatedButton(
                        onPressed:
                            isCorrect == null ? () => _checkAnswer(opt) : null,
                        child: Text(opt),
                      );
                    }).toList(),
              ),
            ],
            const SizedBox(height: 30),
            if (isCorrect != null) ...[
              Text(
                isCorrect! ? 'Yay! That\'s Correct!' : 'Oops! Try Again!',
                style: TextStyle(
                  fontSize: 22,
                  color: isCorrect! ? Colors.green : Colors.red,
                ),
              ),
              TextButton(
                onPressed: _resetGame,
                child: const Text('Play Again'),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultsScreen(profile: widget.profile),
                    ),
                  );
                },
                icon: const Icon(Icons.leaderboard),
                label: const Text('View My Results'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
