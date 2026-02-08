import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../../../constants/durations.dart';
import '../../../../../../../constants/enums.dart';
import '../../../../../../../models/drag_payload.dart';
import '../../../../../../../util/card_size.dart';
import '../../../../../../../util/dependencies.dart';
import '../../../../../../../util/main_stack_layout.dart';
import '../../../game_controller.dart';
import '../../card/card_empty.dart';
import '../../card/card_frame.dart';
import '../../card/card_main.dart';

class MainCardsColumn extends WatchingWidget {
  final String instanceId;
  final int column;
  final double cardHeight;
  final double cardWidth;
  final bool isWideUi;
  final double stackHeightMultiplier;
  final GlobalKey columnKey;
  final bool hideTopCard;
  final bool isAnimatingMove;
  final bool isInitialDealAnimating;
  final int initialDealAnimationVersion;
  final Future<void> Function(int column)? onTapMoveSelected;

  const MainCardsColumn({
    required this.instanceId,
    required this.column,
    required this.cardHeight,
    required this.cardWidth,
    required this.isWideUi,
    required this.stackHeightMultiplier,
    required this.columnKey,
    required this.hideTopCard,
    required this.isAnimatingMove,
    required this.isInitialDealAnimating,
    required this.initialDealAnimationVersion,
    required this.onTapMoveSelected,
  });

  int getDealOrder({
    required int column,
    required int row,
  }) {
    if (row > column) {
      return 0;
    }

    final cardsBeforeRow = row * 7 - ((row * (row - 1)) ~/ 2);
    return cardsBeforeRow + (column - row);
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>(
      instanceName: instanceId,
    );
    final state = watchIt<GameController>(
      instanceName: instanceId,
    ).value;

    final mainCards = state.mainCards[column];
    final revealVersion = state.mainRevealVersions[column];
    final revealCardKey = state.mainRevealCardKeys[column];
    final shouldApplyDropSettle =
        state.dropSettleTarget == PileType.mainCards && state.dropSettlePileIndex == column && state.dropSettleCardKeys.isNotEmpty && state.dropSettleFromOffset != null;

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
      final isSameColumnSelected = selectedCard?.source == PileType.mainCards && selectedCard?.pileIndex == column;

      if (selectedCard != null && !isSameColumnSelected) {
        final selectedStack = controller.selectedStackFrom(
          selectedCard,
          drawingOpenedCards: latestState.drawingOpenedCards,
          mainCards: latestState.mainCards,
        );
        final canMoveSelected = selectedStack.isNotEmpty && controller.canMoveToMain(selectedStack.first, columnCards);

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
      onAcceptWithDetails: (details) => controller.moveDragToMain(
        details.data,
        column,
        dropOffset: details.offset,
      ),
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
                  icon: PhosphorIcons.crown(
                    PhosphorIconsStyle.thin,
                  ),
                ),
              for (var i = 0; i < mainCards.length; i += 1)
                Positioned(
                  top: mainStackTopOffset(
                    mainCards,
                    i,
                    cardWidth: cardWidth,
                    isWideUi: isWideUi,
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
                      final dropSettleIndex = shouldApplyDropSettle ? state.dropSettleCardKeys.indexOf(card.revealKey) : -1;
                      final shouldAnimateDropSettle = dropSettleIndex >= 0;

                      final cardMain = CardMain(
                        instanceId: instanceId,
                        card: card,
                        column: column,
                        cardIndex: i,
                        stack: mainCards.sublist(i),
                        height: cardHeight,
                        width: cardWidth,
                        isSelected: isSelected && i >= selectedStartIndex,
                        onTap: () => handleTap(cardIndex: i),
                      );

                      Widget child = cardMain;

                      if (shouldAnimateReveal) {
                        child = Animate(
                          key: ValueKey('main-reveal-$column-$revealVersion'),
                          effects: const [
                            FlipEffect(
                              duration: SolitaireDurations.animation,
                              curve: Curves.easeIn,
                              direction: Axis.horizontal,
                            ),
                          ],
                          child: child,
                        );
                      }

                      if (!shouldAnimateDropSettle) {
                        if (!isInitialDealAnimating || initialDealAnimationVersion == 0) {
                          return child;
                        }

                        final cardRect = controller.mainCardRect(
                          column,
                          i,
                          isWideUi: isWideUi,
                        );
                        final mediaSize = MediaQuery.sizeOf(context);
                        final sourceTopLeft = Offset(
                          (mediaSize.width - cardWidth) / 2,
                          mediaSize.height + cardHeight,
                        );
                        final fromDelta = cardRect == null ? Offset.zero : sourceTopLeft - cardRect.topLeft;
                        final shouldAnimateDeal = cardRect != null && fromDelta.distance > 0.5;

                        if (!shouldAnimateDeal) {
                          return child;
                        }

                        final dealOrder = getDealOrder(
                          column: column,
                          row: i,
                        );

                        return Animate(
                          key: ValueKey(
                            'main-initial-deal-$initialDealAnimationVersion-$column-$i-${card.revealKey}',
                          ),
                          effects: [
                            MoveEffect(
                              begin: fromDelta,
                              end: Offset.zero,
                              delay: SolitaireDurations.initialDealStaggerDuration * dealOrder,
                              duration: SolitaireDurations.initialDealMoveDuration,
                              curve: Curves.easeOutCubic,
                            ),
                          ],
                          child: child,
                        );
                      }

                      final toRect = controller.mainCardRect(
                        column,
                        i,
                        isWideUi: isWideUi,
                      );
                      final fromTopLeft =
                          state.dropSettleFromOffset! +
                          Offset(
                            0,
                            dropSettleIndex *
                                mainStackOffsetFromCardWidth(
                                  cardWidth,
                                  isWideUi: isWideUi,
                                ),
                          );
                      final dropDelta = toRect == null ? Offset.zero : fromTopLeft - toRect.topLeft;
                      final shouldUseDropSettle = toRect != null && dropDelta.distance > 0.5;

                      if (!shouldUseDropSettle) {
                        return child;
                      }

                      return Animate(
                        key: ValueKey('main-drop-settle-$column-${state.dropSettleVersion}-${card.revealKey}'),
                        effects: [
                          MoveEffect(
                            begin: dropDelta,
                            end: Offset.zero,
                            duration: SolitaireDurations.animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ],
                        child: child,
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
