import 'package:flutter/material.dart';

import '../../../../../../../constants/constants.dart';
import '../../cards/finished_cards.dart';

class FinishedCardsRow extends StatelessWidget {
  final String instanceId;
  final List<GlobalKey> pileKeys;
  final bool isAnimatingMove;
  final Future<void> Function(int index) onTapMoveSelected;

  const FinishedCardsRow({
    required this.instanceId,
    required this.pileKeys,
    required this.isAnimatingMove,
    required this.onTapMoveSelected,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (context, constraints) {
        final slotCount = pileKeys.length;
        final slotWidth = (constraints.maxWidth - SolitaireConstants.padding * (slotCount - 1)) / slotCount;
        final cardWidth = slotWidth > 0 ? slotWidth : 0.0;
        final cardHeight = cardWidth * SolitaireConstants.cardAspectRatio;

        return Row(
          children: List.generate(
            slotCount,
            (index) => Padding(
              padding: EdgeInsets.only(
                right: index == slotCount - 1 ? 0 : SolitaireConstants.padding,
              ),
              child: SizedBox(
                width: cardWidth,
                child: FinishedCards(
                  instanceId: instanceId,
                  index: index,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                  pileKey: pileKeys[index],
                  isAnimatingMove: isAnimatingMove,
                  onTapMoveSelected: onTapMoveSelected,
                ),
              ),
            ),
          ),
        );
      },
    );
}
