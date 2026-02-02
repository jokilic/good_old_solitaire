import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../constants/constants.dart';
import '../../../../models/solitaire_card.dart';
import 'card_label.dart';

class CardFront extends StatelessWidget {
  final SolitaireCard card;
  final double height;
  final double width;

  const CardFront({
    required this.card,
    required this.height,
    required this.width,
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
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 4,
            child: CardLabel(
              label: label,
              color: color,
            ),
          ),
          Positioned(
            top: 6,
            right: 4,
            child: ClipRect(
              child: PhosphorIcon(
                icon,
                color: color,
                size: 16,
              ),
            ),
          ),
          Positioned(
            bottom: -8,
            left: 0,
            right: -24,
            child: ClipRect(
              child: PhosphorIcon(
                icon,
                color: color,
                size: 56,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
