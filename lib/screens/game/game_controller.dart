import 'package:flutter/material.dart';

import '../../constants/enums.dart';
import '../../models/drag_payload.dart';
import '../../models/selected_card.dart';
import '../../models/solitaire_card.dart';
import '../../util/main_stack_layout.dart';
import '../../util/nullable_objects.dart';

class GameController
    extends
        ValueNotifier<
          ({
            List<SolitaireCard> drawingUnopenedCards,
            List<SolitaireCard> drawingOpenedCards,
            List<List<SolitaireCard>> mainCards,
            List<List<SolitaireCard>> finishedCards,
            List<int> mainRevealVersions,
            List<String?> mainRevealCardKeys,
            SelectedCard? selectedCard,
            DragPayload? draggingPayload,
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
          mainRevealVersions: List.filled(7, 0),
          mainRevealCardKeys: List.filled(7, null),
          selectedCard: null,
          draggingPayload: null,
        ),
      );

  ///
  /// VARIABLES
  ///

  late final List<GlobalKey> mainColumnKeys = List.generate(
    7,
    (_) => GlobalKey(),
  );
  late final List<GlobalKey> finishedPileKeys = List.generate(
    4,
    (_) => GlobalKey(),
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

  /// Builds and deals a fresh game
  void newGame() {
    final deck = <SolitaireCard>[];

    /// Generate a full 52-card deck (all suits, ranks 1-13)
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

    /// Shuffle the deck before dealing
    deck.shuffle();

    final newMainCards = List.generate(7, (_) => <SolitaireCard>[]);
    final newFinishedCards = List.generate(4, (_) => <SolitaireCard>[]);
    final newDrawingUnopenedCards = <SolitaireCard>[];

    /// Deal the main cards: 1..7 cards per column, only top card face-up
    for (var col = 0; col < newMainCards.length; col += 1) {
      for (var row = 0; row <= col; row += 1) {
        final card = deck.removeLast()..faceUp = row == col;
        newMainCards[col].add(card);
      }
    }

    /// Move remaining cards to the drawing unopened (face-down)
    while (deck.isNotEmpty) {
      final card = deck.removeLast()..faceUp = false;
      newDrawingUnopenedCards.add(card);
    }

    /// Commit the new game state in one notifier update
    updateState(
      newDrawingUnopenedCards: newDrawingUnopenedCards,
      newDrawingOpenedCards: const [],
      newMainCards: newMainCards,
      newFinishedCards: newFinishedCards,
      newMainRevealVersions: List.filled(7, 0),
      newMainRevealCardKeys: List.filled(7, null),
      newSelectedCard: null,
    );
  }

  /// Draws from unopened section to opened section, or recycles opened section to unopened section
  void drawFromUnopenedSection() {
    final hasUnopened = value.drawingUnopenedCards.isNotEmpty;
    final hasOpened = value.drawingOpenedCards.isNotEmpty;

    if (!hasUnopened && !hasOpened) {
      if (value.selectedCard != null) {
        updateState(newSelectedCard: null);
      }
      return;
    }

    /// Work on copies to keep notifier updates atomic
    final drawingUnopened = List<SolitaireCard>.from(value.drawingUnopenedCards);
    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);

    /// Move one card from drawing unopened to drawing opened
    if (drawingUnopened.isNotEmpty) {
      final card = drawingUnopened.removeLast()..faceUp = true;
      drawingOpened.add(card);
    }
    /// Recycle drawing opened back to drawing unopened, flipping face-down
    else if (drawingOpened.isNotEmpty) {
      while (drawingOpened.isNotEmpty) {
        final card = drawingOpened.removeLast()..faceUp = false;
        drawingUnopened.add(card);
      }
    }

    /// Commit the new game state in one notifier update
    updateState(
      newDrawingUnopenedCards: drawingUnopened,
      newDrawingOpenedCards: drawingOpened,
      newSelectedCard: null,
    );
  }

  /// Toggles selection of the top unopened section card
  void selectUnopenedSectionTop() {
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

  /// Toggles selection of the top card in a main cards column
  void selectMainCardsTop(int column) {
    if (column < 0 || column >= value.mainCards.length) {
      return;
    }

    final pile = value.mainCards[column];

    if (pile.isEmpty) {
      return;
    }

    selectMainCardsAt(column, pile.length - 1);
  }

  /// Toggles selection of a specific card in a main cards column
  void selectMainCardsAt(int column, int cardIndex) {
    if (column < 0 || column >= value.mainCards.length) {
      return;
    }

    final pile = value.mainCards[column];

    if (pile.isEmpty) {
      return;
    }

    if (cardIndex < 0 || cardIndex >= pile.length) {
      return;
    }

    final card = pile[cardIndex];

    if (!card.faceUp) {
      return;
    }

    final slice = pile.sublist(cardIndex);
    final normalizedIndex = slice.any((pileCard) => !pileCard.faceUp) || !isValidMainStack(slice) ? pile.length - 1 : cardIndex;

    /// Toggle selection for the same column
    final next = SelectedCard(
      source: PileType.mainCards,
      pileIndex: column,
      cardIndex: normalizedIndex,
    );

    final currentSelected = value.selectedCard;

    updateState(
      newSelectedCard: currentSelected?.source == next.source && currentSelected?.pileIndex == next.pileIndex && currentSelected?.cardIndex == next.cardIndex ? null : next,
    );
  }

  /// Flips the top card of a main cards column if it is face-down
  void flipMainCardsTop(int column) {
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

    /// Update value to notify listeners
    updateState(
      newMainCards: List<List<SolitaireCard>>.from(
        value.mainCards,
      ),
    );
  }

  /// Attempts to move the selected card to the given finished cards pile
  void tryMoveSelectedToFinished(int finishedIndex) {
    if (finishedIndex < 0 || finishedIndex >= value.finishedCards.length) {
      return;
    }

    final selectedCard = value.selectedCard;

    if (selectedCard == null) {
      return;
    }

    if (selectedCard.source == PileType.mainCards) {
      final pile = value.mainCards[selectedCard.pileIndex];

      if (selectedCard.cardIndex < 0 || selectedCard.cardIndex >= pile.length) {
        return;
      }

      if (selectedCard.cardIndex != pile.length - 1) {
        return;
      }
    }

    /// Resolve the selected card based on its source pile
    final card = selectedCardFrom(
      selectedCard,
      drawingOpenedCards: value.drawingOpenedCards,
      mainCards: value.mainCards,
    );

    if (card == null) {
      return;
    }

    final currentFinished = value.finishedCards[finishedIndex];

    if (!canMoveToFinished(card, currentFinished)) {
      return;
    }

    /// Perform move on copies and commit in a single update
    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    final mainCards = List<List<SolitaireCard>>.from(value.mainCards);
    final finishedCards = List<List<SolitaireCard>>.from(value.finishedCards);
    final mainRevealVersions = List<int>.from(value.mainRevealVersions);
    final mainRevealCardKeys = List<String?>.from(value.mainRevealCardKeys);
    final finished = List<SolitaireCard>.from(currentFinished);

    removeSelectedCardAndReveal(
      selectedCard,
      drawingOpenedCards: drawingOpened,
      mainCards: mainCards,
      mainRevealVersions: mainRevealVersions,
      mainRevealCardKeys: mainRevealCardKeys,
    );

    finished.add(card);
    finishedCards[finishedIndex] = finished;

    updateState(
      newDrawingOpenedCards: drawingOpened,
      newMainCards: mainCards,
      newFinishedCards: finishedCards,
      newMainRevealVersions: mainRevealVersions,
      newMainRevealCardKeys: mainRevealCardKeys,
      newSelectedCard: null,
    );
  }

  /// Attempts to move the selected card to main cards column
  void tryMoveSelectedToMain(int column) {
    if (column < 0 || column >= value.mainCards.length) {
      return;
    }

    final selectedCard = value.selectedCard;

    if (selectedCard == null) {
      return;
    }

    final stack = selectedStackFrom(
      selectedCard,
      drawingOpenedCards: value.drawingOpenedCards,
      mainCards: value.mainCards,
    );

    if (stack.isEmpty) {
      return;
    }

    final currentPile = value.mainCards[column];

    if (!canMoveToMain(stack.first, currentPile)) {
      return;
    }

    /// Perform move on copies and commit in a single update
    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    final mainCards = List<List<SolitaireCard>>.from(value.mainCards);
    final mainRevealVersions = List<int>.from(value.mainRevealVersions);
    final mainRevealCardKeys = List<String?>.from(value.mainRevealCardKeys);
    final pile = List<SolitaireCard>.from(currentPile);

    if (selectedCard.source == PileType.mainCards) {
      final sourcePile = mainCards[selectedCard.pileIndex];
      final startIndex = sourcePile.length - stack.length;

      final payload = DragPayload(
        source: PileType.mainCards,
        pileIndex: selectedCard.pileIndex,
        cardIndex: startIndex,
      );

      removeCardsFromSource(
        payload,
        drawingOpenedCards: drawingOpened,
        finishedCards: value.finishedCards,
        mainCards: mainCards,
        mainRevealVersions: mainRevealVersions,
        mainRevealCardKeys: mainRevealCardKeys,
      );
    } else {
      removeSelectedCardAndReveal(
        selectedCard,
        drawingOpenedCards: drawingOpened,
        mainCards: mainCards,
        mainRevealVersions: mainRevealVersions,
        mainRevealCardKeys: mainRevealCardKeys,
      );
    }

    pile.addAll(stack);
    mainCards[column] = pile;

    updateState(
      newDrawingOpenedCards: drawingOpened,
      newMainCards: mainCards,
      newMainRevealVersions: mainRevealVersions,
      newMainRevealCardKeys: mainRevealCardKeys,
      newSelectedCard: null,
    );
  }

  /// Validates whether a drag payload can drop on a finished pile
  bool canDropOnFinished(DragPayload payload, int finishedIndex) {
    if (finishedIndex < 0 || finishedIndex >= value.finishedCards.length) {
      return false;
    }

    final cards = cardsFromSource(
      payload,
      drawingOpenedCards: value.drawingOpenedCards,
      finishedCards: value.finishedCards,
      mainCards: value.mainCards,
    );

    if (cards.isEmpty || cards.length != 1) {
      return false;
    }

    return canMoveToFinished(
      cards.first,
      value.finishedCards[finishedIndex],
    );
  }

  /// Validates whether a drag payload can drop on main cards column
  bool canDropOnMain(DragPayload payload, int column) {
    if (column < 0 || column >= value.mainCards.length) {
      return false;
    }

    if (payload.source == PileType.mainCards && payload.pileIndex == column) {
      return false;
    }

    final cards = cardsFromSource(
      payload,
      drawingOpenedCards: value.drawingOpenedCards,
      finishedCards: value.finishedCards,
      mainCards: value.mainCards,
    );

    if (cards.isEmpty) {
      return false;
    }

    return canMoveToMain(
      cards.first,
      value.mainCards[column],
    );
  }

  /// Executes a drag-drop move to finished cards (after validation)
  void moveDragToFinished(DragPayload payload, int finishedIndex) {
    if (!canDropOnFinished(payload, finishedIndex)) {
      return;
    }

    final cards = cardsFromSource(
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
    final mainRevealVersions = List<int>.from(value.mainRevealVersions);
    final mainRevealCardKeys = List<String?>.from(value.mainRevealCardKeys);

    removeCardsFromSource(
      payload,
      drawingOpenedCards: drawingOpened,
      finishedCards: finishedCards,
      mainCards: mainCards,
      mainRevealVersions: mainRevealVersions,
      mainRevealCardKeys: mainRevealCardKeys,
    );

    final finished = List<SolitaireCard>.from(finishedCards[finishedIndex])
      ..add(
        cards.first,
      );
    finishedCards[finishedIndex] = finished;

    updateState(
      newDrawingOpenedCards: drawingOpened,
      newMainCards: mainCards,
      newFinishedCards: finishedCards,
      newMainRevealVersions: mainRevealVersions,
      newMainRevealCardKeys: mainRevealCardKeys,
      newSelectedCard: null,
    );
  }

  /// Executes a drag-drop move to main cards column (after validation)
  void moveDragToMain(DragPayload payload, int column) {
    if (!canDropOnMain(payload, column)) {
      return;
    }

    final cards = cardsFromSource(
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
    final mainRevealVersions = List<int>.from(value.mainRevealVersions);
    final mainRevealCardKeys = List<String?>.from(value.mainRevealCardKeys);

    removeCardsFromSource(
      payload,
      drawingOpenedCards: drawingOpened,
      finishedCards: finishedCards,
      mainCards: mainCards,
      mainRevealVersions: mainRevealVersions,
      mainRevealCardKeys: mainRevealCardKeys,
    );

    final pile = List<SolitaireCard>.from(mainCards[column])..addAll(cards);
    mainCards[column] = pile;

    updateState(
      newDrawingOpenedCards: drawingOpened,
      newMainCards: mainCards,
      newFinishedCards: finishedCards,
      newMainRevealVersions: mainRevealVersions,
      newMainRevealCardKeys: mainRevealCardKeys,
      newSelectedCard: null,
    );
  }

  /// Resolves the actual card represented by the selection
  SolitaireCard? selectedCardFrom(
    SelectedCard selectedCard, {
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> mainCards,
  }) {
    switch (selectedCard.source) {
      case PileType.drawingOpenedCards:
        return drawingOpenedCards.isNotEmpty ? drawingOpenedCards.last : null;

      case PileType.mainCards:
        final pile = mainCards[selectedCard.pileIndex];
        if (pile.isEmpty) {
          return null;
        }

        if (selectedCard.cardIndex >= 0 && selectedCard.cardIndex < pile.length) {
          return pile[selectedCard.cardIndex];
        }

        return pile.last;

      default:
        return null;
    }
  }

  /// Resolves the full stack represented by the selection
  List<SolitaireCard> selectedStackFrom(
    SelectedCard selectedCard, {
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> mainCards,
  }) {
    switch (selectedCard.source) {
      case PileType.drawingOpenedCards:
        return drawingOpenedCards.isNotEmpty ? [drawingOpenedCards.last] : const [];

      case PileType.mainCards:
        if (selectedCard.pileIndex < 0 || selectedCard.pileIndex >= mainCards.length) {
          return const [];
        }

        final pile = mainCards[selectedCard.pileIndex];
        if (pile.isEmpty) {
          return const [];
        }

        final start = selectedCard.cardIndex >= 0 ? selectedCard.cardIndex : pile.length - 1;
        if (start < 0 || start >= pile.length) {
          return const [];
        }

        final slice = pile.sublist(start);
        if (slice.any((card) => !card.faceUp)) {
          return const [];
        }

        if (!isValidMainStack(slice)) {
          return pile.last.faceUp ? [pile.last] : const [];
        }

        return slice;

      default:
        return const [];
    }
  }

  /// Removes the selected card and reveals the next main card if needed
  void removeSelectedCardAndReveal(
    SelectedCard selectedCard, {
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> mainCards,
    required List<int> mainRevealVersions,
    required List<String?> mainRevealCardKeys,
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
          mainRevealVersions[pileIndex] += 1;
          mainRevealCardKeys[pileIndex] = pile.last.revealKey;
        }

        mainCards[pileIndex] = pile;
        break;

      default:
        break;
    }
  }

  /// Returns the cards represented by a drag payload, or empty if invalid
  List<SolitaireCard> cardsFromSource(
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

        if (!isValidMainStack(slice)) {
          return const [];
        }

        return slice;

      default:
        return const [];
    }
  }

  /// Removes cards represented by a drag payload and reveals main if needed
  void removeCardsFromSource(
    DragPayload payload, {
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> finishedCards,
    required List<List<SolitaireCard>> mainCards,
    required List<int> mainRevealVersions,
    required List<String?> mainRevealCardKeys,
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
          mainRevealVersions[pileIndex] += 1;
          mainRevealCardKeys[pileIndex] = pile.last.revealKey;
        }

        mainCards[pileIndex] = pile;
        break;

      default:
        break;
    }
  }

  /// Validates a descending alternating-color stack
  bool isValidMainStack(List<SolitaireCard> cards) {
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

  /// Checks if a card can be placed on finished pile
  bool canMoveToFinished(SolitaireCard card, List<SolitaireCard> finished) {
    if (finished.isEmpty) {
      return card.rank == 1;
    }

    final top = finished.last;
    return card.suit == top.suit && card.rank == top.rank + 1;
  }

  /// Checks if a card can be placed on main pile
  bool canMoveToMain(SolitaireCard card, List<SolitaireCard> pile) {
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

  /// Triggered when user starts dragging [CardMain]
  void setDraggingPayload(DragPayload? payload) {
    if (value.draggingPayload == payload) {
      return;
    }

    updateState(
      newDraggingPayload: payload,
    );
  }

  int getSelectedStartIndex({
    required List<SolitaireCard> mainCards,
    required SelectedCard? selectedCard,
  }) {
    if (selectedCard == null || mainCards.isEmpty) {
      return -1;
    }

    final start = selectedCard.cardIndex >= 0 ? selectedCard.cardIndex : mainCards.length - 1;

    if (start < 0 || start >= mainCards.length) {
      return mainCards.length - 1;
    }

    final slice = mainCards.sublist(start);

    if (slice.isEmpty || slice.any((card) => !card.faceUp) || !isValidMainStack(slice)) {
      return mainCards.length - 1;
    }

    return start;
  }

  Rect? rectFromKey(GlobalKey key) {
    final context = key.currentContext;

    if (context == null) {
      return null;
    }

    final box = context.findRenderObject() as RenderBox?;

    if (box == null || !box.hasSize) {
      return null;
    }

    final offset = box.localToGlobal(Offset.zero);

    return offset & box.size;
  }

  Rect? mainCardRect(int column, int cardIndex) {
    final base = rectFromKey(mainColumnKeys[column]);

    if (base == null) {
      return null;
    }

    final cards = value.mainCards[column];
    final topLeft = base.topLeft + Offset(
      0,
      mainStackTopOffset(
        cards,
        cardIndex,
        cardWidth: base.width,
      ),
    );

    return Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      base.width,
      base.height,
    );
  }

  /// Updates `state` with any passed value
  void updateState({
    List<SolitaireCard>? newDrawingUnopenedCards,
    List<SolitaireCard>? newDrawingOpenedCards,
    List<List<SolitaireCard>>? newMainCards,
    List<List<SolitaireCard>>? newFinishedCards,
    List<int>? newMainRevealVersions,
    List<String?>? newMainRevealCardKeys,
    Object? newSelectedCard = noSelectedCard,
    Object? newDraggingPayload = noDraggingPayload,
  }) {
    value = (
      drawingUnopenedCards: newDrawingUnopenedCards ?? value.drawingUnopenedCards,
      drawingOpenedCards: newDrawingOpenedCards ?? value.drawingOpenedCards,
      mainCards: newMainCards ?? value.mainCards,
      finishedCards: newFinishedCards ?? value.finishedCards,
      mainRevealVersions: newMainRevealVersions ?? value.mainRevealVersions,
      mainRevealCardKeys: newMainRevealCardKeys ?? value.mainRevealCardKeys,
      selectedCard: newSelectedCard == noSelectedCard ? value.selectedCard : newSelectedCard as SelectedCard?,
      draggingPayload: newDraggingPayload == noDraggingPayload ? value.draggingPayload : newDraggingPayload as DragPayload?,
    );
  }
}
