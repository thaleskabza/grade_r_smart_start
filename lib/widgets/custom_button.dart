import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final double width;
  final double height;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = Colors.orange,
    this.textColor = Colors.white,
    this.icon,
    this.width = double.infinity,
    this.height = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        icon: icon != null ? Icon(icon, color: textColor) : const SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(fontSize: 18, color: textColor),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
