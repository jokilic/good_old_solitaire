import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import '../../cards/drawing_opened_cards.dart';
import '../../cards/drawing_unopened_cards.dart';

class DrawingCardsRow extends StatelessWidget {
  final GlobalKey drawingOpenedKey;
  final bool hideOpenedTopCard;

  const DrawingCardsRow({
    required this.drawingOpenedKey,
    required this.hideOpenedTopCard,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cardWidth = (constraints.maxWidth - padding) / 2;
      final cardHeight = cardWidth * cardAspectRatio;

      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: DrawingUnopenedCards(
              cardHeight: cardHeight,
              cardWidth: cardWidth,
            ),
          ),
          const SizedBox(width: padding),
          Expanded(
            child: DrawingOpenedCards(
              cardHeight: cardHeight,
              cardWidth: cardWidth,
              pileKey: drawingOpenedKey,
              hideTopCard: hideOpenedTopCard,
            ),
          ),
        ],
      );
    },
  );
}
