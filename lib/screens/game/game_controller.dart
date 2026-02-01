import 'package:flutter/material.dart';

import '../../constants/enums.dart';
import '../../models/drag_payload.dart';
import '../../models/selected_card.dart';
import '../../models/solitaire_card.dart';
import '../../util/nullable_objects.dart';

class GameController
    extends
        ValueNotifier<
          ({
            List<SolitaireCard> drawingUnopenedCards,
            List<SolitaireCard> drawingOpenedCards,
            List<List<SolitaireCard>> mainCards,
            List<List<SolitaireCard>> finishedCards,
            SelectedCard? selectedCard,
          })
        > {
  ///
  /// CONSTRUCTOR
  ///

  GameController()
    : super(
        (
          drawingUnopenedCards: [],
          drawingOpenedCards: [],
          mainCards: List.generate(7, (_) => []),
          finishedCards: List.generate(4, (_) => []),
          selectedCard: null,
        ),
      );

  ///
  /// INIT
  ///

  void init() {
    newGame();
  }

  ///
  /// METHODS
  ///

  /// Builds and deals a fresh game.
  void newGame() {
    final deck = <SolitaireCard>[];

    /// Generate a full 52-card deck (all suits, ranks 1-13).
    for (final suit in Suit.values) {
      for (var rank = 1; rank <= 13; rank += 1) {
        deck.add(
          SolitaireCard(
            suit: suit,
            rank: rank,
            faceUp: false,
          ),
        );
      }
    }

    /// Shuffle the deck before dealing.
    deck.shuffle();

    final newMainCards = List.generate(7, (_) => <SolitaireCard>[]);
    final newFinishedCards = List.generate(4, (_) => <SolitaireCard>[]);
    final newDrawingUnopenedCards = <SolitaireCard>[];

    /// Deal the tableau: 1..7 cards per column, only top card face-up.
    for (var col = 0; col < newMainCards.length; col += 1) {
      for (var row = 0; row <= col; row += 1) {
        final card = deck.removeLast()..faceUp = row == col;
        newMainCards[col].add(card);
      }
    }

    /// Move remaining cards to the stock (face-down).
    while (deck.isNotEmpty) {
      final card = deck.removeLast()..faceUp = false;
      newDrawingUnopenedCards.add(card);
    }

    /// Commit the new game state in one notifier update.
    updateState(
      newDrawingUnopenedCards: newDrawingUnopenedCards,
      newDrawingOpenedCards: const [],
      newMainCards: newMainCards,
      newFinishedCards: newFinishedCards,
      newSelectedCard: null,
    );
  }

  /// Draws from stock to waste, or recycles waste to stock.
  void drawFromStock() {
    final hasUnopened = value.drawingUnopenedCards.isNotEmpty;
    final hasOpened = value.drawingOpenedCards.isNotEmpty;

    if (!hasUnopened && !hasOpened) {
      if (value.selectedCard != null) {
        updateState(newSelectedCard: null);
      }
      return;
    }

    /// Work on copies to keep notifier updates atomic.
    final drawingUnopened = List<SolitaireCard>.from(value.drawingUnopenedCards);
    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);

    /// Move one card from stock to waste.
    if (drawingUnopened.isNotEmpty) {
      final card = drawingUnopened.removeLast()..faceUp = true;
      drawingOpened.add(card);
    }
    /// Recycle waste back to stock, flipping face-down.
    else if (drawingOpened.isNotEmpty) {
      while (drawingOpened.isNotEmpty) {
        final card = drawingOpened.removeLast()..faceUp = false;
        drawingUnopened.add(card);
      }
    }

    /// Commit the new game state in one notifier update.
    updateState(
      newDrawingUnopenedCards: drawingUnopened,
      newDrawingOpenedCards: drawingOpened,
      newSelectedCard: null,
    );
  }

  /// Toggles selection of the top waste card.
  void selectWasteTop() {
    if (value.drawingOpenedCards.isEmpty) {
      return;
    }

    const next = SelectedCard(
      source: PileType.drawingOpenedCards,
      pileIndex: 0,
    );

    updateState(
      newSelectedCard: value.selectedCard?.source == next.source ? null : next,
    );
  }

  /// Toggles selection of the top card in a tableau column.
  void selectTableauTop(int column) {
    if (column < 0 || column >= value.mainCards.length) {
      return;
    }

    final pile = value.mainCards[column];

    if (pile.isEmpty) {
      return;
    }

    final top = pile.last;

    if (!top.faceUp) {
      return;
    }

    /// Toggle selection for the same column.
    final next = SelectedCard(
      source: PileType.mainCards,
      pileIndex: column,
    );

    final selectedCard = value.selectedCard;

    updateState(
      newSelectedCard: selectedCard?.source == next.source && selectedCard?.pileIndex == next.pileIndex ? null : next,
    );
  }

  /// Flips the top card of a tableau column if it is face-down.
  void flipTableauTop(int column) {
    if (column < 0 || column >= value.mainCards.length) {
      return;
    }

    final pile = value.mainCards[column];

    if (pile.isEmpty) {
      return;
    }

    final top = pile.last;

    if (top.faceUp) {
      return;
    }

    top.faceUp = true;

    /// Update value to notify listeners.
    updateState(
      newMainCards: List<List<SolitaireCard>>.from(
        value.mainCards,
      ),
    );
  }

  /// Attempts to move the selected card to the given foundation.
  void tryMoveSelectedToFoundation(int foundationIndex) {
    if (foundationIndex < 0 || foundationIndex >= value.finishedCards.length) {
      return;
    }

    final selectedCard = value.selectedCard;

    if (selectedCard == null) {
      return;
    }

    /// Resolve the selected card based on its source pile.
    final card = _selectedCardFrom(
      selectedCard,
      drawingOpenedCards: value.drawingOpenedCards,
      mainCards: value.mainCards,
    );

    if (card == null) {
      return;
    }

    final currentFoundation = value.finishedCards[foundationIndex];

    if (!_canMoveToFoundation(card, currentFoundation)) {
      return;
    }

    /// Perform move on copies and commit in a single update.
    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    final mainCards = List<List<SolitaireCard>>.from(value.mainCards);
    final finishedCards = List<List<SolitaireCard>>.from(value.finishedCards);
    final foundation = List<SolitaireCard>.from(currentFoundation);

    _removeSelectedCardAndReveal(
      selectedCard,
      drawingOpenedCards: drawingOpened,
      mainCards: mainCards,
    );

    foundation.add(card);
    finishedCards[foundationIndex] = foundation;

    updateState(
      newDrawingOpenedCards: drawingOpened,
      newMainCards: mainCards,
      newFinishedCards: finishedCards,
      newSelectedCard: null,
    );
  }

  /// Attempts to move the selected card to a tableau column.
  void tryMoveSelectedToTableau(int column) {
    if (column < 0 || column >= value.mainCards.length) {
      return;
    }

    final selectedCard = value.selectedCard;

    if (selectedCard == null) {
      return;
    }

    /// Resolve the selected card based on its source pile.
    final card = _selectedCardFrom(
      selectedCard,
      drawingOpenedCards: value.drawingOpenedCards,
      mainCards: value.mainCards,
    );

    if (card == null) {
      return;
    }

    final currentPile = value.mainCards[column];

    if (!_canMoveToTableau(card, currentPile)) {
      return;
    }

    /// Perform move on copies and commit in a single update.
    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    final mainCards = List<List<SolitaireCard>>.from(value.mainCards);
    final pile = List<SolitaireCard>.from(currentPile);

    _removeSelectedCardAndReveal(
      selectedCard,
      drawingOpenedCards: drawingOpened,
      mainCards: mainCards,
    );

    pile.add(card);
    mainCards[column] = pile;

    updateState(
      newDrawingOpenedCards: drawingOpened,
      newMainCards: mainCards,
      newSelectedCard: null,
    );
  }

  /// Validates whether a drag payload can drop on a foundation pile.
  bool canDropOnFoundation(DragPayload payload, int foundationIndex) {
    if (foundationIndex < 0 || foundationIndex >= value.finishedCards.length) {
      return false;
    }

    final cards = _cardsFromSource(
      payload,
      drawingOpenedCards: value.drawingOpenedCards,
      finishedCards: value.finishedCards,
      mainCards: value.mainCards,
    );

    if (cards.isEmpty || cards.length != 1) {
      return false;
    }

    return _canMoveToFoundation(
      cards.first,
      value.finishedCards[foundationIndex],
    );
  }

  /// Validates whether a drag payload can drop on a tableau column.
  bool canDropOnTableau(DragPayload payload, int column) {
    if (column < 0 || column >= value.mainCards.length) {
      return false;
    }

    if (payload.source == PileType.mainCards && payload.pileIndex == column) {
      return false;
    }

    final cards = _cardsFromSource(
      payload,
      drawingOpenedCards: value.drawingOpenedCards,
      finishedCards: value.finishedCards,
      mainCards: value.mainCards,
    );

    if (cards.isEmpty) {
      return false;
    }

    return _canMoveToTableau(
      cards.first,
      value.mainCards[column],
    );
  }

  /// Executes a drag-drop move to a foundation (after validation).
  void moveDragToFoundation(DragPayload payload, int foundationIndex) {
    if (!canDropOnFoundation(payload, foundationIndex)) {
      return;
    }

    final cards = _cardsFromSource(
      payload,
      drawingOpenedCards: value.drawingOpenedCards,
      finishedCards: value.finishedCards,
      mainCards: value.mainCards,
    );

    if (cards.isEmpty) {
      return;
    }

    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    final finishedCards = List<List<SolitaireCard>>.from(value.finishedCards);
    final mainCards = List<List<SolitaireCard>>.from(value.mainCards);

    _removeCardsFromSource(
      payload,
      drawingOpenedCards: drawingOpened,
      finishedCards: finishedCards,
      mainCards: mainCards,
    );

    final foundation = List<SolitaireCard>.from(finishedCards[foundationIndex])
      ..add(
        cards.first,
      );
    finishedCards[foundationIndex] = foundation;

    updateState(
      newDrawingOpenedCards: drawingOpened,
      newMainCards: mainCards,
      newFinishedCards: finishedCards,
      newSelectedCard: null,
    );
  }

  /// Executes a drag-drop move to a tableau column (after validation).
  void moveDragToTableau(DragPayload payload, int column) {
    if (!canDropOnTableau(payload, column)) {
      return;
    }

    final cards = _cardsFromSource(
      payload,
      drawingOpenedCards: value.drawingOpenedCards,
      finishedCards: value.finishedCards,
      mainCards: value.mainCards,
    );

    if (cards.isEmpty) {
      return;
    }

    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    final mainCards = List<List<SolitaireCard>>.from(value.mainCards);
    final finishedCards = List<List<SolitaireCard>>.from(value.finishedCards);

    _removeCardsFromSource(
      payload,
      drawingOpenedCards: drawingOpened,
      finishedCards: finishedCards,
      mainCards: mainCards,
    );

    final pile = List<SolitaireCard>.from(mainCards[column])..addAll(cards);
    mainCards[column] = pile;

    updateState(
      newDrawingOpenedCards: drawingOpened,
      newMainCards: mainCards,
      newFinishedCards: finishedCards,
      newSelectedCard: null,
    );
  }

  /// Resolves the actual card represented by the selection.
  SolitaireCard? _selectedCardFrom(
    SelectedCard selectedCard, {
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> mainCards,
  }) {
    switch (selectedCard.source) {
      case PileType.drawingOpenedCards:
        return drawingOpenedCards.isNotEmpty ? drawingOpenedCards.last : null;

      case PileType.mainCards:
        final pile = mainCards[selectedCard.pileIndex];
        return pile.isNotEmpty ? pile.last : null;

      default:
        return null;
    }
  }

  /// Removes the selected card and reveals the next tableau card if needed.
  void _removeSelectedCardAndReveal(
    SelectedCard selectedCard, {
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> mainCards,
  }) {
    switch (selectedCard.source) {
      case PileType.drawingOpenedCards:
        if (drawingOpenedCards.isNotEmpty) {
          drawingOpenedCards.removeLast();
        }
        break;

      case PileType.mainCards:
        final pileIndex = selectedCard.pileIndex;
        final pile = List<SolitaireCard>.from(mainCards[pileIndex]);

        if (pile.isNotEmpty) {
          pile.removeLast();
        }

        if (pile.isNotEmpty && !pile.last.faceUp) {
          pile.last.faceUp = true;
        }

        mainCards[pileIndex] = pile;
        break;

      default:
        break;
    }
  }

  /// Returns the cards represented by a drag payload, or empty if invalid.
  List<SolitaireCard> _cardsFromSource(
    DragPayload payload, {
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> finishedCards,
    required List<List<SolitaireCard>> mainCards,
  }) {
    switch (payload.source) {
      case PileType.drawingOpenedCards:
        return drawingOpenedCards.isNotEmpty ? [drawingOpenedCards.last] : const [];

      case PileType.finishedCards:
        if (payload.pileIndex < 0 || payload.pileIndex >= finishedCards.length) {
          return const [];
        }

        final pile = finishedCards[payload.pileIndex];
        return pile.isNotEmpty ? [pile.last] : const [];

      case PileType.mainCards:
        if (payload.pileIndex < 0 || payload.pileIndex >= mainCards.length) {
          return const [];
        }

        final pile = mainCards[payload.pileIndex];

        if (pile.isEmpty) {
          return const [];
        }

        final start = payload.cardIndex < 0 ? pile.length - 1 : payload.cardIndex;

        if (start < 0 || start >= pile.length) {
          return const [];
        }

        final slice = pile.sublist(start);

        if (slice.any((card) => !card.faceUp)) {
          return const [];
        }

        if (!_isValidTableauStack(slice)) {
          return const [];
        }

        return slice;

      default:
        return const [];
    }
  }

  /// Removes cards represented by a drag payload and reveals tableau if needed.
  void _removeCardsFromSource(
    DragPayload payload, {
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> finishedCards,
    required List<List<SolitaireCard>> mainCards,
  }) {
    switch (payload.source) {
      case PileType.drawingOpenedCards:
        if (drawingOpenedCards.isNotEmpty) {
          drawingOpenedCards.removeLast();
        }
        break;

      case PileType.finishedCards:
        if (payload.pileIndex < 0 || payload.pileIndex >= finishedCards.length) {
          return;
        }

        final pileIndex = payload.pileIndex;
        final pile = List<SolitaireCard>.from(finishedCards[pileIndex]);

        if (pile.isNotEmpty) {
          pile.removeLast();
        }

        finishedCards[pileIndex] = pile;
        break;

      case PileType.mainCards:
        if (payload.pileIndex < 0 || payload.pileIndex >= mainCards.length) {
          return;
        }

        final pileIndex = payload.pileIndex;
        final pile = List<SolitaireCard>.from(mainCards[pileIndex]);

        if (pile.isEmpty) {
          return;
        }

        final start = payload.cardIndex < 0 ? pile.length - 1 : payload.cardIndex;

        if (start < 0 || start >= pile.length) {
          return;
        }

        pile.removeRange(start, pile.length);

        if (pile.isNotEmpty && !pile.last.faceUp) {
          pile.last.faceUp = true;
        }

        mainCards[pileIndex] = pile;
        break;

      default:
        break;
    }
  }

  /// Validates a descending alternating-color stack.
  bool _isValidTableauStack(List<SolitaireCard> cards) {
    if (cards.isEmpty) {
      return false;
    }

    for (var i = 0; i < cards.length - 1; i += 1) {
      final current = cards[i];
      final next = cards[i + 1];

      if (current.isRed == next.isRed) {
        return false;
      }

      if (current.rank != next.rank + 1) {
        return false;
      }
    }

    return true;
  }

  /// Checks if a card can be placed on a foundation pile.
  bool _canMoveToFoundation(SolitaireCard card, List<SolitaireCard> foundation) {
    if (foundation.isEmpty) {
      return card.rank == 1;
    }

    final top = foundation.last;
    return card.suit == top.suit && card.rank == top.rank + 1;
  }

  /// Checks if a card can be placed on a tableau pile.
  bool _canMoveToTableau(SolitaireCard card, List<SolitaireCard> pile) {
    if (pile.isEmpty) {
      return card.rank == 13;
    }

    final top = pile.last;

    if (!top.faceUp) {
      return false;
    }

    final isOppositeColor = card.isRed != top.isRed;
    return isOppositeColor && card.rank == top.rank - 1;
  }

  /// Updates `state` with any passed value.
  void updateState({
    List<SolitaireCard>? newDrawingUnopenedCards,
    List<SolitaireCard>? newDrawingOpenedCards,
    List<List<SolitaireCard>>? newMainCards,
    List<List<SolitaireCard>>? newFinishedCards,
    Object? newSelectedCard = noSelectedCard,
  }) {
    value = (
      drawingUnopenedCards: newDrawingUnopenedCards ?? value.drawingUnopenedCards,
      drawingOpenedCards: newDrawingOpenedCards ?? value.drawingOpenedCards,
      mainCards: newMainCards ?? value.mainCards,
      finishedCards: newFinishedCards ?? value.finishedCards,
      selectedCard: newSelectedCard == noSelectedCard ? value.selectedCard : newSelectedCard as SelectedCard?,
    );
  }
}
