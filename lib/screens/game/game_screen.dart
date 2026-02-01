import 'package:flutter/material.dart';

import '../../constants/constants.dart';
import '../../constants/enums.dart';
import '../../models/solitaire_card.dart';
import '../../util/dependencies.dart';
import 'game_controller.dart';
import 'widgets/card/card_back.dart';
import 'widgets/card/card_widget.dart';
import 'widgets/stack_drag_feedback.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
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
      instanceName: widget.key.toString(),
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<GameController>(
      instanceName: widget.key.toString(),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<GameController>(
      instanceName: widget.key.toString(),
    );

    // final state = watchIt<GameController>(
    //   instanceName: widget.key.toString(),
    // ).value;

    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(
        title: const Text('Good Old Solitaire'),
        backgroundColor: Colors.green,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: controller.newGame,
            icon: const Icon(Icons.refresh),
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
                      buildFinishedCardsColumn(
                        sideCardWidth,
                        sideCardHeight,
                      ),
                      const SizedBox(width: padding),

                      ///
                      /// MAIN CARDS
                      ///
                      Expanded(
                        child: buildMainCardsRow(
                          clampedCardWidth,
                          cardHeight,
                        ),
                      ),
                      const SizedBox(width: padding),

                      ///
                      /// DRAWING CARDS
                      ///
                      buildDrawingCardsColumn(
                        sideCardWidth,
                        sideCardHeight,
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
                          buildDrawingCardsRow(
                            cardWidth,
                            cardHeight,
                          ),

                          const Spacer(),

                          ///
                          /// FINISHED CARDS
                          ///
                          buildFinishedCardsRow(
                            cardWidth,
                            cardHeight,
                          ),
                        ],
                      ),
                      const SizedBox(height: padding),

                      ///
                      /// MAIN CARDS
                      ///
                      Expanded(
                        child: buildMainCardsRow(
                          clampedCardWidth,
                          cardHeight,
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget buildDrawingCardsRow(
    double cardWidth,
    double cardHeight,
  ) => Row(
    children: [
      ///
      /// DRAWING UNOPENED CARDS
      ///
      buildDrawingUnopenedCards(
        cardWidth,
        cardHeight,
      ),
      const SizedBox(width: padding),

      ///
      /// DRAWING OPENED CARDS
      ///
      buildDrawingOpenedCards(
        cardWidth,
        cardHeight,
      ),
    ],
  );

  Widget buildFinishedCardsRow(double cardWidth, double cardHeight) {
    final controller = getIt.get<GameController>(
      instanceName: widget.key.toString(),
    );

    return Row(
      children: List.generate(
        controller.finishedCards.length,
        (index) => Padding(
          padding: const EdgeInsets.only(left: padding),
          child: buildFinishedCards(
            index,
            cardWidth,
            cardHeight,
          ),
        ),
      ),
    );
  }

  Widget buildFinishedCardsColumn(double cardWidth, double cardHeight) {
    final controller = getIt.get<GameController>(
      instanceName: widget.key.toString(),
    );

    return Column(
      children: List.generate(
        controller.finishedCards.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            top: index == 0 ? 0 : padding,
          ),
          child: buildFinishedCards(
            index,
            cardWidth,
            cardHeight,
          ),
        ),
      ),
    );
  }

  Widget buildDrawingCardsColumn(double cardWidth, double cardHeight) => Column(
    children: [
      buildDrawingOpenedCards(
        cardWidth,
        cardHeight,
      ),
      const SizedBox(height: padding),
      buildDrawingUnopenedCards(
        cardWidth,
        cardHeight,
      ),
    ],
  );

  Widget buildDrawingUnopenedCards(double cardWidth, double cardHeight) {
    final controller = getIt.get<GameController>(
      instanceName: widget.key.toString(),
    );

    final hasCards = controller.drawingUnopenedCards.isNotEmpty;

    return GestureDetector(
      onTap: controller.drawFromStock,
      child: cardFrame(
        cardWidth,
        cardHeight,
        child: hasCards
            ? CardBack(
                height: cardHeight,
                width: cardWidth,
              )
            : cardEmptySlot(
                cardWidth,
                cardHeight,
                label: 'Stock',
              ),
      ),
    );
  }

  Widget buildDrawingOpenedCards(double cardWidth, double cardHeight) {
    final controller = getIt.get<GameController>(
      instanceName: widget.key.toString(),
    );

    final hasCards = controller.drawingOpenedCards.isNotEmpty;
    final isSelected = controller.selected?.source == PileType.drawingOpenedCards;

    const dragPayload = DragPayload(
      source: PileType.drawingOpenedCards,
      pileIndex: 0,
    );

    return GestureDetector(
      onTap: controller.selectWasteTop,
      child: cardFrame(
        cardWidth,
        cardHeight,
        child: hasCards
            ? Draggable<DragPayload>(
                data: dragPayload,
                feedback: buildDragFeedback(
                  controller.drawingOpenedCards.last,
                  cardWidth,
                  cardHeight,
                ),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: CardWidget(
                    card: controller.drawingOpenedCards.last,
                    width: cardWidth,
                    height: cardHeight,
                    isSelected: isSelected,
                  ),
                ),
                child: CardWidget(
                  card: controller.drawingOpenedCards.last,
                  width: cardWidth,
                  height: cardHeight,
                  isSelected: isSelected,
                ),
              )
            : cardEmptySlot(
                cardWidth,
                cardHeight,
                label: 'Waste',
              ),
      ),
    );
  }

  Widget buildFinishedCards(int index, double cardWidth, double cardHeight) {
    final controller = getIt.get<GameController>(
      instanceName: widget.key.toString(),
    );

    final finishedCards = controller.finishedCards[index];
    final hasCards = finishedCards.isNotEmpty;

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnFoundation(details.data, index),
      onAcceptWithDetails: (details) => controller.moveDragToFoundation(details.data, index),
      builder: (context, _, __) => GestureDetector(
        onTap: () => controller.tryMoveSelectedToFoundation(index),
        child: cardFrame(
          cardWidth,
          cardHeight,
          child: hasCards
              ? Draggable<DragPayload>(
                  data: DragPayload(
                    source: PileType.finishedCards,
                    pileIndex: index,
                  ),
                  feedback: buildDragFeedback(
                    finishedCards.last,
                    cardWidth,
                    cardHeight,
                  ),
                  childWhenDragging: Opacity(
                    opacity: 0.35,
                    child: CardWidget(
                      card: finishedCards.last,
                      width: cardWidth,
                      height: cardHeight,
                      isSelected: false,
                    ),
                  ),
                  child: CardWidget(
                    card: finishedCards.last,
                    width: cardWidth,
                    height: cardHeight,
                    isSelected: false,
                  ),
                )
              : cardEmptySlot(
                  cardWidth,
                  cardHeight,
                  label: 'A',
                ),
        ),
      ),
    );
  }

  Widget buildMainCardsRow(double cardWidth, double cardHeight) {
    final controller = getIt.get<GameController>(
      instanceName: widget.key.toString(),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        controller.mainCards.length,
        (index) => Expanded(
          child: buildMainCardsColumn(
            index,
            cardWidth,
            cardHeight,
          ),
        ),
      ),
    );
  }

  Widget buildMainCardsColumn(int column, double cardWidth, double cardHeight) {
    final controller = getIt.get<GameController>(
      instanceName: widget.key.toString(),
    );

    final mainCards = controller.mainCards[column];
    final isSelected = controller.selected?.source == PileType.mainCards && controller.selected?.pileIndex == column;

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnTableau(details.data, column),
      onAcceptWithDetails: (details) => controller.moveDragToTableau(details.data, column),
      builder: (context, _, __) => GestureDetector(
        onTap: () {
          if (controller.selected != null && !(controller.selected!.source == PileType.mainCards && controller.selected!.pileIndex == column)) {
            controller.tryMoveSelectedToTableau(column);
            return;
          }
          if (mainCards.isEmpty) {
            controller.tryMoveSelectedToTableau(column);
            return;
          }
          final top = mainCards.last;
          if (!top.faceUp) {
            controller.flipTableauTop(column);
            return;
          }
          controller.selectTableauTop(column);
        },
        child: cardFrame(
          cardWidth,
          cardHeight,
          heightMultiplier: 10,
          child: Stack(
            children: [
              if (mainCards.isEmpty)
                cardEmptySlot(
                  cardWidth,
                  cardHeight,
                  label: 'K',
                ),
              for (var i = 0; i < mainCards.length; i += 1)
                Positioned(
                  top: i * 20.0,
                  child: buildMainCard(
                    mainCards[i],
                    column,
                    i,
                    mainCards.sublist(i),
                    cardWidth,
                    cardHeight,
                    isSelected: isSelected && i == mainCards.length - 1,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cardFrame(
    double width,
    double height, {
    required Widget child,
    double heightMultiplier = 1,
  }) => SizedBox(
    width: width,
    height: height * heightMultiplier,
    child: Align(
      alignment: Alignment.topCenter,
      child: child,
    ),
  );

  Widget cardEmptySlot(
    double width,
    double height, {
    String? label,
  }) => Container(
    height: height,
    width: width,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: Colors.white30,
        width: borderWidth,
      ),
      color: Colors.white10,
    ),
    child: label == null
        ? null
        : Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
  );

  Widget buildMainCard(
    SolitaireCard card,
    int column,
    int cardIndex,
    List<SolitaireCard> stack,
    double width,
    double height, {
    bool isSelected = false,
  }) {
    final body = CardWidget(
      card: card,
      height: height,
      width: width,
      isSelected: isSelected,
    );

    if (!card.faceUp) {
      return body;
    }

    final payload = DragPayload(
      source: PileType.mainCards,
      pileIndex: column,
      cardIndex: cardIndex,
    );

    return Draggable<DragPayload>(
      data: payload,
      feedback: StackDragFeedback(
        cards: stack,
        height: height,
        width: width,
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: body,
      ),
      child: body,
    );
  }

  Widget buildDragFeedback(SolitaireCard card, double width, double height) => Material(
    color: Colors.transparent,
    child: Opacity(
      opacity: 0.9,
      child: CardWidget(
        card: card,
        height: height,
        width: width,
        isSelected: false,
      ),
    ),
  );
}
