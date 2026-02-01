import 'package:flutter/cupertino.dart';

import '../../../../../constants/constants.dart';
import '../../../../../util/dependencies.dart';
import '../../../game_controller.dart';
import '../../cards/finished_cards.dart';

class FinishedCardsRow extends StatelessWidget {
  final double cardHeight;
  final double cardWidth;

  const FinishedCardsRow({
    required this.cardHeight,
    required this.cardWidth,
  });

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();

    return Row(
      children: List.generate(
        controller.finishedCards.length,
        (index) => Padding(
          padding: const EdgeInsets.only(left: padding),
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
