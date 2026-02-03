import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../constants/constants.dart';
import '../../../game_controller.dart';
import '../../cards/finished_cards.dart';

class FinishedCardsRow extends WatchingWidget {
  final List<GlobalKey> pileKeys;
  final bool isAnimatingMove;
  final Future<void> Function(int index) onTapMoveSelected;

  const FinishedCardsRow({
    required this.pileKeys,
    required this.isAnimatingMove,
    required this.onTapMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    final state = watchIt<GameController>().value;
    final finishedCards = state.finishedCards;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          flex: 3,
          child: SizedBox.shrink(),
        ),
        ...List.generate(
          finishedCards.length,
          (index) => Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: padding / 2),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth;
                  final cardHeight = cardWidth * cardAspectRatio;

                  return FinishedCards(
                    index: index,
                    cardHeight: cardHeight,
                    cardWidth: cardWidth,
                    pileKey: pileKeys[index],
                    isAnimatingMove: isAnimatingMove,
                    onTapMoveSelected: onTapMoveSelected,
                  );
                },
              ),
            ),
          ),
        ),
        const Expanded(
          flex: 3,
          child: SizedBox.shrink(),
        ),
      ],
    );
  }
}
