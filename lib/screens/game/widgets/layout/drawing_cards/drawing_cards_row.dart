import 'package:flutter/cupertino.dart';

import '../../../../../constants/constants.dart';
import '../../cards/drawing_opened_cards.dart';
import '../../cards/drawing_unopened_cards.dart';

class DrawingCardsRow extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;
  final GlobalKey drawingOpenedKey;
  final bool hideOpenedTopCard;

  const DrawingCardsRow({
    required this.cardHeight,
    required this.cardWidth,
    required this.drawingOpenedKey,
    required this.hideOpenedTopCard,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      ///
      /// DRAWING UNOPENED CARDS
      ///
      DrawingUnopenedCards(
        cardHeight: cardHeight,
        cardWidth: cardWidth,
      ),
      const SizedBox(width: padding),

      ///
      /// DRAWING OPENED CARDS
      ///
      DrawingOpenedCards(
        cardHeight: cardHeight,
        cardWidth: cardWidth,
        pileKey: drawingOpenedKey,
        hideTopCard: hideOpenedTopCard,
      ),
    ],
  );
}
