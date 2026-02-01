import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../constants/constants.dart';
import '../../../game_controller.dart';
import '../../cards/finished_cards.dart';

class FinishedCardsColumn extends WatchingWidget {
  final double cardHeight;
  final double cardWidth;

  const FinishedCardsColumn({
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final state = watchIt<GameController>().value;
    final finishedCards = state.finishedCards;

    return Column(
      children: List.generate(
        finishedCards.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            top: index == 0 ? 0 : padding,
          ),
          child: FinishedCards(
            index: index,
            cardHeight: cardHeight,
            cardWidth: cardWidth,
          ),
        ),
      ),
    );
  }
}
