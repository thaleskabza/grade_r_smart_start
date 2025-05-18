import 'package:flutter/material.dart';
import '../models/score.dart';
import '../models/child_profile.dart';
import '../services/local_storage_service.dart';

class ResultsScreen extends StatefulWidget {
  final ChildProfile profile;

  const ResultsScreen({super.key, required this.profile});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Future<List<Score>> _scoreFuture;

  @override
  void initState() {
    super.initState();
    _scoreFuture = LocalStorageService().getScores(widget.profile.name);
  }

  Widget _buildScoreTile(Score score) {
    return ListTile(
      leading: Icon(
        score.isCorrect ? Icons.check_circle : Icons.cancel,
        color: score.isCorrect ? Colors.green : Colors.red,
      ),
      title: Text('${score.gameType} (${score.difficulty})'),
      subtitle: Text('Answered on ${score.timestamp.toLocal()}'),
      trailing: Text(score.isCorrect ? '✔' : '✖',
          style: TextStyle(
            fontSize: 20,
            color: score.isCorrect ? Colors.green : Colors.red,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Results'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: FutureBuilder<List<Score>>(
          future: _scoreFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Failed to load results'));
            } else if (snapshot.data == null || snapshot.data!.isEmpty) {
              return const Center(child: Text('No results yet. Play a game first!'));
            }

            return ListView.separated(
              itemCount: snapshot.data!.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                return _buildScoreTile(snapshot.data![index]);
              },
            );
          },
        ),
      ),
    );
  }
}
