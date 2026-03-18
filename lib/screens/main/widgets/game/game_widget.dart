import 'dart:async';

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/durations.dart';
import '../../../../constants/enums.dart';
import '../../../../models/game_history_snapshot.dart';
import '../../../../models/selected_card.dart';
import '../../../../models/settings/draw_cards_position.dart';
import '../../../../models/solitaire_card.dart';
import '../../../../services/hive_service.dart';
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

class GameWidget extends WatchingStatefulWidget {
  final String instanceId;

  const GameWidget({
    required this.instanceId,
    required super.key,
  });

  @override
  State<GameWidget> createState() => GameWidgetState();
}

class GameWidgetState extends State<GameWidget> with TickerProviderStateMixin {
  final GlobalKey drawingUnopenedKey = GlobalKey();
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

  void restartInitialDealAnimation() {
    initialDealTimer?.cancel();

    setState(() {
      isInitialDealAnimating = true;
      initialDealAnimationVersion += 1;
      isAnimatingMove = false;
      tapMoveSource = null;
    });

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

  Future<void> undoLastMoveWithAnimation() async {
    if (isAnimatingMove || isInitialDealAnimating) {
      return;
    }

    final controller = getIt.get<GameController>(
      instanceName: widget.instanceId,
    );
    final snapshot = controller.lastMoveSnapshot;

    if (snapshot == null) {
      return;
    }

    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;
    final animationPlan = buildUndoAnimationPlan(
      snapshot: snapshot,
      controller: controller,
      isWideUi: isWideUi,
    );

    if (animationPlan != null && mounted) {
      setState(() {
        isAnimatingMove = true;
      });
    }

    controller.undoLastMove(
      animatedTarget: animationPlan?.target,
      animatedPileIndex: animationPlan?.pileIndex,
      animatedCardKeys: animationPlan?.cardKeys,
      animatedFromOffset: animationPlan?.fromOffset,
    );

    if (animationPlan == null) {
      return;
    }

    await Future<void>.delayed(
      SolitaireDurations.animation,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      isAnimatingMove = false;
    });
  }

  ({
    PileType target,
    int? pileIndex,
    List<String> cardKeys,
    Offset fromOffset,
  })?
  buildUndoAnimationPlan({
    required GameHistorySnapshot snapshot,
    required GameController controller,
    required bool isWideUi,
  }) {
    final undoTarget = snapshot.undoTarget;

    if (undoTarget == null || snapshot.undoCardKeys.isEmpty) {
      return null;
    }

    if (undoTarget == PileType.drawingUnopenedCards) {
      return null;
    }

    final currentLocations = buildCardLocationMap(
      drawingUnopenedCards: controller.value.drawingUnopenedCards,
      drawingOpenedCards: controller.value.drawingOpenedCards,
      mainCards: controller.value.mainCards,
      finishedCards: controller.value.finishedCards,
    );
    final sourceLocation = currentLocations[snapshot.undoCardKeys.first];

    if (sourceLocation == null) {
      return null;
    }

    final fromRect = rectForCardLocation(
      controller: controller,
      isWideUi: isWideUi,
      location: sourceLocation,
    );

    if (fromRect == null) {
      return null;
    }

    return (
      target: undoTarget,
      pileIndex: snapshot.undoTargetPileIndex,
      cardKeys: List<String>.from(snapshot.undoCardKeys),
      fromOffset: fromRect.topLeft,
    );
  }

  Map<String, ({PileType pileType, int pileIndex, int cardIndex})> buildCardLocationMap({
    required List<SolitaireCard> drawingUnopenedCards,
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> mainCards,
    required List<List<SolitaireCard>> finishedCards,
  }) {
    final locations = <String, ({PileType pileType, int pileIndex, int cardIndex})>{};

    for (var i = 0; i < drawingUnopenedCards.length; i += 1) {
      locations[drawingUnopenedCards[i].revealKey] = (
        pileType: PileType.drawingUnopenedCards,
        pileIndex: 0,
        cardIndex: i,
      );
    }

    for (var i = 0; i < drawingOpenedCards.length; i += 1) {
      locations[drawingOpenedCards[i].revealKey] = (
        pileType: PileType.drawingOpenedCards,
        pileIndex: 0,
        cardIndex: i,
      );
    }

    for (var pileIndex = 0; pileIndex < mainCards.length; pileIndex += 1) {
      for (var cardIndex = 0; cardIndex < mainCards[pileIndex].length; cardIndex += 1) {
        locations[mainCards[pileIndex][cardIndex].revealKey] = (
          pileType: PileType.mainCards,
          pileIndex: pileIndex,
          cardIndex: cardIndex,
        );
      }
    }

    for (var pileIndex = 0; pileIndex < finishedCards.length; pileIndex += 1) {
      for (var cardIndex = 0; cardIndex < finishedCards[pileIndex].length; cardIndex += 1) {
        locations[finishedCards[pileIndex][cardIndex].revealKey] = (
          pileType: PileType.finishedCards,
          pileIndex: pileIndex,
          cardIndex: cardIndex,
        );
      }
    }

    return locations;
  }

