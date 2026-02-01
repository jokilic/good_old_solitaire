import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../util/dependencies.dart';
import '../../game_controller.dart';
import '../card/card_back.dart';
import '../card/card_empty.dart';
import '../card/card_frame.dart';

class DrawingUnopenedCards extends WatchingWidget {
  final double cardHeight;
  final double cardWidth;

  const DrawingUnopenedCards({
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();
    final state = watchIt<GameController>().value;

    final hasCards = state.drawingUnopenedCards.isNotEmpty;

    return GestureDetector(
      onTap: controller.drawFromUnopenedSection,
      child: CardFrame(
        height: cardHeight,
        width: cardWidth,
        child: hasCards
            ? CardBack(
                height: cardHeight,
                width: cardWidth,
              )
            : CardEmpty(
                height: cardHeight,
                width: cardWidth,
              ),
      ),
    );
  }
}
