import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/images.dart';

class CardBack extends StatelessWidget {
  final double height;
  final double width;

  const CardBack({
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white,
        width: borderWidth,
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        SolitaireImages.cardBack,
        height: height,
        width: width,
        fit: BoxFit.cover,
      ),
    ),
  );
}
