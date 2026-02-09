import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../../constants/durations.dart';
import '../../../../../../constants/enums.dart';
import '../../../../../../models/drag_payload.dart';
import '../../../../../../models/solitaire_card.dart';
import '../../../../../../services/sound_service.dart';
import '../../../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../animated_return_draggable.dart';
import '../card/card_empty.dart';
import '../card/card_frame.dart';
import '../card/card_widget.dart';
import '../drag_feedback.dart';

class FinishedCards extends WatchingWidget {
  final String instanceId;
  final int index;
  final double cardHeight;
  final double cardWidth;
  final GlobalKey pileKey;
  final bool isAnimatingMove;
  final Future<void> Function(int index)? onTapMoveSelected;

  const FinishedCards({
    required this.instanceId,
    required this.index,
    required this.cardHeight,
    required this.cardWidth,
    required this.pileKey,
    required this.isAnimatingMove,
    required this.onTapMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>(
      instanceName: instanceId,
    );
    final finishedCards = watchPropertyValue<GameController, List<SolitaireCard>>(
      (x) => x.value.finishedCards[index],
      instanceName: instanceId,
    );
    final hasSelectedCard = watchPropertyValue<GameController, bool>(
      (x) => x.value.selectedCard != null,
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
    final hasCards = finishedCards.isNotEmpty;
    final shouldApplyDropSettle =
        hasCards &&
        dropSettleTarget == PileType.finishedCards &&
        dropSettlePileIndex == index &&
        dropSettleFromOffset != null &&
        dropSettleCardKeys.contains(finishedCards.last.revealKey);

    final cardUnderTop = finishedCards.length > 1 ? finishedCards[finishedCards.length - 2] : null;

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnFinished(details.data, index),
      onAcceptWithDetails: (details) => controller.moveDragToFinished(
        details.data,
        index,
        dropOffset: details.offset,
      ),
      builder: (context, _, __) => GestureDetector(
        onTap: () async {
          if (isAnimatingMove) {
            return;
          }

          if (hasSelectedCard && onTapMoveSelected != null) {
            await onTapMoveSelected!(index);
            return;
          }

          controller.tryMoveSelectedToFinished(index);
        },
        child: CardFrame(
          key: pileKey,
          height: effectiveCardHeight,
          width: cardWidth,
          child: () {
            if (!hasCards) {
              return CardEmpty(
                height: effectiveCardHeight,
                width: cardWidth,
                icon: PhosphorIcons.asteriskSimple(
                  PhosphorIconsStyle.thin,
                ),
              );
            }

            final child = DraggableFinishedCard(
              index: index,
              topCard: finishedCards.last,
              cardUnderTop: cardUnderTop,
              cardHeight: effectiveCardHeight,
              cardWidth: cardWidth,
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
              key: ValueKey('finished-drop-settle-$index-$dropSettleVersion'),
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
        isSelected: false,
        isLifted: isPressed,
      ),
    ),
  );
}
