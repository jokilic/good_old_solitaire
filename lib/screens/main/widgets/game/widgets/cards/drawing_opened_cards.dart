import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../../constants/constants.dart';
import '../../../../../../constants/durations.dart';
import '../../../../../../constants/enums.dart';
import '../../../../../../models/cards/solitaire_card.dart';
import '../../../../../../models/drag_payload.dart';
import '../../../../../../models/settings/draw_cards_number.dart';
import '../../../../../../services/hive_service.dart';
import '../../../../../../services/sound_service.dart';
import '../../../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../animated_return_draggable.dart';
import '../card/card_frame.dart';
import '../card/card_widget.dart';
import '../drag_feedback.dart';

class DrawingOpenedCards extends WatchingWidget {
  static const maxVisibleCardsForDrawThree = 3;
  static const visibleCardOffsetFactor = 0.16;

  final String instanceId;
  final double cardHeight;
  final double cardWidth;
  final GlobalKey pileKey;
  final bool hideTopCard;
  final bool revealFromRight;

  const DrawingOpenedCards({
    required this.instanceId,
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
    required List<SolitaireCard> visibleCards,
    required DragPayload dragPayload,
    required bool isSelected,
    required bool shouldAnimateReveal,
    required int revealVersion,
    required double revealShiftX,
    required double visibleCardOffset,
  }) {
    Widget empty() => const SizedBox.shrink();

    if (!hasCards) {
      return empty();
    }

    final topCard = visibleCards.last;
    final underTopCards = visibleCards.take(visibleCards.length - 1).toList();

    Widget topCardView() => DraggableOpenedCard(
      topCard: topCard,
      dragPayload: dragPayload,
      cardHeight: cardHeight,
      cardWidth: cardWidth,
      isSelected: isSelected,
    );

    final stackedCards = <Widget>[
      for (var index = 0; index < underTopCards.length; index += 1)
        Positioned(
          top: visibleCardOffset * (underTopCards.length - index),
          child: CardWidget(
            card: underTopCards[index],
            width: cardWidth,
            height: cardHeight,
            isSelected: false,
          ),
        ),
      if (!hideTopCard)
        Positioned(
          top: 0,
          child: shouldAnimateReveal
              ? Animate(
                  key: ValueKey('drawing-reveal-$revealVersion'),
                  effects: [
                    MoveEffect(
                      begin: Offset(revealFromRight ? revealShiftX : -revealShiftX, 0),
                      end: Offset.zero,
                      duration: SolitaireDurations.animation,
                      curve: Curves.easeIn,
                    ),
                    ScaleEffect(
                      begin: const Offset(0.92, 0.92),
                      end: const Offset(1, 1),
                      duration: SolitaireDurations.animation,
                      curve: Curves.easeIn,
                    ),
                    FadeEffect(
                      begin: 0.2,
                      end: 1,
                      duration: SolitaireDurations.animation,
                      curve: Curves.easeIn,
                    ),
                  ],
                  child: topCardView(),
                )
              : topCardView(),
        ),
    ];

    if (stackedCards.isEmpty) {
      return empty();
    }

    return SizedBox(
      width: cardWidth,
      height: cardHeight + visibleCardOffset * (visibleCards.length - 1),
      child: Stack(
        clipBehavior: Clip.none,
        children: stackedCards,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>(
      instanceName: instanceId,
    );
    final openedCards = watchPropertyValue<GameController, List<SolitaireCard>>(
      (x) => x.value.drawingOpenedCards,
      instanceName: instanceId,
    );
    final drawCardsNumber = watchPropertyValue<HiveService, DrawCardsNumber>(
      (x) => x.value.settings?.drawCardsNumber ?? DrawCardsNumber.one,
    );
    final revealVersion = watchPropertyValue<GameController, int>(
      (x) => x.value.drawingRevealVersion,
      instanceName: instanceId,
    );
    final revealCardKey = watchPropertyValue<GameController, String?>(
      (x) => x.value.drawingRevealCardKey,
      instanceName: instanceId,
    );
    final isSelected = watchPropertyValue<GameController, bool>(
      (x) => x.value.selectedCard?.source == PileType.drawingOpenedCards,
      instanceName: instanceId,
    );

    final dropSettleTarget = watchPropertyValue<GameController, PileType?>(
      (x) => x.value.dropSettleTarget,
      instanceName: instanceId,
    );
    final dropSettlePileIndex = watchPropertyValue<GameController, int?>(
      (x) => x.value.dropSettlePileIndex,
      instanceName: instanceId,
    );
    final dropSettleFromOffset = watchPropertyValue<GameController, Offset?>(
      (x) => x.value.dropSettleFromOffset,
      instanceName: instanceId,
    );
    final dropSettleCardKeys = watchPropertyValue<GameController, List<String>>(
      (x) => x.value.dropSettleCardKeys,
      instanceName: instanceId,
    );
    final dropSettleVersion = watchPropertyValue<GameController, int>(
      (x) => x.value.dropSettleVersion,
      instanceName: instanceId,
    );

    final effectiveCardHeight = cardHeight - 2;
    final visibleCardOffset = effectiveCardHeight * visibleCardOffsetFactor;
    final maxVisibleCards = drawCardsNumber == DrawCardsNumber.three ? maxVisibleCardsForDrawThree : 1;

    final hasCards = openedCards.isNotEmpty;
    final visibleCards = openedCards.skip(openedCards.length > maxVisibleCards ? openedCards.length - maxVisibleCards : 0).toList();

    const dragPayload = DragPayload(
      source: PileType.drawingOpenedCards,
      pileIndex: 0,
    );

    final shouldAnimateReveal = hasCards && revealVersion > 0 && revealCardKey == openedCards.last.revealKey;
    final shouldApplyDropSettle =
        hasCards &&
        dropSettleTarget == PileType.drawingOpenedCards &&
        dropSettlePileIndex == null &&
        dropSettleFromOffset != null &&
        dropSettleCardKeys.contains(openedCards.last.revealKey);
    final heightMultiplier = hasCards ? 1 + (visibleCards.length - 1) * visibleCardOffsetFactor : 1.0;

    return GestureDetector(
      onTap: controller.selectUnopenedSectionTop,
      child: CardFrame(
        key: pileKey,
        height: effectiveCardHeight,
        width: cardWidth,
        heightMultiplier: heightMultiplier,
        child: () {
          final child = getOpenedCardView(
            hasCards: hasCards,
            hideTopCard: hideTopCard,
            cardHeight: effectiveCardHeight,
            cardWidth: cardWidth,
            visibleCards: visibleCards,
            dragPayload: dragPayload,
            isSelected: isSelected,
            shouldAnimateReveal: shouldAnimateReveal,
            revealVersion: revealVersion,
            revealShiftX: cardWidth + SolitaireConstants.padding,
            visibleCardOffset: visibleCardOffset,
          );

          if (!shouldApplyDropSettle) {
            return child;
          }

          final toRect = controller.rectFromKey(pileKey);
          final dropDelta = toRect == null ? Offset.zero : dropSettleFromOffset - toRect.topLeft;
          final shouldUseDropSettle = toRect != null && dropDelta.distance > 0.5;

          if (!shouldUseDropSettle) {
            return child;
          }

          return Animate(
            key: ValueKey('drawing-drop-settle-$dropSettleVersion'),
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
    );
  }
}

class DraggableOpenedCard extends StatefulWidget {
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
    childWhenDragging: const SizedBox.shrink(),
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
