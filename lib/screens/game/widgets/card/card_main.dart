import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../../../../constants/enums.dart';
import '../../../../models/drag_payload.dart';
import '../../../../models/solitaire_card.dart';
import '../../../../services/sound_service.dart';
import '../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../animated_return_draggable.dart';
import '../stack_drag_feedback.dart';
import 'card_widget.dart';

class CardMain extends StatefulWidget {
  final SolitaireCard card;
  final int column;
  final int cardIndex;
  final List<SolitaireCard> stack;
  final double height;
  final double width;
  final bool isSelected;
  final VoidCallback? onTap;

  const CardMain({
    required this.card,
    required this.column,
    required this.cardIndex,
    required this.stack,
    required this.height,
    required this.width,
    this.isSelected = false,
    this.onTap,
  });

  @override
  State<CardMain> createState() => _CardMainState();
}

class _CardMainState extends State<CardMain> {
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
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();

    final body = CardWidget(
      card: widget.card,
      height: widget.height,
      width: widget.width,
      isSelected: widget.isSelected,
      isLifted: isPressed,
    );

    final tappableBody = widget.onTap == null
        ? body
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (_) => setPressed(true),
            onTapUp: (_) => setPressed(false),
            onTapCancel: () => setPressed(false),
            onTap: widget.onTap,
            child: body,
          );

    if (!widget.card.faceUp) {
      return tappableBody;
    }

    final payload = DragPayload(
      source: PileType.mainCards,
      pileIndex: widget.column,
      cardIndex: widget.cardIndex,
    );

    return AnimatedReturnDraggable<DragPayload>(
      data: payload,
      feedback: StackDragFeedback(
        cards: widget.stack,
        height: widget.height,
        width: widget.width,
      ),
      onDragStarted: () {
        setPressed(true);
        controller.setDraggingPayload(payload);
      },
      onDragEnd: (details) {
        setPressed(false);
        if (details.wasAccepted) {
          controller.setDraggingPayload(null);
        }
      },
      onDragCompleted: () {
        setPressed(false);
        controller.setDraggingPayload(null);
      },
      onReturnAnimationCompleted: () {
        setPressed(false);
        controller.setDraggingPayload(null);
        unawaited(getIt.get<SoundService>().playCardPlace());
      },
      childWhenDragging: tappableBody,
      child: tappableBody,
    );
  }
}
