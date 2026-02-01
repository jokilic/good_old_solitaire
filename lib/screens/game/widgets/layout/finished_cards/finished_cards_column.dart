import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import '../../../../../util/dependencies.dart';
import '../../../game_controller.dart';
import '../../cards/finished_cards.dart';

class FinishedCardsColumn extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;

  const FinishedCardsColumn({
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();

    return Column(
      children: List.generate(
        controller.finishedCards.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            top: index == 0 ? 0 : padding,
          ),
          child: FinishedCards(
            index: index,
            cardHeight: cardHeight,
            cardWidth: cardWidth,
          ),
        ),
      ),
    );
  }
}
