import 'package:flutter/material.dart';

import '../../../../../../../constants/constants.dart';
import '../../../../../../../models/settings/draw_cards_position.dart';
import '../../cards/drawing_opened_cards.dart';
import '../../cards/drawing_unopened_cards.dart';

class DrawingCardsRow extends StatelessWidget {
  final String instanceId;
  final GlobalKey drawingUnopenedKey;
  final GlobalKey drawingOpenedKey;
  final bool hideOpenedTopCard;
  final DrawCardsPosition drawCardsPosition;

  const DrawingCardsRow({
    required this.instanceId,
    required this.drawingUnopenedKey,
    required this.drawingOpenedKey,
    required this.hideOpenedTopCard,
    required this.drawCardsPosition,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final cardWidth = (constraints.maxWidth - SolitaireConstants.padding) / 2;
      final cardHeight = cardWidth * SolitaireConstants.cardAspectRatio;
      final showOpenedCardsFirst = drawCardsPosition == DrawCardsPosition.right;

      Widget unopenedCards() => DrawingUnopenedCards(
        instanceId: instanceId,
        pileKey: drawingUnopenedKey,
        cardHeight: cardHeight,
        cardWidth: cardWidth,
      );

      Widget openedCards() => DrawingOpenedCards(
        instanceId: instanceId,
        cardHeight: cardHeight,
        cardWidth: cardWidth,
        pileKey: drawingOpenedKey,
        hideTopCard: hideOpenedTopCard,
        revealFromRight: showOpenedCardsFirst,
      );

      return Row(
        children: [
          Expanded(
            child: showOpenedCardsFirst ? openedCards() : unopenedCards(),
          ),
          const SizedBox(width: SolitaireConstants.padding),
          Expanded(
            child: showOpenedCardsFirst ? unopenedCards() : openedCards(),
          ),
        ],
      );
    },
  );
}
