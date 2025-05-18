class Score {
  int? id;
  final String childName;
  final String gameType;
  final String difficulty;
  final bool isCorrect;
  final DateTime timestamp;

  Score({
    this.id, // now optional
    required this.childName,
    required this.gameType,
    required this.difficulty,
    required this.isCorrect,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'childName': childName,
      'gameType': gameType,
      'difficulty': difficulty,
      'isCorrect': isCorrect ? 1 : 0,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Score.fromMap(Map<String, dynamic> map) {
    return Score(
      id: map['id'],
      childName: map['childName'],
      gameType: map['gameType'],
      difficulty: map['difficulty'],
      isCorrect: map['isCorrect'] == 1,
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}
