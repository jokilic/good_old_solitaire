import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/enums.dart';
import '../../../../models/drag_payload.dart';
import '../../../../models/solitaire_card.dart';
import '../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../card/card_empty.dart';
import '../card/card_frame.dart';
import '../card/card_widget.dart';
import '../drag_feedback.dart';

class DrawingOpenedCards extends WatchingWidget {
  final double cardHeight;
  final double cardWidth;

  const DrawingOpenedCards({
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();
    final state = watchIt<GameController>().value;

    final openedCards = state.drawingOpenedCards;
    final hasCards = openedCards.isNotEmpty;

    final isSelected = state.selectedCard?.source == PileType.drawingOpenedCards;

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
            ? DraggableOpenedCard(
                topCard: openedCards.last,
                dragPayload: dragPayload,
                cardHeight: cardHeight,
                cardWidth: cardWidth,
                isSelected: isSelected,
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

class DraggableOpenedCard extends StatelessWidget {
  final SolitaireCard topCard;
  final DragPayload dragPayload;
  final double cardHeight;
  final double cardWidth;
  final bool isSelected;

  const DraggableOpenedCard({
    required this.topCard,
    required this.dragPayload,
    required this.cardHeight,
    required this.cardWidth,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) => Draggable<DragPayload>(
    data: dragPayload,
    feedback: DragFeedback(
      card: topCard,
      height: cardHeight,
      width: cardWidth,
    ),
    childWhenDragging: Opacity(
      opacity: 0.35,
      child: CardWidget(
        card: topCard,
        width: cardWidth,
        height: cardHeight,
        isSelected: isSelected,
      ),
    ),
    child: CardWidget(
      card: topCard,
      width: cardWidth,
      height: cardHeight,
      isSelected: isSelected,
    ),
  );
}
