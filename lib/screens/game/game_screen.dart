import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../util/dependencies.dart';
import 'game_controller.dart';
import 'widgets/layout/drawing_cards/drawing_cards_column.dart';
import 'widgets/layout/drawing_cards/drawing_cards_row.dart';
import 'widgets/layout/finished_cards/finished_cards_column.dart';
import 'widgets/layout/finished_cards/finished_cards_row.dart';
import 'widgets/layout/main_cards/main_cards_row.dart';

class GameScreen extends StatefulWidget {
  final String instanceId;

  const GameScreen({
    required this.instanceId,
    required super.key,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<GameController>(
      GameController.new,
      afterRegister: (controller) => controller.init(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<GameController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();

    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.newGame,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            tooltip: 'New Game',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLandscape = constraints.maxWidth > constraints.maxHeight;

          final availableHeight = constraints.maxHeight - padding * 2;
          final availableWidth = constraints.maxWidth - padding * 2;

          final cardWidth = (availableWidth - 6 * 8) / 7;
          final clampedCardWidth = cardWidth.clamp(48.0, 92.0);

          final cardHeight = clampedCardWidth * 1.4;

          final sideCardHeight = ((availableHeight - 3 * 8) / 4).clamp(36.0, cardHeight);
          final sideCardWidth = (sideCardHeight / 1.4).clamp(28.0, clampedCardWidth);

          return Padding(
            padding: const EdgeInsets.all(padding),
            child: isLandscape
                ? Row(
                    children: [
                      ///
                      /// FINISHED CARDS
                      ///
                      FinishedCardsColumn(
                        cardHeight: sideCardHeight,
                        cardWidth: sideCardWidth,
                      ),
                      const SizedBox(width: padding),

                      ///
                      /// MAIN CARDS
                      ///
                      Expanded(
                        child: MainCardsRow(
                          cardHeight: cardHeight,
                          cardWidth: clampedCardWidth,
                        ),
                      ),
                      const SizedBox(width: padding),

                      ///
                      /// DRAWING CARDS
                      ///
                      DrawingCardsColumn(
                        cardHeight: sideCardHeight,
                        cardWidth: sideCardWidth,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        children: [
                          ///
                          /// DRAWING CARDS
                          ///
                          DrawingCardsRow(
                            cardHeight: cardHeight,
                            cardWidth: cardWidth,
                          ),

                          const Spacer(),

                          ///
                          /// FINISHED CARDS
                          ///
                          FinishedCardsRow(
                            cardHeight: cardHeight,
                            cardWidth: cardWidth,
                          ),
                        ],
                      ),
                      const SizedBox(height: padding),

                      ///
                      /// MAIN CARDS
                      ///
                      Expanded(
                        child: MainCardsRow(
                          cardHeight: cardHeight,
                          cardWidth: clampedCardWidth,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
