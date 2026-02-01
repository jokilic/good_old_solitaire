import 'package:flutter/material.dart';

import '../../../../constants/enums.dart';
import '../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../card/card_empty.dart';
import '../card/card_frame.dart';
import '../card/card_widget.dart';
import '../drag_feedback.dart';

class DrawingOpenedCards extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;

  const DrawingOpenedCards({
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();

    final hasCards = controller.drawingOpenedCards.isNotEmpty;
    final isSelected = controller.selected?.source == PileType.drawingOpenedCards;

    const dragPayload = DragPayload(
      source: PileType.drawingOpenedCards,
      pileIndex: 0,
    );

    return GestureDetector(
      onTap: controller.selectWasteTop,
      child: CardFrame(
        height: cardHeight,
        width: cardWidth,
        child: hasCards
            ? Draggable<DragPayload>(
                data: dragPayload,
                feedback: DragFeedback(
                  card: controller.drawingOpenedCards.last,
                  height: cardHeight,
                  width: cardWidth,
                ),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: CardWidget(
                    card: controller.drawingOpenedCards.last,
                    width: cardWidth,
                    height: cardHeight,
                    isSelected: isSelected,
                  ),
                ),
                child: CardWidget(
                  card: controller.drawingOpenedCards.last,
                  width: cardWidth,
                  height: cardHeight,
                  isSelected: isSelected,
                ),
              )
            : CardEmpty(
                height: cardHeight,
                width: cardWidth,
                label: 'Waste',
              ),
      ),
    );
  }
}
