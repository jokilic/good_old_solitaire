import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../models/solitaire_card.dart';
import 'card/card_widget.dart';

class DragFeedback extends StatelessWidget {
  final SolitaireCard card;
  final double height;
  final double width;

  const DragFeedback({
    required this.card,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: Stack(
      children: [
        CardWidget(
          card: card,
          height: height,
          width: width,
          isSelected: false,
        ),
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
    ),
  );
}
