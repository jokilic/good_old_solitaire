import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../constants/constants.dart';
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
  final GlobalKey columnKey;
  final bool hideTopCard;
  final bool isAnimatingMove;
  final Future<void> Function(int column)? onTapMoveSelected;

  const MainCardsColumn({
    required this.column,
    required this.cardHeight,
    required this.cardWidth,
    required this.columnKey,
    required this.hideTopCard,
    required this.isAnimatingMove,
    required this.onTapMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();
    final state = watchIt<GameController>().value;

    final mainCards = state.mainCards[column];
    final isSelected = state.selectedCard?.source == PileType.mainCards && state.selectedCard?.pileIndex == column;
    final draggingPayload = state.draggingPayload;
    final isDraggingStack = draggingPayload?.source == PileType.mainCards && draggingPayload?.pileIndex == column;
    final selectedStartIndex = controller.getSelectedStartIndex(
      mainCards: mainCards,
      isSelected: isSelected,
    );

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnMain(details.data, column),
      onAcceptWithDetails: (details) => controller.moveDragToMain(details.data, column),
      builder: (context, _, __) => GestureDetector(
        onTap: () async {
          if (isAnimatingMove) {
            return;
          }

          if (state.selectedCard != null && !(state.selectedCard!.source == PileType.mainCards && state.selectedCard!.pileIndex == column)) {
            if (onTapMoveSelected != null) {
              await onTapMoveSelected!(column);
            } else {
              controller.tryMoveSelectedToMain(column);
            }
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
          key: columnKey,
          height: cardHeight,
          width: cardWidth,
          heightMultiplier: 10,
          child: Stack(
            children: [
              if (mainCards.isEmpty)
                CardEmpty(
                  height: cardHeight,
                  width: cardWidth,
                ),
              for (var i = 0; i < mainCards.length; i += 1)
                Positioned(
                  top: i * mainStackOffset,
                  child: Opacity(
                    opacity: () {
                      final isDraggedCard = isDraggingStack && draggingPayload!.cardIndex <= i;
                      final isHiddenSource = hideTopCard && i == mainCards.length - 1;

                      if (isHiddenSource) {
                        return 0.0;
                      }

                      return isDraggedCard ? 0.35 : 1.0;
                    }(),
                    child: CardMain(
                      card: mainCards[i],
                      column: column,
                      cardIndex: i,
                      stack: mainCards.sublist(i),
                      height: cardHeight,
                      width: cardWidth,
                      isSelected: isSelected && i >= selectedStartIndex,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
