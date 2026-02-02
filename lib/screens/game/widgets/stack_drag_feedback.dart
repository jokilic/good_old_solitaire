import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../models/solitaire_card.dart';
import 'card/card_widget.dart';

class StackDragFeedback extends StatelessWidget {
  final List<SolitaireCard> cards;
  final double height;
  final double width;

  const StackDragFeedback({
    required this.cards,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }

    final stackHeight = height + (cards.length - 1) * 16.0;

    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: width,
        height: stackHeight,
        child: Stack(
          children: [
            for (var i = 0; i < cards.length; i += 1)
              Positioned(
                top: i * 18.0,
                child: Stack(
                  children: [
                    CardWidget(
                      card: cards[i],
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
              ),
          ],
        ),
      ),
    );
  }
}
