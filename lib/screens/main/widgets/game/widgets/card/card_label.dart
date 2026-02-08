import 'package:flutter/material.dart';

class CardLabel extends StatelessWidget {
  final String label;
  final Color color;

  const CardLabel({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      color: color,
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1,
    ),
  );
}
