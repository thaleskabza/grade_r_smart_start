import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final double value; // Should be between 0.0 and 1.0
  final Color color;
  final double height;
  final String? label;

  const ProgressBar({
    super.key,
    required this.value,
    this.color = Colors.green,
    this.height = 20.0,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(label!, style: const TextStyle(fontSize: 14)),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: LinearProgressIndicator(
            value: value.clamp(0.0, 1.0),
            minHeight: height,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
