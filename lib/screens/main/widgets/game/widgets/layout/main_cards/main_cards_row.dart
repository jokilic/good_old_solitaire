import 'package:flutter/material.dart';

import '../../../../../../../constants/constants.dart';
import '../../../../../../../util/card_size.dart';
import 'main_cards_column.dart';

class MainCardsRow extends StatelessWidget {
  final String instanceId;
  final List<GlobalKey> columnKeys;
  final bool isAnimatingMove;
  final bool isInitialDealAnimating;
  final int initialDealAnimationVersion;
  final int? hiddenTopCardColumn;
  final Future<void> Function(int column) onTapMoveSelected;

  const MainCardsRow({
    required this.instanceId,
    required this.columnKeys,
    required this.isAnimatingMove,
    required this.isInitialDealAnimating,
    required this.initialDealAnimationVersion,
    required this.hiddenTopCardColumn,
    required this.onTapMoveSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        columnKeys.length,
        (index) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: SolitaireConstants.padding / 2),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                final cardHeight = cardWidth * SolitaireConstants.cardAspectRatio;

                return MainCardsColumn(
                  instanceId: instanceId,
                  column: index,
                  cardHeight: cardHeight,
                  cardWidth: cardWidth,
                  isWideUi: isWideUi,
                  stackHeightMultiplier: mainStackHeightMultiplier(
                    cardHeight: cardHeight,
                    cardWidth: cardWidth,
                    isWideUi: isWideUi,
                  ),
                  columnKey: columnKeys[index],
                  hideTopCard: hiddenTopCardColumn == index,
                  isAnimatingMove: isAnimatingMove,
                  isInitialDealAnimating: isInitialDealAnimating,
                  initialDealAnimationVersion: initialDealAnimationVersion,
                  onTapMoveSelected: onTapMoveSelected,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
