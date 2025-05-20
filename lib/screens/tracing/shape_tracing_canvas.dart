import 'package:flutter/material.dart';

class ShapeTracingCanvas extends StatefulWidget {
  final String shape;
  const ShapeTracingCanvas({super.key, required this.shape});

  @override
  State<ShapeTracingCanvas> createState() => _ShapeTracingCanvasState();
}

class _ShapeTracingCanvasState extends State<ShapeTracingCanvas> {
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
        title: Text('Trace Shape: ${widget.shape}', style: const TextStyle(fontSize: 26)),
        backgroundColor: Colors.teal,
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
          painter: ShapePainter(points: points, shape: widget.shape),
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

class ShapePainter extends CustomPainter {
  final List<Offset> points;
  final String shape;

  ShapePainter({required this.points, required this.shape});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint tracePaint = Paint()
      ..color = Colors.green
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6.0;

    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: shape,
        style: TextStyle(
          fontSize: 160,
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