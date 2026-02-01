import 'dart:math';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';
import '../../../../models/solitaire_card.dart';
import 'card_label.dart';

class CardFront extends StatelessWidget {
  final SolitaireCard card;
  final double width;
  final double height;

  const CardFront({
    required this.card,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final color = card.isRed ? Colors.red : Colors.black;
    final label = card.cardLabel;
    final icon = card.suitIcon;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          width: borderWidth,
        ),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: CardLabel(
                label: label,
                color: color,
              ),
            ),
            Align(
              child: PhosphorIcon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Transform.rotate(
                angle: pi,
                child: CardLabel(
                  label: label,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
