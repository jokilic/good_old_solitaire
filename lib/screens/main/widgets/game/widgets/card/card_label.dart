import 'package:flutter/material.dart';

class CardLabel extends StatelessWidget {
  final String label;
  final Color color;
  final double width;

  const CardLabel({
    required this.label,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) => Text(
    label,
    // TODO
    style: TextStyle(
      color: color,
      fontSize: width * 0.35,
      fontWeight: FontWeight.w700,
      height: 1,
    ),
  );
}
