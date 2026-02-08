import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../constants/enums.dart';
import '../../../../models/selected_card.dart';
import '../../../../models/solitaire_card.dart';
import '../../../../services/sound_service.dart';
import '../../../../util/dependencies.dart';
import '../../../../util/main_stack_layout.dart';
import 'game_controller.dart';
import 'widgets/card/card_widget.dart';
import 'widgets/cards/drawing_opened_cards.dart';
import 'widgets/cards/drawing_unopened_cards.dart';
import 'widgets/cards/finished_cards.dart';
import 'widgets/layout/drawing_cards/drawing_cards_row.dart';
import 'widgets/layout/finished_cards/finished_cards_row.dart';
import 'widgets/layout/main_cards/main_cards_row.dart';

class GameWidget extends StatefulWidget {
  final String instanceId;

  const GameWidget({
    required this.instanceId,
    required super.key,
  });

  @override
  State<GameWidget> createState() => _GameWidgetState();
}

class _GameWidgetState extends State<GameWidget> with TickerProviderStateMixin {
  final GlobalKey drawingOpenedKey = GlobalKey();

  bool isAnimatingMove = false;
  bool isInitialDealAnimating = true;
  int initialDealAnimationVersion = 0;
  SelectedCard? tapMoveSource;
  Timer? initialDealTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        setState(
          () => initialDealAnimationVersion = 1,
        );

        unawaited(
          getIt.get<SoundService>().playShuffle(),
        );

