import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
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
  final bool revealFromRight;

  const DrawingOpenedCards({
    required this.cardHeight,
    required this.cardWidth,
    required this.pileKey,
    required this.hideTopCard,
    this.revealFromRight = false,
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
    required bool shouldAnimateReveal,
    required int revealVersion,
    required double revealShiftX,
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

    final topCard = DraggableOpenedCard(
      topCard: openedCards.last,
      cardUnderTop: cardUnderTop,
      dragPayload: dragPayload,
      cardHeight: cardHeight,
      cardWidth: cardWidth,
      isSelected: isSelected,
    );

    if (!shouldAnimateReveal) {
      return topCard;
    }

    return Animate(
      key: ValueKey('drawing-reveal-$revealVersion'),
      effects: [
        MoveEffect(
          begin: Offset(revealFromRight ? revealShiftX : -revealShiftX, 0),
          end: Offset.zero,
          duration: SolitaireDurations.animation,
          curve: Curves.easeIn,
        ),
        const ScaleEffect(
          begin: Offset(0.92, 0.92),
          end: Offset(1, 1),
          duration: SolitaireDurations.animation,
          curve: Curves.easeIn,
        ),
        const FadeEffect(
          begin: 0.2,
          end: 1,
          duration: SolitaireDurations.animation,
          curve: Curves.easeIn,
        ),
      ],
      child: topCard,
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();
    final state = watchIt<GameController>().value;
    final effectiveCardHeight = cardHeight - 2;

    final openedCards = state.drawingOpenedCards;
    final hasCards = openedCards.isNotEmpty;
    final revealVersion = state.drawingRevealVersion;
    final revealCardKey = state.drawingRevealCardKey;

    final isSelected = state.selectedCard?.source == PileType.drawingOpenedCards;

    const dragPayload = DragPayload(
      source: PileType.drawingOpenedCards,
      pileIndex: 0,
    );

    final cardUnderTop = openedCards.length > 1 ? openedCards[openedCards.length - 2] : null;
    final shouldAnimateReveal = hasCards && revealVersion > 0 && revealCardKey == openedCards.last.revealKey;

    return GestureDetector(
      onTap: controller.selectUnopenedSectionTop,
      child: CardFrame(
        key: pileKey,
        height: effectiveCardHeight,
        width: cardWidth,
        child: getOpenedCardView(
          hasCards: hasCards,
          hideTopCard: hideTopCard,
          cardHeight: effectiveCardHeight,
          cardWidth: cardWidth,
          openedCards: openedCards,
          cardUnderTop: cardUnderTop,
          dragPayload: dragPayload,
          isSelected: isSelected,
          shouldAnimateReveal: shouldAnimateReveal,
          revealVersion: revealVersion,
          revealShiftX: cardWidth + SolitaireConstants.padding,
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
    onDragStarted: () {
      setPressed(true);
      unawaited(getIt.get<SoundService>().playCardLift());
    },
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
