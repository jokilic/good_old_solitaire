import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../constants/enums.dart';
import '../../../../../models/drag_payload.dart';
import '../../../../../util/dependencies.dart';
import '../../../game_controller.dart';
import '../../card/card_empty.dart';
import '../../card/card_frame.dart';
import '../../card/card_main.dart';

class MainCardsColumn extends WatchingWidget {
  final int column;
  final double cardHeight;
  final double cardWidth;

  const MainCardsColumn({
    required this.column,
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();
    final state = watchIt<GameController>().value;

    final mainCards = state.mainCards[column];
    final isSelected = state.selectedCard?.source == PileType.mainCards && state.selectedCard?.pileIndex == column;

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnMain(details.data, column),
      onAcceptWithDetails: (details) => controller.moveDragToMain(details.data, column),
      builder: (context, _, __) => GestureDetector(
        onTap: () {
          if (state.selectedCard != null && !(state.selectedCard!.source == PileType.mainCards && state.selectedCard!.pileIndex == column)) {
            controller.tryMoveSelectedToMain(column);
            return;
          }

          if (mainCards.isEmpty) {
            controller.tryMoveSelectedToMain(column);
            return;
          }

          final top = mainCards.last;
          if (!top.faceUp) {
            controller.flipMainCardsTop(column);
            return;
          }

          controller.selectMainCardsTop(column);
        },
        child: CardFrame(
          height: cardHeight,
          width: cardWidth,
          heightMultiplier: 10,
          child: Stack(
            children: [
              if (mainCards.isEmpty)
                CardEmpty(
                  height: cardHeight,
                  width: cardWidth,
                  label: 'K',
                ),
              for (var i = 0; i < mainCards.length; i += 1)
                Positioned(
                  top: i * 20.0,
                  child: CardMain(
                    card: mainCards[i],
                    column: column,
                    cardIndex: i,
                    stack: mainCards.sublist(i),
                    height: cardHeight,
                    width: cardWidth,
                    isSelected: isSelected && i == mainCards.length - 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
