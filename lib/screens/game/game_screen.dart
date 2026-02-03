import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../constants/durations.dart';
import '../../constants/enums.dart';
import '../../models/selected_card.dart';
import '../../models/solitaire_card.dart';
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
    int column,
  ) async {
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
    double? cardHeight;
    double? cardWidth;

    if (selected.source == PileType.drawingOpenedCards) {
      fromRect = controller.rectFromKey(drawingOpenedKey);
      cardHeight = fromRect?.height;
      cardWidth = fromRect?.width;
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

      final sourceRect = controller.rectFromKey(
        controller.mainColumnKeys[selected.pileIndex],
      );

      if (sourceRect != null) {
        cardWidth = sourceRect.width;
        final computedHeight = sourceRect.height - (maxMainStackCards - 1) * mainStackOffset;
        cardHeight = computedHeight > 0 ? computedHeight : sourceRect.width * cardAspectRatio;
      }
    } else {
      return;
    }

    final toRect = controller.mainCardRect(
      column,
      state.mainCards[column].length,
    );

    if (fromRect == null || toRect == null || cardHeight == null || cardWidth == null) {
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
    int index,
  ) async {
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
    double? cardHeight;
    double? cardWidth;

    if (selected.source == PileType.drawingOpenedCards) {
      fromRect = controller.rectFromKey(drawingOpenedKey);
      cardHeight = fromRect?.height;
      cardWidth = fromRect?.width;
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

      final sourceRect = controller.rectFromKey(
        controller.mainColumnKeys[selected.pileIndex],
      );

      if (sourceRect != null) {
        cardWidth = sourceRect.width;

        final computedHeight = sourceRect.height - (maxMainStackCards - 1) * mainStackOffset;

        cardHeight = computedHeight > 0 ? computedHeight : sourceRect.width * cardAspectRatio;
      }
    } else {
      return;
    }

    final toRect = controller.rectFromKey(
      controller.finishedPileKeys[index],
    );

    if (fromRect == null || cardHeight == null || cardWidth == null) {
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

              final hiddenTopCardColumn = tapMoveSource?.source == PileType.mainCards ? tapMoveSource!.pileIndex : null;
              final hideOpenedTopCard = tapMoveSource?.source == PileType.drawingOpenedCards;

              Widget buildCardSlot(
                Widget Function(double cardWidth, double cardHeight) childBuilder,
              ) => LayoutBuilder(
                builder: (context, slotConstraints) {
                  final cardWidth = slotConstraints.maxWidth;
                  final cardHeight = cardWidth * cardAspectRatio;

                  return childBuilder(
                    cardWidth,
                    cardHeight,
                  );
                },
              );

              return IgnorePointer(
                ignoring: isAnimatingMove,
                child: isLandscape
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(
                            child: SizedBox.shrink(),
                          ),
                          const SizedBox(width: padding),
                          Expanded(
                            flex: 7,
                            child: Column(
                              children: [
                                Expanded(
                                  child: MainCardsRow(
                                    columnKeys: controller.mainColumnKeys,
                                    isAnimatingMove: isAnimatingMove,
                                    hiddenTopCardColumn: hiddenTopCardColumn,
                                    onTapMoveSelected: animateSelectedToMain,
                                  ),
                                ),
                                const SizedBox(height: padding),
                                FinishedCardsRow(
                                  pileKeys: controller.finishedPileKeys,
                                  isAnimatingMove: isAnimatingMove,
                                  onTapMoveSelected: animateSelectedToFinished,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: padding),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: padding / 2),
                              child: DrawingCardsColumn(
                                drawingOpenedKey: drawingOpenedKey,
                                hideOpenedTopCard: hideOpenedTopCard,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...List.generate(
                                controller.finishedPileKeys.length,
                                (index) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: padding / 2),
                                    child: buildCardSlot(
                                      (cardWidth, cardHeight) => FinishedCards(
                                        index: index,
                                        cardHeight: cardHeight,
                                        cardWidth: cardWidth,
                                        pileKey: controller.finishedPileKeys[index],
                                        isAnimatingMove: isAnimatingMove,
                                        onTapMoveSelected: animateSelectedToFinished,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: padding / 2),
                                  child: buildCardSlot(
                                    (cardWidth, cardHeight) => SizedBox(
                                      width: cardWidth,
                                      height: cardHeight,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: padding / 2),
                                  child: buildCardSlot(
                                    (cardWidth, cardHeight) => DrawingOpenedCards(
                                      cardHeight: cardHeight,
                                      cardWidth: cardWidth,
                                      pileKey: drawingOpenedKey,
                                      hideTopCard: hideOpenedTopCard,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: padding / 2),
                                  child: buildCardSlot(
                                    (cardWidth, cardHeight) => DrawingUnopenedCards(
                                      cardHeight: cardHeight,
                                      cardWidth: cardWidth,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: padding),
                          Expanded(
                            child: MainCardsRow(
                              columnKeys: controller.mainColumnKeys,
                              isAnimatingMove: isAnimatingMove,
                              hiddenTopCardColumn: hiddenTopCardColumn,
                              onTapMoveSelected: animateSelectedToMain,
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
