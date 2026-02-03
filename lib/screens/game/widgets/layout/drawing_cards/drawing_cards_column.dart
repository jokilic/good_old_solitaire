import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import '../../cards/drawing_opened_cards.dart';
import '../../cards/drawing_unopened_cards.dart';

class DrawingCardsColumn extends StatelessWidget {
  final GlobalKey drawingOpenedKey;
  final bool hideOpenedTopCard;

  const DrawingCardsColumn({
    required this.drawingOpenedKey,
    required this.hideOpenedTopCard,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cardWidth = constraints.maxWidth;
      final cardHeight = cardWidth * cardAspectRatio;

      return Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawingOpenedCards(
            cardHeight: cardHeight,
            cardWidth: cardWidth,
            pileKey: drawingOpenedKey,
            hideTopCard: hideOpenedTopCard,
          ),
          const SizedBox(height: padding),
          DrawingUnopenedCards(
            cardHeight: cardHeight,
            cardWidth: cardWidth,
          ),
        ],
      );
    },
  );
}
