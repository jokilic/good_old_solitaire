import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../constants/constants.dart';
import '../../../../../util/card_size.dart';
import '../../../game_controller.dart';
import 'main_cards_column.dart';

class MainCardsRow extends WatchingWidget {
  final List<GlobalKey> columnKeys;
  final bool isAnimatingMove;
  final int? hiddenTopCardColumn;
  final Future<void> Function(int column) onTapMoveSelected;

  const MainCardsRow({
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: padding / 2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                final cardHeight = cardWidth * cardAspectRatio;

                return MainCardsColumn(
                  column: index,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                  stackHeightMultiplier: mainStackHeightMultiplier(
                    cardHeight: cardHeight,
                    cardWidth: cardWidth,
                  ),
                  columnKey: columnKeys[index],
                  hideTopCard: hiddenTopCardColumn == index,
                  isAnimatingMove: isAnimatingMove,
                  onTapMoveSelected: onTapMoveSelected,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
