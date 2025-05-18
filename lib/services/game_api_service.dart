import 'dart:convert';
import 'package:http/http.dart' as http;

class GameApiService {
  static const String _quizApiUrl =
      'https://opentdb.com/api.php?amount=5&category=9&type=multiple'; // Example public API

  /// Fetch simple multiple-choice quiz data
  Future<List<Map<String, dynamic>>> fetchQuizQuestions() async {
    try {
      final response = await http.get(Uri.parse(_quizApiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = data['results'];

        return results.map<Map<String, dynamic>>((item) {
          List<String> options = List<String>.from(item['incorrect_answers']);
          options.add(item['correct_answer']);
          options.shuffle();

          return {
            'question': item['question'],
            'correctAnswer': item['correct_answer'],
            'options': options,
          };
        }).toList();
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      // Fallback example (use for offline mode or local development)
      return [
        {
          'question': 'Which day comes after Monday?',
          'correctAnswer': 'Tuesday',
          'options': ['Sunday', 'Wednesday', 'Tuesday', 'Friday']
        },
        {
          'question': 'What number comes after 4?',
          'correctAnswer': '5',
          'options': ['3', '5', '7', '2']
        },
      ];
    }
  }
}
