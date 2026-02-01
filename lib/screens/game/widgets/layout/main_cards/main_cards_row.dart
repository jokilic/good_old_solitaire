import 'package:flutter/material.dart';

import '../../../../../util/dependencies.dart';
import '../../../game_controller.dart';
import 'main_cards_column.dart';

class MainCardsRow extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;

  const MainCardsRow({
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        controller.mainCards.length,
        (index) => Expanded(
          child: MainCardsColumn(
            column: index,
            cardHeight: cardHeight,
            cardWidth: cardWidth,
          ),
        ),
      ),
    );
  }
}