  Rect? rectForCardLocation({
    required GameController controller,
    required bool isWideUi,
    required ({PileType pileType, int pileIndex, int cardIndex}) location,
  }) {
    switch (location.pileType) {
      case PileType.mainCards:
        return controller.mainCardRect(
          location.pileIndex,
          location.cardIndex,
          isWideUi: isWideUi,
        );
      case PileType.finishedCards:
        return controller.rectFromKey(
          controller.finishedPileKeys[location.pileIndex],
        );
      case PileType.drawingOpenedCards:
        return controller.rectFromKey(drawingOpenedKey);
      case PileType.drawingUnopenedCards:
        return controller.rectFromKey(drawingUnopenedKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>(
      instanceName: widget.instanceId,
    );

    final drawCardsPosition = watchPropertyValue<HiveService, DrawCardsPosition>(
      (x) => x.value.settings?.drawCardPosition ?? DrawCardsPosition.left,
    );

    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Builder(
          builder: (context) {
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

            final showOpenedCardsFirst = drawCardsPosition == DrawCardsPosition.right;

            Widget buildCompactUnopenedCards() => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SolitaireConstants.padding / 2,
                ),
                child: buildCardSlot(
                  (cardWidth, cardHeight) => DrawingUnopenedCards(
                    instanceId: widget.instanceId,
                    pileKey: drawingUnopenedKey,
                    cardHeight: cardHeight,
                    cardWidth: cardWidth,
                  ),
                ),
              ),
            );

            Widget buildCompactOpenedCards() => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SolitaireConstants.padding / 2,
                ),
                child: buildCardSlot(
                  (cardWidth, cardHeight) => DrawingOpenedCards(
                    instanceId: widget.instanceId,
                    cardHeight: cardHeight,
                    cardWidth: cardWidth,
                    pileKey: drawingOpenedKey,
                    hideTopCard: hideOpenedTopCard,
                    revealFromRight: showOpenedCardsFirst,
                  ),
                ),
              ),
            );

            Widget buildCompactFinishedCardsSection() => Row(
              children: [
                ...List.generate(
                  controller.finishedPileKeys.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: SolitaireConstants.padding / 2,
                      ),
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
              ],
            );

            Widget buildCompactSpacerSection() => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: SolitaireConstants.padding / 2,
                ),
                child: buildCardSlot(
                  (cardWidth, cardHeight) => SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                  ),
                ),
              ),
            );

            Widget buildCompactDrawingCardsSection() => Row(
              children: [
                if (showOpenedCardsFirst) buildCompactOpenedCards(),
                if (showOpenedCardsFirst) buildCompactUnopenedCards(),
                if (!showOpenedCardsFirst) buildCompactUnopenedCards(),
                if (!showOpenedCardsFirst) buildCompactOpenedCards(),
              ],
            );

            return IgnorePointer(
              ignoring: isAnimatingMove || isInitialDealAnimating,
              child: isWideUi
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
                                    if (drawCardsPosition == DrawCardsPosition.left)
                                      SizedBox(
                                        width: drawingSectionWidth,
                                        child: DrawingCardsRow(
                                          instanceId: widget.instanceId,
                                          drawingUnopenedKey: drawingUnopenedKey,
                                          drawingOpenedKey: drawingOpenedKey,
                                          hideOpenedTopCard: hideOpenedTopCard,
                                          drawCardsPosition: drawCardsPosition,
                                        ),
                                      ),
                                    if (drawCardsPosition == DrawCardsPosition.right)
                                      SizedBox(
                                        width: finishedSectionWidth,
                                        child: FinishedCardsRow(
                                          instanceId: widget.instanceId,
                                          pileKeys: controller.finishedPileKeys,
                                          isAnimatingMove: isAnimatingMove,
                                          onTapMoveSelected: animateSelectedToFinished,
                                        ),
                                      ),
                                    const SizedBox(
                                      width: SolitaireConstants.padding,
                                    ),
                                    SizedBox(
                                      width: emptySectionWidth,
                                      child: buildCardSlot(
                                        (cardWidth, cardHeight) => SizedBox(
                                          width: cardWidth,
                                          height: cardHeight,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: SolitaireConstants.padding,
                                    ),
                                    if (drawCardsPosition == DrawCardsPosition.left)
                                      SizedBox(
                                        width: finishedSectionWidth,
                                        child: FinishedCardsRow(
                                          instanceId: widget.instanceId,
                                          pileKeys: controller.finishedPileKeys,
                                          isAnimatingMove: isAnimatingMove,
                                          onTapMoveSelected: animateSelectedToFinished,
                                        ),
                                      ),
                                    if (drawCardsPosition == DrawCardsPosition.right)
                                      SizedBox(
                                        width: drawingSectionWidth,
                                        child: DrawingCardsRow(
                                          instanceId: widget.instanceId,
                                          drawingUnopenedKey: drawingUnopenedKey,
                                          drawingOpenedKey: drawingOpenedKey,
                                          hideOpenedTopCard: hideOpenedTopCard,
                                          drawCardsPosition: drawCardsPosition,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: SolitaireConstants.padding,
                        ),
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
                            if (drawCardsPosition == DrawCardsPosition.left) ...[
                              Expanded(
                                flex: 2,
                                child: buildCompactDrawingCardsSection(),
                              ),
                              buildCompactSpacerSection(),
                              Expanded(
                                flex: 4,
                                child: buildCompactFinishedCardsSection(),
                              ),
                            ],
                            if (drawCardsPosition == DrawCardsPosition.right) ...[
                              Expanded(
                                flex: 4,
                                child: buildCompactFinishedCardsSection(),
                              ),
                              buildCompactSpacerSection(),
                              Expanded(
                                flex: 2,
                                child: buildCompactDrawingCardsSection(),
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(
                          height: SolitaireConstants.padding,
                        ),
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
    );
  }
}
