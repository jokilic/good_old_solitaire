import 'dart:async';

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/enums.dart';
import '../../../../models/drag_payload.dart';
import '../../../../models/solitaire_card.dart';
import '../../../../services/sound_service.dart';
import '../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../animated_return_draggable.dart';
import '../card/card_empty.dart';
import '../card/card_frame.dart';
import '../card/card_widget.dart';
import '../drag_feedback.dart';

class DrawingOpenedCards extends WatchingWidget {
  final double cardHeight;
  final double cardWidth;
  final GlobalKey pileKey;
  final bool hideTopCard;

  const DrawingOpenedCards({
    required this.cardHeight,
    required this.cardWidth,
    required this.pileKey,
    required this.hideTopCard,
  });

  Widget getOpenedCardView({
    required bool hasCards,
    required bool hideTopCard,
    required double cardHeight,
    required double cardWidth,
    required List<SolitaireCard> openedCards,
    required SolitaireCard? cardUnderTop,
    required DragPayload dragPayload,
    required bool isSelected,
  }) {
    Widget empty() => CardEmpty(
      height: cardHeight,
      width: cardWidth,
    );

    Widget underTopOrEmpty() {
      final card = cardUnderTop;

      if (card == null) {
        return empty();
      }

      return CardWidget(
        card: card,
        width: cardWidth,
        height: cardHeight,
        isSelected: false,
      );
    }

    if (!hasCards) {
      return empty();
    }

    if (hideTopCard) {
      return underTopOrEmpty();
    }

    return DraggableOpenedCard(
      topCard: openedCards.last,
      cardUnderTop: cardUnderTop,
      dragPayload: dragPayload,
      cardHeight: cardHeight,
      cardWidth: cardWidth,
      isSelected: isSelected,
    );
  }

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

    final cardUnderTop = openedCards.length > 1 ? openedCards[openedCards.length - 2] : null;

    return GestureDetector(
      onTap: controller.selectUnopenedSectionTop,
      child: CardFrame(
        key: pileKey,
        height: cardHeight,
        width: cardWidth,
        child: getOpenedCardView(
          hasCards: hasCards,
          hideTopCard: hideTopCard,
          cardHeight: cardHeight,
          cardWidth: cardWidth,
          openedCards: openedCards,
          cardUnderTop: cardUnderTop,
          dragPayload: dragPayload,
          isSelected: isSelected,
        ),
      ),
    );
  }
}

class DraggableOpenedCard extends StatefulWidget {
  final SolitaireCard topCard;
  final SolitaireCard? cardUnderTop;
  final DragPayload dragPayload;
  final double cardHeight;
  final double cardWidth;
  final bool isSelected;

  const DraggableOpenedCard({
    required this.topCard,
    required this.cardUnderTop,
    required this.dragPayload,
    required this.cardHeight,
    required this.cardWidth,
    required this.isSelected,
  });

  @override
  State<DraggableOpenedCard> createState() => _DraggableOpenedCardState();
}

class _DraggableOpenedCardState extends State<DraggableOpenedCard> {
  bool isPressed = false;

  void setPressed(bool value) {
    if (isPressed == value) {
      return;
    }

    if (value) {
      unawaited(getIt.get<SoundService>().playCardLift());
    }

    setState(() {
      isPressed = value;
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedReturnDraggable<DragPayload>(
    data: widget.dragPayload,
    feedback: DragFeedback(
      card: widget.topCard,
      height: widget.cardHeight,
      width: widget.cardWidth,
    ),
    onDragStarted: () => setPressed(true),
    onDragEnd: (_) => setPressed(false),
    onDragCompleted: () => setPressed(false),
    onReturnAnimationCompleted: () {
      setPressed(false);
      unawaited(getIt.get<SoundService>().playCardPlace());
    },
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
        isSelected: widget.isSelected,
        isLifted: isPressed,
      ),
    ),
  );
}
