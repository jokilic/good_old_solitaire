import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/constants.dart';
import '../../../../../../constants/durations.dart';
import '../../../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../card/card_back.dart';
import '../card/card_empty.dart';
import '../card/card_frame.dart';

class DrawingUnopenedCards extends WatchingWidget {
  final String instanceId;
  final double cardHeight;
  final double cardWidth;

  const DrawingUnopenedCards({
    required this.instanceId,
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>(
      instanceName: instanceId,
    );
    final hasCards = watchPropertyValue<GameController, bool>(
      (x) => x.value.drawingUnopenedCards.isNotEmpty,
      instanceName: instanceId,
    );

    return PressableUnopenedCard(
      hasCards: hasCards,
      cardHeight: cardHeight,
      cardWidth: cardWidth,
      onTap: controller.drawFromUnopenedSection,
    );
  }
}

class PressableUnopenedCard extends StatefulWidget {
  final bool hasCards;
  final double cardHeight;
  final double cardWidth;
  final VoidCallback onTap;

  const PressableUnopenedCard({
    required this.hasCards,
    required this.cardHeight,
    required this.cardWidth,
    required this.onTap,
  });

  @override
  State<PressableUnopenedCard> createState() => _PressableUnopenedCardState();
}

class _PressableUnopenedCardState extends State<PressableUnopenedCard> {
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
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTapDown: (_) => setPressed(true),
    onTapUp: (_) => setPressed(false),
    onTapCancel: () => setPressed(false),
    onTap: widget.onTap,
    child: CardFrame(
      height: widget.cardHeight,
      width: widget.cardWidth,
      child: AnimatedContainer(
        duration: SolitaireDurations.animationLong,
        curve: Curves.easeIn,
        transform: Matrix4.translationValues(0, isPressed && widget.hasCards ? -4 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SolitaireConstants.borderRadius),
          boxShadow: isPressed && widget.hasCards
              ? const [
                  SolitaireBoxShadows.lift,
                ]
              : const [],
        ),
        child: widget.hasCards
            ? CardBack(
                height: widget.cardHeight,
                width: widget.cardWidth,
              )
            : CardEmpty(
                height: widget.cardHeight,
                width: widget.cardWidth,
                icon: PhosphorIcons.handTap(
                  PhosphorIconsStyle.thin,
                ),
              ),
      ),
    ),
  );
}
