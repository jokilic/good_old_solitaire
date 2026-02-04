import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../models/solitaire_card.dart';
import 'card_back.dart';
import 'card_front.dart';

class CardWidget extends StatelessWidget {
  final SolitaireCard card;
  final double height;
  final double width;
  final bool isSelected;
  final bool isLifted;

  const CardWidget({
    required this.card,
    required this.height,
    required this.width,
    required this.isSelected,
    this.isLifted = false,
  });

  @override
  Widget build(BuildContext context) {
    final shouldLift = isLifted || isSelected;

    final cardView = card.faceUp
        ? CardFront(
            card: card,
            height: height,
            width: width,
          )
        : CardBack(
            height: height,
            width: width,
          );

    final selectedCardView = !isSelected
        ? cardView
        : Stack(
            children: [
              cardView,
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: Colors.amber,
                        width: borderWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );

    return AnimatedContainer(
      duration: SolitaireDurations.animationLong,
      curve: Curves.easeIn,
      transform: Matrix4.translationValues(0, shouldLift ? -4 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shouldLift
            ? const [
                BoxShadow(
                  color: Colors.black45,
                  blurRadius: 12,
                  offset: Offset(0, 8),
                ),
              ]
            : const [],
      ),
      child: selectedCardView,
    );
  }
}
