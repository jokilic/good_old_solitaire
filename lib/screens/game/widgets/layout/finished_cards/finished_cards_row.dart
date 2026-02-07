import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../constants/constants.dart';
import '../../../game_controller.dart';
import '../../cards/finished_cards.dart';

class FinishedCardsRow extends WatchingWidget {
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
  Widget build(BuildContext context) {
    final state = watchIt<GameController>(
      instanceName: instanceId,
    ).value;
    final finishedCards = state.finishedCards;

    return LayoutBuilder(
      builder: (context, constraints) {
        final slotWidth = (constraints.maxWidth - SolitaireConstants.padding * (finishedCards.length - 1)) / finishedCards.length;
        final cardWidth = slotWidth > 0 ? slotWidth : 0.0;
        final cardHeight = cardWidth * SolitaireConstants.cardAspectRatio;

        return Row(
          children: List.generate(
            finishedCards.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                right: index == finishedCards.length - 1 ? 0 : SolitaireConstants.padding,
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
}
