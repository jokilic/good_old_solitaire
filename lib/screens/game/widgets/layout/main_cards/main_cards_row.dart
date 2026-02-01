import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../game_controller.dart';
import 'main_cards_column.dart';

class MainCardsRow extends WatchingWidget {
  final double cardHeight;
  final double cardWidth;
  final List<GlobalKey> columnKeys;
  final bool isAnimatingMove;
  final int? hiddenTopCardColumn;
  final Future<void> Function(int column) onTapMoveSelected;

  const MainCardsRow({
    required this.cardHeight,
    required this.cardWidth,
    required this.columnKeys,
    required this.isAnimatingMove,
    required this.hiddenTopCardColumn,
    required this.onTapMoveSelected,
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
            columnKey: columnKeys[index],
            hideTopCard: hiddenTopCardColumn == index,
            isAnimatingMove: isAnimatingMove,
            onTapMoveSelected: onTapMoveSelected,
          ),
        ),
      ),
    );
  }
}
