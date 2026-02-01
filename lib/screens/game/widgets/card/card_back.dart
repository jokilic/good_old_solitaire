import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';

class CardBack extends StatelessWidget {
  final double width;
  final double height;

  const CardBack({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white70,
        width: borderWidth,
      ),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.blueGrey.shade800,
          Colors.blueGrey.shade900,
        ],
      ),
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Center(
      child: Container(
        height: height * 0.35,
        width: width * 0.55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: Colors.white30,
            width: borderWidth,
          ),
          color: Colors.white10,
        ),
      ),
    ),
  );
}
