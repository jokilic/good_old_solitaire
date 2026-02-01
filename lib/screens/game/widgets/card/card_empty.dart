import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';

class CardEmpty extends StatelessWidget {
  final double height;
  final double width;
  final String? label;

  const CardEmpty({
    required this.height,
    required this.width,
    this.label,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white30,
        width: borderWidth,
      ),
      color: Colors.white10,
    ),
    child: label != null
        ? Text(
            label!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          )
        : null,
  );
}
