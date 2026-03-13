import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../../../constants/colors.dart';
import '../../../../../../constants/constants.dart';
import '../../../../../../constants/durations.dart';
import '../../../../../../constants/enums.dart';
import '../../../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../card/card_back.dart';
import '../card/card_empty.dart';
import '../card/card_frame.dart';

class DrawingUnopenedCards extends WatchingWidget {
  final String instanceId;
  final GlobalKey pileKey;
  final double cardHeight;
  final double cardWidth;

  const DrawingUnopenedCards({
    required this.instanceId,
    required this.pileKey,
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
    final isSelected = watchPropertyValue<GameController, bool>(
      (x) => x.value.selectedCard?.source == PileType.drawingUnopenedCards,
      instanceName: instanceId,
    );

    return PressableUnopenedCard(
      pileKey: pileKey,
      hasCards: hasCards,
      isSelected: isSelected,
      cardHeight: cardHeight,
      cardWidth: cardWidth,
      onTap: controller.drawFromUnopenedSection,
    );
  }
}

class PressableUnopenedCard extends StatefulWidget {
  final GlobalKey pileKey;
  final bool hasCards;
  final bool isSelected;
  final double cardHeight;
  final double cardWidth;
  final VoidCallback onTap;

  const PressableUnopenedCard({
    required this.pileKey,
    required this.hasCards,
    required this.isSelected,
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
      key: widget.pileKey,
      height: widget.cardHeight,
      width: widget.cardWidth,
      child: AnimatedContainer(
        duration: SolitaireDurations.animationLong,
        curve: Curves.easeIn,
        transform: Matrix4.translationValues(
          0,
          (isPressed && widget.hasCards) || widget.isSelected ? -4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SolitaireConstants.borderRadius),
          boxShadow: (isPressed && widget.hasCards) || widget.isSelected
              ? const [
                  SolitaireBoxShadows.lift,
                ]
              : const [],
        ),
        child: Stack(
          children: [
            if (widget.hasCards)
              CardBack(
                height: widget.cardHeight,
                width: widget.cardWidth,
              )
            else
              CardEmpty(
                height: widget.cardHeight,
                width: widget.cardWidth,
                icon: PhosphorIcons.handTap(
                  PhosphorIconsStyle.thin,
                ),
              ),
            if (widget.isSelected)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        SolitaireConstants.borderRadius,
                      ),
                      border: Border.all(
                        color: Colors.amber,
                        width: SolitaireConstants.borderWidth,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}
