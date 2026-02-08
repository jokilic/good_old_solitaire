import 'package:flutter/material.dart';

import '../../../../../models/solitaire_card.dart';
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
    child: CardWidget(
      card: card,
      height: height,
      width: width,
      isSelected: true,
      isLifted: true,
    ),
  );
}
