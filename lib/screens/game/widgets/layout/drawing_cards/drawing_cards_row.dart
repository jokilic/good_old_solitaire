import 'package:flutter/cupertino.dart';

import '../../../../../constants/constants.dart';
import '../../cards/drawing_unopened_cards.dart';

class DrawingCardsRow extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;

  const DrawingCardsRow({
    required this.cardHeight,
    required this.cardWidth,
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
      DrawingUnopenedCards(
        cardHeight: cardHeight,
        cardWidth: cardWidth,
      ),
    ],
  );
}
