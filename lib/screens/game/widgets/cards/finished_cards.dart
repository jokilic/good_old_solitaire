import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/enums.dart';
import '../../../../models/drag_payload.dart';
import '../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../card/card_empty.dart';
import '../card/card_frame.dart';
import '../card/card_widget.dart';
import '../drag_feedback.dart';

class FinishedCards extends WatchingWidget {
  final int index;
  final double cardHeight;
  final double cardWidth;
  final GlobalKey pileKey;
  final bool isAnimatingMove;
  final Future<void> Function(int index)? onTapMoveSelected;

  const FinishedCards({
    required this.index,
    required this.cardHeight,
    required this.cardWidth,
    required this.pileKey,
    required this.isAnimatingMove,
    required this.onTapMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();
    final state = watchIt<GameController>().value;

    final finishedCards = state.finishedCards[index];
    final hasCards = finishedCards.isNotEmpty;

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnFinished(details.data, index),
      onAcceptWithDetails: (details) => controller.moveDragToFinished(details.data, index),
      builder: (context, _, __) => GestureDetector(
        onTap: () async {
          if (isAnimatingMove) {
            return;
          }

          if (state.selectedCard != null && onTapMoveSelected != null) {
            await onTapMoveSelected!(index);
            return;
          }

          controller.tryMoveSelectedToFinished(index);
        },
        child: CardFrame(
          key: pileKey,
          height: cardHeight,
          width: cardWidth,
          child: hasCards
              ? Draggable<DragPayload>(
                  data: DragPayload(
                    source: PileType.finishedCards,
                    pileIndex: index,
                  ),
                  feedback: DragFeedback(
                    card: finishedCards.last,
                    height: cardHeight,
                    width: cardWidth,
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: CardWidget(
                      card: finishedCards.last,
                      width: cardWidth,
                      height: cardHeight,
                      isSelected: false,
                    ),
                  ),
                  child: CardWidget(
                    card: finishedCards.last,
                    width: cardWidth,
                    height: cardHeight,
                    isSelected: false,
                  ),
                )
              : CardEmpty(
                  height: cardHeight,
                  width: cardWidth,
                ),
        ),
      ),
    );
  }
}
