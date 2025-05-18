import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/score.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static Database? _database;

  /// Get the initialized database or open one if null
  Future<Database> get database async {
    _database ??= await _initDB('smart_start.db');
    return _database!;
  }

  /// Initialize the SQLite database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// Create the scores table with auto-incrementing ID
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        childName TEXT NOT NULL,
        gameType TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        isCorrect INTEGER NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  /// Insert a new score into the scores table
  Future<void> insertScore(Score score) async {
    final db = await database;
    try {
      await db.insert(
        'scores',
        score.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace, // Prevent duplicates if needed
      );
    } catch (e) {
      print('Error inserting score: $e');
    }
  }

  /// Get all scores for a specific child, sorted by newest first
  Future<List<Score>> getScores(String childName) async {
    final db = await database;
    final result = await db.query(
      'scores',
      where: 'childName = ?',
      whereArgs: [childName],
      orderBy: 'timestamp DESC',
    );

    return result.map((map) => Score.fromMap(map)).toList();
  }

  /// Get all scores from all children
  Future<List<Score>> getAllScores() async {
    final db = await database;
    final result = await db.query('scores', orderBy: 'timestamp DESC');
    return result.map((map) => Score.fromMap(map)).toList();
  }

  /// Delete all scores from the database (for a full reset)
  Future<void> deleteAllScores() async {
    final db = await database;
    await db.delete('scores');
  }

  /// Delete scores for a specific child
  Future<void> deleteScoresForChild(String childName) async {
    final db = await database;
    await db.delete(
      'scores',
      where: 'childName = ?',
      whereArgs: [childName],
    );
  }
}
