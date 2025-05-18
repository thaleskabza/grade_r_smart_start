import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'game_screen.dart';
import '../models/child_profile.dart';

class CalendarScreen extends StatefulWidget {
  final ChildProfile profile;
  const CalendarScreen({super.key, required this.profile});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  late DateTime now;

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
    _speakDate();
  }

Future<void> _speakDate() async {
  final now = DateTime.now(); // define 'now' here safely

  final String day = DateFormat('EEEE').format(now); // e.g., Monday
  final String date = DateFormat('MMMM d, yyyy').format(now); // e.g., May 18, 2025

  final String name = widget.profile.name.isNotEmpty ? widget.profile.name : 'friend';

  try {
    await _flutterTts.setLanguage('en-ZA');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.4);
    await _flutterTts.awaitSpeakCompletion(true);

    final String message = "Hello $name, today is $day, $date";
    print("TTS: Speaking date - $message");

    await _flutterTts.speak(message);
  } catch (e) {
    print("TTS Error in _speakDate: $e");
  }
}

  List<Widget> _buildCalendarGrid() {
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startWeekday = firstDayOfMonth.weekday;

    List<Widget> dayWidgets = [];

    // Weekday headers
    const daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    dayWidgets.addAll(daysOfWeek.map((d) => Center(
          child: Text(d, style: const TextStyle(fontWeight: FontWeight.bold)),
        )));

    // Leading empty days
    for (int i = 1; i < startWeekday; i++) {
      dayWidgets.add(const SizedBox());
    }

    // Calendar days
    for (int i = 1; i <= daysInMonth; i++) {
      final isToday = now.day == i;
      dayWidgets.add(
        Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isToday ? Colors.indigo : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              '$i',
              style: TextStyle(
                fontSize: 16,
                color: isToday ? Colors.white : Colors.black87,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      );
    }

    return dayWidgets;
  }

  @override
  Widget build(BuildContext context) {
    final dayOfWeek = DateFormat('EEEE').format(now);
    final dateText = DateFormat('MMMM d, yyyy').format(now);
    final monthYear = DateFormat('MMMM yyyy').format(now);

    return Scaffold(
      appBar: AppBar(
        title: const Text('What Day is it Today?'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Hi ${widget.profile.name}, today is:',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            Text(
              dayOfWeek,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            const SizedBox(height: 8),
            Text(
              dateText,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Text(monthYear, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.count(
                crossAxisCount: 7,
                childAspectRatio: 1.2,
                physics: const NeverScrollableScrollPhysics(),
                children: _buildCalendarGrid(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => GameScreen(profile: widget.profile)),
                );
              },
              child: const Text('Play Game', style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
