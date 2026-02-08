import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import '../../cards/drawing_opened_cards.dart';
import '../../cards/drawing_unopened_cards.dart';

class DrawingCardsRow extends StatelessWidget {
  final String instanceId;
  final GlobalKey drawingOpenedKey;
  final bool hideOpenedTopCard;

  const DrawingCardsRow({
    required this.instanceId,
    required this.drawingOpenedKey,
    required this.hideOpenedTopCard,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cardWidth = (constraints.maxWidth - SolitaireConstants.padding) / 2;
      final cardHeight = cardWidth * SolitaireConstants.cardAspectRatio;

      return Row(
        children: [
          Expanded(
            child: DrawingUnopenedCards(
              instanceId: instanceId,
              cardHeight: cardHeight,
              cardWidth: cardWidth,
            ),
          ),
          const SizedBox(width: SolitaireConstants.padding),
          Expanded(
            child: DrawingOpenedCards(
              instanceId: instanceId,
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
