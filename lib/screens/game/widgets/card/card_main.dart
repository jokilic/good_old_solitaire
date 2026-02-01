import 'package:flutter/cupertino.dart';

import '../../../../constants/enums.dart';
import '../../../../models/drag_payload.dart';
import '../../../../models/solitaire_card.dart';
import '../../../../util/dependencies.dart';
import '../../game_controller.dart';
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
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();

    final body = CardWidget(
      card: card,
      height: height,
      width: width,
      isSelected: isSelected,
    );

    final tappableBody = onTap == null
        ? body
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: body,
          );

    if (!card.faceUp) {
      return tappableBody;
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
      onDragStarted: () => controller.setDraggingPayload(payload),
      onDragEnd: (_) => controller.setDraggingPayload(null),
      onDraggableCanceled: (_, __) => controller.setDraggingPayload(null),
      onDragCompleted: () => controller.setDraggingPayload(null),
      childWhenDragging: tappableBody,
      child: tappableBody,
    );
  }
}