        initialDealTimer = Timer(
          SolitaireDurations.initialDealTotalDuration,
          () {
            if (!mounted) {
              return;
            }

            setState(
              () => isInitialDealAnimating = false,
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    initialDealTimer?.cancel();
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
          child: Material(
            type: MaterialType.transparency,
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
    required bool isWideUi,
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
          child: Material(
            type: MaterialType.transparency,
            child: SizedBox(
              width: cardWidth,
              height:
                  cardHeight +
                  mainStackTotalOffset(
                    cards,
                    cardWidth: cardWidth,
                    isWideUi: isWideUi,
                  ),
              child: Stack(
                children: [
                  for (var i = 0; i < cards.length; i += 1)
                    Positioned(
                      top: mainStackTopOffset(
                        cards,
                        i,
                        cardWidth: cardWidth,
                        isWideUi: isWideUi,
                      ),
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

    final controller = getIt.get<GameController>(
      instanceName: widget.instanceId,
    );

    final state = controller.value;
    final selected = state.selectedCard;
    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;

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
        isWideUi: isWideUi,
      );

      final sourceRect = controller.rectFromKey(
        controller.mainColumnKeys[selected.pileIndex],
      );

      if (sourceRect != null) {
        cardWidth = sourceRect.width;
        cardHeight = sourceRect.width * SolitaireConstants.cardAspectRatio;
      }
    } else {
      return;
    }

    final toRect = controller.mainCardRect(
      column,
      state.mainCards[column].length,
      isWideUi: isWideUi,
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
      isWideUi: isWideUi,
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

    final controller = getIt.get<GameController>(
      instanceName: widget.instanceId,
    );

    final state = controller.value;
    final selected = state.selectedCard;
    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;

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
        isWideUi: isWideUi,
      );

      final sourceRect = controller.rectFromKey(
        controller.mainColumnKeys[selected.pileIndex],
      );

      if (sourceRect != null) {
        cardWidth = sourceRect.width;
        cardHeight = sourceRect.width * SolitaireConstants.cardAspectRatio;
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
    final controller = getIt.get<GameController>(
      instanceName: widget.instanceId,
    );

    return Padding(
      padding: const EdgeInsets.all(SolitaireConstants.padding),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final useWideLayout = constraints.maxWidth > SolitaireConstants.compactLayoutMaxWidth;

              final hiddenTopCardColumn = tapMoveSource?.source == PileType.mainCards ? tapMoveSource!.pileIndex : null;
              final hideOpenedTopCard = tapMoveSource?.source == PileType.drawingOpenedCards;

              Widget buildCardSlot(
                Widget Function(double cardWidth, double cardHeight) childBuilder,
              ) => LayoutBuilder(
                builder: (context, slotConstraints) {
                  final cardWidth = slotConstraints.maxWidth;
                  final cardHeight = cardWidth * SolitaireConstants.cardAspectRatio;

                  return childBuilder(
                    cardWidth,
                    cardHeight,
                  );
                },
              );

              return IgnorePointer(
                ignoring: isAnimatingMove || isInitialDealAnimating,
                child: useWideLayout
                    ? Column(
                        children: [
                          Builder(
                            builder: (context) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: SolitaireConstants.padding / 2),
                              child: LayoutBuilder(
                                builder: (context, topConstraints) {
                                  final slotWidth = (topConstraints.maxWidth - SolitaireConstants.padding * 6) / 7;
                                  final clampedSlotWidth = slotWidth > 0 ? slotWidth : 0.0;
                                  final drawingSectionWidth = clampedSlotWidth * 2 + SolitaireConstants.padding;
                                  final emptySectionWidth = clampedSlotWidth;
                                  final finishedSectionWidth = clampedSlotWidth * 4 + SolitaireConstants.padding * 3;

                                  return Row(
                                    children: [
                                      SizedBox(
                                        width: drawingSectionWidth,
                                        child: DrawingCardsRow(
                                          instanceId: widget.instanceId,
                                          drawingOpenedKey: drawingOpenedKey,
                                          hideOpenedTopCard: hideOpenedTopCard,
                                        ),
                                      ),
                                      const SizedBox(width: SolitaireConstants.padding),
                                      SizedBox(
                                        width: emptySectionWidth,
                                        child: buildCardSlot(
                                          (cardWidth, cardHeight) => SizedBox(
                                            width: cardWidth,
                                            height: cardHeight,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: SolitaireConstants.padding),
                                      SizedBox(
                                        width: finishedSectionWidth,
                                        child: FinishedCardsRow(
                                          instanceId: widget.instanceId,
                                          pileKeys: controller.finishedPileKeys,
                                          isAnimatingMove: isAnimatingMove,
                                          onTapMoveSelected: animateSelectedToFinished,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: SolitaireConstants.padding),
                          Expanded(
                            child: MainCardsRow(
                              instanceId: widget.instanceId,
                              columnKeys: controller.mainColumnKeys,
                              isAnimatingMove: isAnimatingMove,
                              isInitialDealAnimating: isInitialDealAnimating,
                              initialDealAnimationVersion: initialDealAnimationVersion,
                              hiddenTopCardColumn: hiddenTopCardColumn,
                              onTapMoveSelected: animateSelectedToMain,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          Row(
                            children: [
                              ...List.generate(
                                controller.finishedPileKeys.length,
                                (index) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: SolitaireConstants.padding / 2),
                                    child: buildCardSlot(
                                      (cardWidth, cardHeight) => FinishedCards(
                                        instanceId: widget.instanceId,
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
                                  padding: const EdgeInsets.symmetric(horizontal: SolitaireConstants.padding / 2),
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
                                  padding: const EdgeInsets.symmetric(horizontal: SolitaireConstants.padding / 2),
                                  child: buildCardSlot(
                                    (cardWidth, cardHeight) => DrawingOpenedCards(
                                      instanceId: widget.instanceId,
                                      cardHeight: cardHeight,
                                      cardWidth: cardWidth,
                                      pileKey: drawingOpenedKey,
                                      hideTopCard: hideOpenedTopCard,
                                      revealFromRight: true,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: SolitaireConstants.padding / 2),
                                  child: buildCardSlot(
                                    (cardWidth, cardHeight) => DrawingUnopenedCards(
                                      instanceId: widget.instanceId,
                                      cardHeight: cardHeight,
                                      cardWidth: cardWidth,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: SolitaireConstants.padding),
                          Expanded(
                            child: MainCardsRow(
                              instanceId: widget.instanceId,
                              columnKeys: controller.mainColumnKeys,
                              isAnimatingMove: isAnimatingMove,
                              isInitialDealAnimating: isInitialDealAnimating,
                              initialDealAnimationVersion: initialDealAnimationVersion,
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
