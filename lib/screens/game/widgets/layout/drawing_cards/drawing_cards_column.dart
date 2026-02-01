import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import '../../cards/drawing_opened_cards.dart';
import '../../cards/drawing_unopened_cards.dart';

class DrawingCardsColumn extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;
  final GlobalKey drawingOpenedKey;
  final bool hideOpenedTopCard;

  const DrawingCardsColumn({
    required this.cardHeight,
    required this.cardWidth,
    required this.drawingOpenedKey,
    required this.hideOpenedTopCard,
  });

  @override
  Widget build(BuildContext context) => Column(
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
}
