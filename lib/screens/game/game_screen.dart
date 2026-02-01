import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../constants/enums.dart';
import '../../models/selected_card.dart';
import '../../models/solitaire_card.dart';
import '../../util/card_size.dart';
import '../../util/dependencies.dart';
import '../../util/main_stack_layout.dart';
import 'game_controller.dart';
import 'widgets/card/card_widget.dart';
import 'widgets/cards/drawing_opened_cards.dart';
import 'widgets/cards/drawing_unopened_cards.dart';
import 'widgets/cards/finished_cards.dart';
import 'widgets/layout/drawing_cards/drawing_cards_column.dart';
import 'widgets/layout/finished_cards/finished_cards_column.dart';
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

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final GlobalKey drawingOpenedKey = GlobalKey();

  bool isAnimatingMove = false;
  SelectedCard? tapMoveSource;

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

  Future<void> animateCardMove({
    required Rect from,
    required Rect to,
    required SolitaireCard card,
    required double cardHeight,
    required double cardWidth,
  }) async {
    final overlay = Overlay.of(context);

    final controller = AnimationController(
      vsync: this,
      duration: SolitaireDurations.animation,
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    final entry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final offset = Offset.lerp(
            from.topLeft,
            to.topLeft,
            animation.value,
          )!;

          return Positioned(
            left: offset.dx,
            top: offset.dy,
            child: child!,
          );
        },
        child: IgnorePointer(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight,
            child: CardWidget(
              card: card,
              height: cardHeight,
              width: cardWidth,
              isSelected: false,
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    await controller.forward();
    entry.remove();

    controller.dispose();
  }

  Future<void> animateStackMove({
    required Rect from,
    required Rect to,
    required List<SolitaireCard> cards,
    required double cardHeight,
    required double cardWidth,
  }) async {
    if (cards.isEmpty) {
      return;
    }

    if (cards.length == 1) {
      await animateCardMove(
        from: from,
        to: to,
        card: cards.single,
        cardHeight: cardHeight,
        cardWidth: cardWidth,
      );
      return;
    }

    final overlay = Overlay.of(context);

    final controller = AnimationController(
      vsync: this,
      duration: SolitaireDurations.animation,
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    final entry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final offset = Offset.lerp(
            from.topLeft,
            to.topLeft,
            animation.value,
          )!;

          return Positioned(
            left: offset.dx,
            top: offset.dy,
            child: child!,
          );
        },
        child: IgnorePointer(
          child: SizedBox(
            width: cardWidth,
            height: cardHeight + mainStackTotalOffset(cards),
            child: Stack(
              children: [
                for (var i = 0; i < cards.length; i += 1)
                  Positioned(
                    top: mainStackTopOffset(cards, i),
                    child: CardWidget(
                      card: cards[i],
                      height: cardHeight,
                      width: cardWidth,
                      isSelected: false,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    await controller.forward();
    entry.remove();

    controller.dispose();
  }

  Future<void> animateSelectedToMain(
    int column, {
    required double cardHeight,
    required double cardWidth,
  }) async {
    if (isAnimatingMove) {
      return;
    }

    final controller = getIt.get<GameController>();
    final state = controller.value;
    final selected = state.selectedCard;

    if (selected == null) {
      return;
    }

    if (selected.source == PileType.mainCards && selected.pileIndex == column) {
      return;
    }

    final stack = controller.selectedStackFrom(
      selected,
      drawingOpenedCards: state.drawingOpenedCards,
      mainCards: state.mainCards,
    );

    if (stack.isEmpty) {
      return;
    }

    if (!controller.canMoveToMain(stack.first, state.mainCards[column])) {
      return;
    }

    Rect? fromRect;
    if (selected.source == PileType.drawingOpenedCards) {
      fromRect = controller.rectFromKey(drawingOpenedKey);
    } else if (selected.source == PileType.mainCards) {
      final sourcePile = state.mainCards[selected.pileIndex];

      if (sourcePile.isEmpty) {
        return;
      }

      final startIndex = sourcePile.length - stack.length;

      if (startIndex < 0 || startIndex >= sourcePile.length) {
        return;
      }

      fromRect = controller.mainCardRect(
        selected.pileIndex,
        startIndex,
      );
    } else {
      return;
    }

    final toRect = controller.mainCardRect(
      column,
      state.mainCards[column].length,
    );

    if (fromRect == null || toRect == null) {
      controller.tryMoveSelectedToMain(column);
      return;
    }

    setState(() {
      isAnimatingMove = true;
      tapMoveSource = selected;
    });

    await animateStackMove(
      from: fromRect,
      to: toRect,
      cards: stack,
      cardHeight: cardHeight,
      cardWidth: cardWidth,
    );

    if (!mounted) {
      return;
    }

    controller.tryMoveSelectedToMain(column);

    setState(() {
      isAnimatingMove = false;
      tapMoveSource = null;
    });
  }

  Future<void> animateSelectedToFinished(
    int index, {
    required double cardHeight,
    required double cardWidth,
  }) async {
    if (isAnimatingMove) {
      return;
    }

    final controller = getIt.get<GameController>();
    final state = controller.value;
    final selected = state.selectedCard;

    if (selected == null) {
      return;
    }

    final card = controller.selectedCardFrom(
      selected,
      drawingOpenedCards: state.drawingOpenedCards,
      mainCards: state.mainCards,
    );

    if (card == null) {
      return;
    }

    if (!controller.canMoveToFinished(card, state.finishedCards[index])) {
      return;
    }

    Rect? fromRect;
    if (selected.source == PileType.drawingOpenedCards) {
      fromRect = controller.rectFromKey(drawingOpenedKey);
    } else if (selected.source == PileType.mainCards) {
      final sourcePile = state.mainCards[selected.pileIndex];

      if (sourcePile.isEmpty) {
        return;
      }

      if (selected.cardIndex < 0 || selected.cardIndex >= sourcePile.length) {
        return;
      }

      if (selected.cardIndex != sourcePile.length - 1) {
        return;
      }

      fromRect = controller.mainCardRect(
        selected.pileIndex,
        selected.cardIndex,
      );
    } else {
      return;
    }

    final toRect = controller.rectFromKey(
      controller.finishedPileKeys[index],
    );

    if (fromRect == null) {
      controller.tryMoveSelectedToFinished(index);
      return;
    }

    setState(() {
      isAnimatingMove = true;
      tapMoveSource = selected;
    });

    if (toRect != null) {
      await animateCardMove(
        from: fromRect,
        to: toRect,
        card: card,
        cardHeight: cardHeight,
        cardWidth: cardWidth,
      );
    }

    if (!mounted) {
      return;
    }

    controller.tryMoveSelectedToFinished(index);

    setState(() {
      isAnimatingMove = false;
      tapMoveSource = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>();

    return Scaffold(
      backgroundColor: Colors.green,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isLandscape = constraints.maxWidth > constraints.maxHeight;

              final availableHeight = constraints.maxHeight - padding * 2;
              final availableWidth = constraints.maxWidth - padding * 2;

              const cardAspectRatio = 1.4;

              final cardWidth = getCardWidth(
                isLandscape: isLandscape,
                availableHeight: availableHeight,
                availableWidth: availableWidth,
                padding: padding,
                cardAspectRatio: cardAspectRatio,
              );

              final cardHeight = cardWidth * cardAspectRatio;

              final hiddenTopCardColumn = tapMoveSource?.source == PileType.mainCards ? tapMoveSource!.pileIndex : null;
              final hideOpenedTopCard = tapMoveSource?.source == PileType.drawingOpenedCards;

              return IgnorePointer(
                ignoring: isAnimatingMove,
                child: isLandscape
                    ? Row(
                        children: [
                          ///
                          /// LEFT COLUMN
                          ///
                          FinishedCardsColumn(
                            cardHeight: cardHeight,
                            cardWidth: cardWidth,
                            pileKeys: controller.finishedPileKeys,
                            isAnimatingMove: isAnimatingMove,
                            onTapMoveSelected: (index) => animateSelectedToFinished(
                              index,
                              cardHeight: cardHeight,
                              cardWidth: cardWidth,
                            ),
                          ),

                          const SizedBox(width: padding),

                          ///
                          /// MIDDLE COLUMN
                          ///
                          Expanded(
                            child: MainCardsRow(
                              cardHeight: cardHeight,
                              cardWidth: cardWidth,
                              columnKeys: controller.mainColumnKeys,
                              isAnimatingMove: isAnimatingMove,
                              hiddenTopCardColumn: hiddenTopCardColumn,
                              onTapMoveSelected: (column) => animateSelectedToMain(
                                column,
                                cardHeight: cardHeight,
                                cardWidth: cardWidth,
                              ),
                            ),
                          ),

                          const SizedBox(width: padding),

                          ///
                          /// RIGHT COLUMN
                          ///
                          DrawingCardsColumn(
                            cardHeight: cardHeight,
                            cardWidth: cardWidth,
                            drawingOpenedKey: drawingOpenedKey,
                            hideOpenedTopCard: hideOpenedTopCard,
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          ///
                          /// TOP ROW
                          ///
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ///
                              /// DRAWING CARDS
                              ///
                              DrawingUnopenedCards(
                                cardHeight: cardHeight,
                                cardWidth: cardWidth,
                              ),
                              DrawingOpenedCards(
                                cardHeight: cardHeight,
                                cardWidth: cardWidth,
                                pileKey: drawingOpenedKey,
                                hideTopCard: hideOpenedTopCard,
                              ),

                              ///
                              /// EMPTY SPACE
                              ///
                              SizedBox(width: cardWidth),

                              ///
                              /// FINISHED CARDS
                              ///
                              ...List.generate(
                                controller.finishedPileKeys.length,
                                (index) => FinishedCards(
                                  index: index,
                                  cardHeight: cardHeight,
                                  cardWidth: cardWidth,
                                  pileKey: controller.finishedPileKeys[index],
                                  isAnimatingMove: isAnimatingMove,
                                  onTapMoveSelected: (index) => animateSelectedToFinished(
                                    index,
                                    cardHeight: cardHeight,
                                    cardWidth: cardWidth,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: padding),

                          ///
                          /// BOTTOM ROW
                          ///
                          Expanded(
                            child: MainCardsRow(
                              cardHeight: cardHeight,
                              cardWidth: cardWidth,
                              columnKeys: controller.mainColumnKeys,
                              isAnimatingMove: isAnimatingMove,
                              hiddenTopCardColumn: hiddenTopCardColumn,
                              onTapMoveSelected: (column) => animateSelectedToMain(
                                column,
                                cardHeight: cardHeight,
                                cardWidth: cardWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
              );
            },
          ),
        ),
      ),
    );
  }
}
