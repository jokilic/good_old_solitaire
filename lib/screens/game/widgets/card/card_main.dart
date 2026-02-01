import 'package:flutter/cupertino.dart';

import '../../../../constants/enums.dart';
import '../../../../models/drag_payload.dart';
import '../../../../models/solitaire_card.dart';
import '../stack_drag_feedback.dart';
import 'card_widget.dart';

class CardMain extends StatelessWidget {
  final SolitaireCard card;
  final int column;
  final int cardIndex;
  final List<SolitaireCard> stack;
  final double height;
  final double width;
  final bool isSelected;

  const CardMain({
    required this.card,
    required this.column,
    required this.cardIndex,
    required this.stack,
    required this.height,
    required this.width,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final body = CardWidget(
      card: card,
      height: height,
      width: width,
      isSelected: isSelected,
    );

    if (!card.faceUp) {
      return body;
    }

    final payload = DragPayload(
      source: PileType.mainCards,
      pileIndex: column,
      cardIndex: cardIndex,
    );

    return Draggable<DragPayload>(
      data: payload,
      feedback: StackDragFeedback(
        cards: stack,
        height: height,
        width: width,
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: body,
      ),
      child: body,
    );
  }
}
