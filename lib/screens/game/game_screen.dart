import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart' as pc;

import '../../util/dependencies.dart';
import 'game_controller.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    required super.key,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController controller;

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
      backgroundColor: const Color(0xFF0A6E3A),
      appBar: AppBar(
        title: const Text('Good Old Solitaire'),
        backgroundColor: const Color(0xFF0B5F33),
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
          final padding = 12.0;
          final isLandscape = constraints.maxWidth > constraints.maxHeight;
          final availableWidth = constraints.maxWidth - padding * 2;
          final cardWidth = (availableWidth - 6 * 8) / 7;
          final clampedCardWidth = cardWidth.clamp(48.0, 92.0);
          final cardHeight = clampedCardWidth * 1.4;
          final availableHeight = constraints.maxHeight - padding * 2;
          final sideCardHeight = ((availableHeight - 3 * 8) / 4).clamp(36.0, cardHeight);
          final sideCardWidth = (sideCardHeight / 1.4).clamp(28.0, clampedCardWidth);

          return Padding(
            padding: EdgeInsets.all(padding),
            child: isLandscape
                ? Row(
                    children: [
                      _buildFoundationColumn(
                        sideCardWidth,
                        sideCardHeight,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTableauRow(
                          clampedCardWidth,
                          cardHeight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildStockWasteColumn(
                        sideCardWidth,
                        sideCardHeight,
                      ),
                    ],
                  )
                : Column(
                    children: [
                      _buildTopRow(clampedCardWidth, cardHeight),
                      const SizedBox(height: 12),
                      Expanded(
                        child: _buildTableauRow(
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

  Widget _buildTopRow(double cardWidth, double cardHeight) {
    return Row(
      children: [
        _buildStockWasteRow(cardWidth, cardHeight),
        const Spacer(),
        _buildFoundationRow(cardWidth, cardHeight),
      ],
    );
  }

  Widget _buildStockWasteRow(
    double cardWidth,
    double cardHeight, {
    bool isLandscape = false,
  }) {
    final stock = _buildStockPile(cardWidth, cardHeight);
    final waste = _buildWastePile(cardWidth, cardHeight);
    return Row(
      children: [
        if (isLandscape) waste else stock,
        const SizedBox(width: 8),
        if (isLandscape) stock else waste,
      ],
    );
  }

  Widget _buildFoundationRow(double cardWidth, double cardHeight) {
    return Row(
      children: List.generate(
        controller.foundations.length,
        (index) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: _buildFoundationPile(index, cardWidth, cardHeight),
        ),
      ),
    );
  }

  Widget _buildFoundationColumn(double cardWidth, double cardHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(
        controller.foundations.length,
        (index) => Padding(
          padding: EdgeInsets.only(top: index == 0 ? 0 : 8),
          child: _buildFoundationPile(index, cardWidth, cardHeight),
        ),
      ),
    );
  }

  Widget _buildStockWasteColumn(double cardWidth, double cardHeight) {
    final stock = _buildStockPile(cardWidth, cardHeight);
    final waste = _buildWastePile(cardWidth, cardHeight);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        waste,
        const SizedBox(height: 8),
        stock,
      ],
    );
  }

  Widget _buildStockPile(double cardWidth, double cardHeight) {
    final hasCards = controller.stock.isNotEmpty;
    return GestureDetector(
      onTap: controller.drawFromStock,
      child: _pileFrame(
        cardWidth,
        cardHeight,
        heightMultiplier: 1,
        child: hasCards ? _buildCardBack(cardWidth, cardHeight) : _emptySlot(cardWidth, cardHeight, label: 'Stock'),
      ),
    );
  }

  Widget _buildWastePile(double cardWidth, double cardHeight) {
    final hasCards = controller.waste.isNotEmpty;
    final isSelected = controller.selected?.source == PileType.waste;
    final dragPayload = const DragPayload(source: PileType.waste, pileIndex: 0);
    return GestureDetector(
      onTap: controller.selectWasteTop,
      child: _pileFrame(
        cardWidth,
        cardHeight,
        heightMultiplier: 1,
        child: hasCards
            ? Draggable<DragPayload>(
                data: dragPayload,
                feedback: _dragFeedback(
                  controller.waste.last,
                  cardWidth,
                  cardHeight,
                ),
                childWhenDragging: Opacity(
                  opacity: 0.35,
                  child: _buildCard(
                    controller.waste.last,
                    cardWidth,
                    cardHeight,
                    isSelected: isSelected,
                  ),
                ),
                child: _buildCard(
                  controller.waste.last,
                  cardWidth,
                  cardHeight,
                  isSelected: isSelected,
                ),
              )
            : _emptySlot(cardWidth, cardHeight, label: 'Waste'),
      ),
    );
  }

  Widget _buildFoundationPile(int index, double cardWidth, double cardHeight) {
    final pile = controller.foundations[index];
    final hasCards = pile.isNotEmpty;
    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnFoundation(details.data, index),
      onAcceptWithDetails: (details) => controller.moveDragToFoundation(details.data, index),
      builder: (context, _, __) {
        return GestureDetector(
          onTap: () => controller.tryMoveSelectedToFoundation(index),
          child: _pileFrame(
            cardWidth,
            cardHeight,
            heightMultiplier: 1,
            child: hasCards
                ? Draggable<DragPayload>(
                    data: DragPayload(source: PileType.foundation, pileIndex: index),
                    feedback: _dragFeedback(pile.last, cardWidth, cardHeight),
                    childWhenDragging: Opacity(
                      opacity: 0.35,
                      child: _buildCard(pile.last, cardWidth, cardHeight),
                    ),
                    child: _buildCard(pile.last, cardWidth, cardHeight),
                  )
                : _emptySlot(cardWidth, cardHeight, label: 'A'),
          ),
        );
      },
    );
  }

  Widget _buildTableauRow(double cardWidth, double cardHeight) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(controller.tableau.length, (index) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _buildTableauColumn(index, cardWidth, cardHeight),
          ),
        );
      }),
    );
  }

  Widget _buildTableauColumn(int column, double cardWidth, double cardHeight) {
    final pile = controller.tableau[column];
    final isSelected = controller.selected?.source == PileType.tableau && controller.selected?.pileIndex == column;

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) => controller.canDropOnTableau(details.data, column),
      onAcceptWithDetails: (details) => controller.moveDragToTableau(details.data, column),
      builder: (context, _, __) {
        return GestureDetector(
          onTap: () {
            if (controller.selected != null && !(controller.selected!.source == PileType.tableau && controller.selected!.pileIndex == column)) {
              controller.tryMoveSelectedToTableau(column);
              return;
            }
            if (pile.isEmpty) {
              controller.tryMoveSelectedToTableau(column);
              return;
            }
            final top = pile.last;
            if (!top.faceUp) {
              controller.flipTableauTop(column);
              return;
            }
            controller.selectTableauTop(column);
          },
          child: _pileFrame(
            cardWidth,
            cardHeight,
            heightMultiplier: 5.2,
            child: Stack(
              children: [
                if (pile.isEmpty) _emptySlot(cardWidth, cardHeight, label: 'K'),
                for (var i = 0; i < pile.length; i += 1)
                  Positioned(
                    top: i * 22.0,
                    child: _buildTableauCard(
                      pile[i],
                      column,
                      i,
                      pile.sublist(i),
                      cardWidth,
                      cardHeight,
                      isSelected: isSelected && i == pile.length - 1,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pileFrame(
    double width,
    double height, {
    double heightMultiplier = 1,
    required Widget child,
  }) {
    return SizedBox(
      width: width,
      height: height * heightMultiplier,
      child: Align(
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }

  Widget _emptySlot(double width, double height, {String? label}) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white30, width: 1.2),
        color: Colors.white.withOpacity(0.08),
      ),
      child: label == null
          ? null
          : Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildCardBack(double width, double height) {
    final backCard = pc.PlayingCard(pc.Suit.spades, pc.CardValue.ace);
    return SizedBox(
      width: width,
      height: height,
      child: pc.PlayingCardView(
        card: backCard,
        showBack: true,
        elevation: 2,
      ),
    );
  }

  Widget _buildCard(
    CardModel card,
    double width,
    double height, {
    bool isSelected = false,
  }) {
    final playingCard = _toPlayingCard(card);
    final cardView = SizedBox(
      width: width,
      height: height,
      child: pc.PlayingCardView(
        card: playingCard,
        showBack: !card.faceUp,
        elevation: 2,
      ),
    );

    if (!isSelected) {
      return cardView;
    }

    return Stack(
      children: [
        cardView,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  pc.PlayingCard _toPlayingCard(CardModel card) {
    return pc.PlayingCard(_toPlayingSuit(card.suit), _toPlayingValue(card.rank));
  }

  pc.Suit _toPlayingSuit(Suit suit) {
    switch (suit) {
      case Suit.clubs:
        return pc.Suit.clubs;
      case Suit.diamonds:
        return pc.Suit.diamonds;
      case Suit.hearts:
        return pc.Suit.hearts;
      case Suit.spades:
        return pc.Suit.spades;
    }
  }

  pc.CardValue _toPlayingValue(int rank) {
    switch (rank) {
      case 1:
        return pc.CardValue.ace;
      case 2:
        return pc.CardValue.two;
      case 3:
        return pc.CardValue.three;
      case 4:
        return pc.CardValue.four;
      case 5:
        return pc.CardValue.five;
      case 6:
        return pc.CardValue.six;
      case 7:
        return pc.CardValue.seven;
      case 8:
        return pc.CardValue.eight;
      case 9:
        return pc.CardValue.nine;
      case 10:
        return pc.CardValue.ten;
      case 11:
        return pc.CardValue.jack;
      case 12:
        return pc.CardValue.queen;
      case 13:
        return pc.CardValue.king;
    }
    return pc.CardValue.ace;
  }

  Widget _buildTableauCard(
    CardModel card,
    int column,
    int cardIndex,
    List<CardModel> stack,
    double width,
    double height, {
    bool isSelected = false,
  }) {
    final body = _buildCard(
      card,
      width,
      height,
      isSelected: isSelected,
    );

    if (!card.faceUp) {
      return body;
    }

    final payload = DragPayload(
      source: PileType.tableau,
      pileIndex: column,
      cardIndex: cardIndex,
    );
    return Draggable<DragPayload>(
      data: payload,
      feedback: _dragStackFeedback(stack, width, height),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: body,
      ),
      child: body,
    );
  }

  Widget _dragFeedback(CardModel card, double width, double height) {
    return Material(
      color: Colors.transparent,
      child: Opacity(
        opacity: 0.9,
        child: _buildCard(card, width, height),
      ),
    );
  }

  Widget _dragStackFeedback(List<CardModel> cards, double width, double height) {
    if (cards.isEmpty) {
      return const SizedBox.shrink();
    }
    final stackHeight = height + (cards.length - 1) * 18.0;
    return Material(
      color: Colors.transparent,
      child: SizedBox(
        width: width,
        height: stackHeight,
        child: Stack(
          children: [
            for (var i = 0; i < cards.length; i += 1)
              Positioned(
                top: i * 18.0,
                child: _buildCard(cards[i], width, height),
              ),
          ],
        ),
      ),
    );
  }
}
