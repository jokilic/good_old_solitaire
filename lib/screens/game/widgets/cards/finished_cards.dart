import 'package:flutter/material.dart';

import '../../../../constants/enums.dart';
import '../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../card/card_empty.dart';
import '../card/card_frame.dart';
import '../card/card_widget.dart';
import '../drag_feedback.dart';

class FinishedCards extends StatelessWidget {
  final int index;
  final double cardHeight;
  final double cardWidth;

  const FinishedCards({
    required this.index,
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();

    final finishedCards = controller.finishedCards[index];
    final hasCards = finishedCards.isNotEmpty;

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnFoundation(details.data, index),
      onAcceptWithDetails: (details) => controller.moveDragToFoundation(details.data, index),
      builder: (context, _, __) => GestureDetector(
        onTap: () => controller.tryMoveSelectedToFoundation(index),
        child: CardFrame(
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
                  label: 'A',
                ),
        ),
      ),
    );
  }
}
