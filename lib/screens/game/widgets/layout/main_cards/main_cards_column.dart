import 'package:flutter/material.dart';

import '../../../../../constants/enums.dart';
import '../../../../../models/drag_payload.dart';
import '../../../../../util/dependencies.dart';
import '../../../game_controller.dart';
import '../../card/card_empty.dart';
import '../../card/card_frame.dart';
import '../../card/card_main.dart';

class MainCardsColumn extends StatelessWidget {
  final int column;
  final double cardHeight;
  final double cardWidth;

  const MainCardsColumn({
    required this.column,
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();

    final mainCards = controller.mainCards[column];
    final isSelected = controller.selected?.source == PileType.mainCards && controller.selected?.pileIndex == column;

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnTableau(details.data, column),
      onAcceptWithDetails: (details) => controller.moveDragToTableau(details.data, column),
      builder: (context, _, __) => GestureDetector(
        onTap: () {
          if (controller.selected != null && !(controller.selected!.source == PileType.mainCards && controller.selected!.pileIndex == column)) {
            controller.tryMoveSelectedToTableau(column);
            return;
          }
          if (mainCards.isEmpty) {
            controller.tryMoveSelectedToTableau(column);
            return;
          }
          final top = mainCards.last;
          if (!top.faceUp) {
            controller.flipTableauTop(column);
            return;
          }
          controller.selectTableauTop(column);
        },
        child: CardFrame(
          height: cardHeight,
          width: cardWidth,
          heightMultiplier: 10,
          child: Stack(
            children: [
              if (mainCards.isEmpty)
                CardEmpty(
                  height: cardHeight,
                  width: cardWidth,
                  label: 'K',
                ),
              for (var i = 0; i < mainCards.length; i += 1)
                Positioned(
                  top: i * 20.0,
                  child: CardMain(
                    card: mainCards[i],
                    column: column,
                    cardIndex: i,
                    stack: mainCards.sublist(i),
                    height: cardHeight,
                    width: cardWidth,
                    isSelected: isSelected && i == mainCards.length - 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
