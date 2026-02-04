import 'dart:async';

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/enums.dart';
import '../../../../models/drag_payload.dart';
import '../../../../models/solitaire_card.dart';
import '../../../../services/game_sound_service.dart';
import '../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../animated_return_draggable.dart';
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

    final cardUnderTop = finishedCards.length > 1 ? finishedCards[finishedCards.length - 2] : null;

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
              ? DraggableFinishedCard(
                  index: index,
                  topCard: finishedCards.last,
                  cardUnderTop: cardUnderTop,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
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

class DraggableFinishedCard extends StatefulWidget {
  final int index;
  final SolitaireCard topCard;
  final SolitaireCard? cardUnderTop;
  final double cardHeight;
  final double cardWidth;

  const DraggableFinishedCard({
    required this.index,
    required this.topCard,
    required this.cardUnderTop,
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  State<DraggableFinishedCard> createState() => _DraggableFinishedCardState();
}

class _DraggableFinishedCardState extends State<DraggableFinishedCard> {
  bool isPressed = false;

  void setPressed(bool value) {
    if (isPressed == value) {
      return;
    }

    if (value) {
      unawaited(getIt.get<GameSoundService>().playCardLift());
    }

    setState(() {
      isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedReturnDraggable<DragPayload>(
    data: DragPayload(
      source: PileType.finishedCards,
      pileIndex: widget.index,
    ),
    feedback: DragFeedback(
      card: widget.topCard,
      height: widget.cardHeight,
      width: widget.cardWidth,
    ),
    onDragStarted: () => setPressed(true),
    onDragEnd: (_) => setPressed(false),
    onDragCompleted: () => setPressed(false),
    onReturnAnimationCompleted: () => setPressed(false),
    childWhenDragging: widget.cardUnderTop != null
        ? CardWidget(
            card: widget.cardUnderTop!,
            width: widget.cardWidth,
            height: widget.cardHeight,
            isSelected: false,
          )
        : CardEmpty(
            height: widget.cardHeight,
            width: widget.cardWidth,
          ),
    child: Listener(
      onPointerDown: (_) => setPressed(true),
      onPointerUp: (_) => setPressed(false),
      onPointerCancel: (_) => setPressed(false),
      child: CardWidget(
        card: widget.topCard,
        width: widget.cardWidth,
        height: widget.cardHeight,
        isSelected: false,
        isLifted: isPressed,
      ),
    ),
  );
}
