import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../constants/constants.dart';
import '../../../game_controller.dart';
import '../../cards/finished_cards.dart';

class FinishedCardsRow extends WatchingWidget {
  final double cardHeight;
  final double cardWidth;
  final List<GlobalKey> pileKeys;
  final bool isAnimatingMove;
  final Future<void> Function(int index) onTapMoveSelected;

  const FinishedCardsRow({
    required this.cardHeight,
    required this.cardWidth,
    required this.pileKeys,
    required this.isAnimatingMove,
    required this.onTapMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    final state = watchIt<GameController>().value;
    final finishedCards = state.finishedCards;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        finishedCards.length,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: padding / 2),
          child: FinishedCards(
            index: index,
            cardHeight: cardHeight,
            cardWidth: cardWidth,
            pileKey: pileKeys[index],
            isAnimatingMove: isAnimatingMove,
            onTapMoveSelected: onTapMoveSelected,
          ),
        ),
      ),
    );
  }
}
