import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';
import '../../../../models/solitaire_card.dart';
import 'card_back.dart';
import 'card_front.dart';

class CardWidget extends StatelessWidget {
  final SolitaireCard card;
  final double height;
  final double width;
  final bool isSelected;

  const CardWidget({
    required this.card,
    required this.height,
    required this.width,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
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

    if (!isSelected) {
      return cardView;
    }

    return Stack(
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
  }
}
