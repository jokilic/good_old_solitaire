import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../game_controller.dart';
import 'main_cards_column.dart';

class MainCardsRow extends WatchingWidget {
  final double cardHeight;
  final double cardWidth;

  const MainCardsRow({
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final state = watchIt<GameController>().value;
    final mainCards = state.mainCards;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        mainCards.length,
        (index) => Expanded(
          child: MainCardsColumn(
            column: index,
            cardHeight: cardHeight,
            cardWidth: cardWidth,
          ),
        ),
      ),
    );
  }
}
