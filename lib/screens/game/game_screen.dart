import 'package:flutter/material.dart';

import 'game_controller.dart';

class GameScreen extends StatefulWidget {
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final GameController controller;

  @override
  void initState() {
    super.initState();
    controller = GameController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
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
              final horizontalPadding = 12.0;
              final availableWidth = constraints.maxWidth - horizontalPadding * 2;
              final cardWidth = (availableWidth - 6 * 8) / 7;
              final clampedCardWidth = cardWidth.clamp(48.0, 92.0);
              final cardHeight = clampedCardWidth * 1.4;

              return Padding(
                padding: EdgeInsets.all(horizontalPadding),
                child: Column(
                  children: [
                    _buildTopRow(clampedCardWidth, cardHeight),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _buildTableauRow(clampedCardWidth, cardHeight),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTopRow(double cardWidth, double cardHeight) {
    return Row(
      children: [
        _buildStockPile(cardWidth, cardHeight),
        const SizedBox(width: 8),
        _buildWastePile(cardWidth, cardHeight),
        const Spacer(),
        Row(
          children: List.generate(
            controller.foundations.length,
            (index) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: _buildFoundationPile(index, cardWidth, cardHeight),
            ),
          ),
        ),
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
        child: hasCards
            ? _buildCardBack(cardWidth, cardHeight)
            : _emptySlot(cardWidth, cardHeight, label: 'Stock'),
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
            ? LongPressDraggable<DragPayload>(
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
      onWillAcceptWithDetails: (details) =>
          controller.canDropOnFoundation(details.data, index),
      onAcceptWithDetails: (details) =>
          controller.moveDragToFoundation(details.data, index),
      builder: (context, _, __) {
        return GestureDetector(
          onTap: () => controller.tryMoveSelectedToFoundation(index),
          child: _pileFrame(
            cardWidth,
            cardHeight,
            heightMultiplier: 1,
            child: hasCards
                ? _buildCard(pile.last, cardWidth, cardHeight)
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
    final isSelected = controller.selected?.source == PileType.tableau &&
        controller.selected?.pileIndex == column;

    return DragTarget<DragPayload>(
      onWillAcceptWithDetails: (details) =>
          controller.canDropOnTableau(details.data, column),
      onAcceptWithDetails: (details) =>
          controller.moveDragToTableau(details.data, column),
      builder: (context, _, __) {
        return GestureDetector(
          onTap: () {
            if (controller.selected != null &&
                !(controller.selected!.source == PileType.tableau &&
                    controller.selected!.pileIndex == column)) {
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
                if (pile.isEmpty)
                  _emptySlot(cardWidth, cardHeight, label: 'K'),
                for (var i = 0; i < pile.length; i += 1)
                  Positioned(
                    top: i * 22.0,
                    child: _buildTableauCard(
                      pile[i],
                      i == pile.length - 1,
                      column,
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white70, width: 1.2),
        color: const Color(0xFF1C3F9A),
        gradient: const LinearGradient(
          colors: [Color(0xFF1C3F9A), Color(0xFF0D2E6D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Icon(Icons.star, color: Colors.white70),
      ),
    );
  }

  Widget _buildCard(
    CardModel card,
    double width,
    double height, {
    bool isSelected = false,
  }) {
    if (!card.faceUp) {
      return _buildCardBack(width, height);
    }

    final isRed = card.isRed;
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
        border: Border.all(
          color: isSelected ? Colors.amber : Colors.black26,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DefaultTextStyle(
        style: TextStyle(
          color: isRed ? Colors.redAccent : Colors.black87,
          fontWeight: FontWeight.w700,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(card.rankLabel),
            Text(card.suitLabel),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(card.rankLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableauCard(
    CardModel card,
    bool isTop,
    int column,
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

    if (!isTop || !card.faceUp) {
      return body;
    }

    final payload = DragPayload(source: PileType.tableau, pileIndex: column);
    return LongPressDraggable<DragPayload>(
      data: payload,
      feedback: _dragFeedback(card, width, height),
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
}
