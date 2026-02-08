import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../../constants/constants.dart';

class CardEmpty extends StatelessWidget {
  final double height;
  final double width;
  final PhosphorIconData? icon;

  const CardEmpty({
    required this.height,
    required this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(SolitaireConstants.borderRadius),
      border: Border.all(
        color: Colors.white12,
        width: SolitaireConstants.borderWidth,
      ),
      color: Colors.white12,
    ),
    child: icon != null
        ? PhosphorIcon(
            icon!,
            color: Colors.white12,
            size: 24,
          )
        : null,
  );
}
