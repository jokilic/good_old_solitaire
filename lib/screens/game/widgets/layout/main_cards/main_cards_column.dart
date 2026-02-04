import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../constants/durations.dart';
import '../../../../../constants/enums.dart';
import '../../../../../models/drag_payload.dart';
import '../../../../../util/dependencies.dart';
import '../../../../../util/main_stack_layout.dart';
import '../../../game_controller.dart';
import '../../card/card_empty.dart';
import '../../card/card_frame.dart';
import '../../card/card_main.dart';

class MainCardsColumn extends WatchingWidget {
  final int column;
  final double cardHeight;
  final double cardWidth;
  final double stackHeightMultiplier;
  final GlobalKey columnKey;
  final bool hideTopCard;
  final bool isAnimatingMove;
  final Future<void> Function(int column)? onTapMoveSelected;

  const MainCardsColumn({
    required this.column,
    required this.cardHeight,
    required this.cardWidth,
    required this.stackHeightMultiplier,
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
    final revealVersion = state.mainRevealVersions[column];
    final revealCardKey = state.mainRevealCardKeys[column];

    final selectedCard = state.selectedCard;
    final isSelected = selectedCard?.source == PileType.mainCards && selectedCard?.pileIndex == column;

    final draggingPayload = state.draggingPayload;
    final isDraggingStack = draggingPayload?.source == PileType.mainCards && draggingPayload?.pileIndex == column;
    final isDraggingAllFromColumn = isDraggingStack && draggingPayload!.cardIndex == 0;

    final selectedStartIndex = controller.getSelectedStartIndex(
      mainCards: mainCards,
      selectedCard: isSelected ? selectedCard : null,
    );
    final hideTapMovedStack = hideTopCard && isSelected && selectedStartIndex >= 0;
    final showEmptyPlaceholder = mainCards.isEmpty || isDraggingAllFromColumn || (hideTapMovedStack && selectedStartIndex == 0);

    Future<void> handleTap({int? cardIndex}) async {
      if (isAnimatingMove) {
        return;
      }

      final latestState = controller.value;
      final selectedCard = latestState.selectedCard;
      final columnCards = latestState.mainCards[column];
      final isSameColumnSelected =
          selectedCard?.source == PileType.mainCards &&
          selectedCard?.pileIndex == column;

      if (selectedCard != null && !isSameColumnSelected) {
        final selectedStack = controller.selectedStackFrom(
          selectedCard,
          drawingOpenedCards: latestState.drawingOpenedCards,
          mainCards: latestState.mainCards,
        );
        final canMoveSelected =
            selectedStack.isNotEmpty &&
            controller.canMoveToMain(selectedStack.first, columnCards);

        if (canMoveSelected) {
          if (onTapMoveSelected != null) {
            await onTapMoveSelected!(column);
          } else {
            controller.tryMoveSelectedToMain(column);
          }
          return;
        }
      }

      if (columnCards.isEmpty) {
        controller.tryMoveSelectedToMain(column);
        return;
      }

      final top = columnCards.last;
      if (!top.faceUp) {
        controller.flipMainCardsTop(column);
        return;
      }

      if (cardIndex != null) {
        controller.selectMainCardsAt(column, cardIndex);
        return;
      }

      controller.selectMainCardsTop(column);
    }

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnMain(details.data, column),
      onAcceptWithDetails: (details) => controller.moveDragToMain(details.data, column),
      builder: (context, _, __) => GestureDetector(
        onTap: handleTap,
        child: CardFrame(
          key: columnKey,
          height: cardHeight,
          width: cardWidth,
          heightMultiplier: stackHeightMultiplier,
          child: Stack(
            children: [
              if (showEmptyPlaceholder)
                CardEmpty(
                  height: cardHeight,
                  width: cardWidth,
                ),
              for (var i = 0; i < mainCards.length; i += 1)
                Positioned(
                  top: mainStackTopOffset(
                    mainCards,
                    i,
                    cardWidth: cardWidth,
                  ),
                  child: Opacity(
                    opacity: () {
                      final isDraggedCard = isDraggingStack && draggingPayload!.cardIndex <= i;
                      if (hideTapMovedStack && i >= selectedStartIndex) {
                        return 0.0;
                      }

                      return isDraggedCard ? 0.0 : 1.0;
                    }(),
                    child: () {
                      final card = mainCards[i];
                      final isTopCard = i == mainCards.length - 1;
                      final shouldAnimateReveal = isTopCard && card.faceUp && revealVersion > 0 && revealCardKey == card.revealKey;

                      final cardMain = CardMain(
                        card: card,
                        column: column,
                        cardIndex: i,
                        stack: mainCards.sublist(i),
                        height: cardHeight,
                        width: cardWidth,
                        isSelected: isSelected && i >= selectedStartIndex,
                        onTap: () => handleTap(cardIndex: i),
                      );

                      if (!shouldAnimateReveal) {
                        return cardMain;
                      }

                      return Animate(
                        key: ValueKey('main-reveal-$column-$revealVersion'),
                        effects: const [
                          FlipEffect(
                            duration: SolitaireDurations.animation,
                            curve: Curves.easeIn,
                            direction: Axis.horizontal,
                          ),
                        ],
                        child: cardMain,
                      );
                    }(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
