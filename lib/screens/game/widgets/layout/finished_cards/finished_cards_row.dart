import 'package:flutter/cupertino.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../constants/constants.dart';
import '../../../game_controller.dart';
import '../../cards/finished_cards.dart';

class FinishedCardsRow extends WatchingWidget {
  final double cardHeight;
  final double cardWidth;

  const FinishedCardsRow({
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final state = watchIt<GameController>().value;
    final finishedCards = state.finishedCards;

    return Row(
      children: List.generate(
        finishedCards.length,
        (index) => Padding(
          padding: const EdgeInsets.only(left: padding),
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
