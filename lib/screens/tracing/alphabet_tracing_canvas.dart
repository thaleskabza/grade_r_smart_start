import 'package:flutter/material.dart';

class AlphabetTracingCanvas extends StatefulWidget {
  final String letter;
  const AlphabetTracingCanvas({super.key, required this.letter});

  @override
  State<AlphabetTracingCanvas> createState() => _AlphabetTracingCanvasState();
}

class _AlphabetTracingCanvasState extends State<AlphabetTracingCanvas> {
  List<Offset> points = [];

  void _clearCanvas() {
    setState(() {
      points.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trace: ${widget.letter}', style: const TextStyle(fontSize: 26)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Clear',
            onPressed: _clearCanvas,
          )
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          RenderBox? box = context.findRenderObject() as RenderBox?;
          Offset localPosition = box!.globalToLocal(details.globalPosition);
          setState(() {
            points.add(localPosition);
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(Offset.zero);
          });
        },
        child: CustomPaint(
          painter: TracingPainter(points: points, letter: widget.letter),
          child: Container(
            color: Colors.white,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}

class TracingPainter extends CustomPainter {
  final List<Offset> points;
  final String letter;

  TracingPainter({required this.points, required this.letter});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint tracePaint = Paint()
      ..color = Colors.blueAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;

    final Paint letterPaint = Paint()
      ..color = Colors.grey.withOpacity(0.3);

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: letter,
        style: TextStyle(
          fontSize: 200,
          color: Colors.grey.withOpacity(0.2),
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(canvas, Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    ));

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != Offset.zero && points[i + 1] != Offset.zero) {
        canvas.drawLine(points[i], points[i + 1], tracePaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}