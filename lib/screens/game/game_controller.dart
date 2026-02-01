import 'dart:math';

import '../../constants/enums.dart';
import '../../models/drag_payload.dart';
import '../../models/selected_card.dart';
import '../../models/solitaire_card.dart';

class GameController {
  GameController() {
    newGame();
  }

  final List<SolitaireCard> drawingUnopenedCards = [];
  final List<SolitaireCard> drawingOpenedCards = [];
  final List<List<SolitaireCard>> mainCards = List.generate(7, (_) => []);
  final List<List<SolitaireCard>> finishedCards = List.generate(4, (_) => []);

  SelectedCard? selected;

  void newGame() {
    final deck = <SolitaireCard>[];
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

    deck.shuffle(Random());

    for (final pile in mainCards) {
      pile.clear();
    }
    for (final pile in finishedCards) {
      pile.clear();
    }
    drawingUnopenedCards.clear();
    drawingOpenedCards.clear();
    selected = null;

    for (var col = 0; col < mainCards.length; col += 1) {
      for (var row = 0; row <= col; row += 1) {
        final card = deck.removeLast()..faceUp = row == col;
        mainCards[col].add(card);
      }
    }

    while (deck.isNotEmpty) {
      final card = deck.removeLast()..faceUp = false;
      drawingUnopenedCards.add(card);
    }

    notifyListeners();
  }

  void drawFromStock() {
    if (drawingUnopenedCards.isNotEmpty) {
      final card = drawingUnopenedCards.removeLast()..faceUp = true;
      drawingOpenedCards.add(card);
    } else if (drawingOpenedCards.isNotEmpty) {
      while (drawingOpenedCards.isNotEmpty) {
        final card = drawingOpenedCards.removeLast()..faceUp = false;
        drawingUnopenedCards.add(card);
      }
    }
    selected = null;
    notifyListeners();
  }

  void selectWasteTop() {
    if (drawingOpenedCards.isEmpty) {
      return;
    }
    const next = SelectedCard(source: PileType.drawingOpenedCards, pileIndex: 0);
    if (selected?.source == next.source) {
      selected = null;
    } else {
      selected = next;
    }
    notifyListeners();
  }

  void selectTableauTop(int column) {
    if (column < 0 || column >= mainCards.length) {
      return;
    }
    final pile = mainCards[column];
    if (pile.isEmpty) {
      return;
    }
    final top = pile.last;
    if (!top.faceUp) {
      return;
    }

    final next = SelectedCard(source: PileType.mainCards, pileIndex: column);
    if (selected?.source == next.source && selected?.pileIndex == next.pileIndex) {
      selected = null;
    } else {
      selected = next;
    }
    notifyListeners();
  }

  void flipTableauTop(int column) {
    if (column < 0 || column >= mainCards.length) {
      return;
    }
    final pile = mainCards[column];
    if (pile.isEmpty) {
      return;
    }
    final top = pile.last;
    if (top.faceUp) {
      return;
    }
    top.faceUp = true;
    notifyListeners();
  }

  void tryMoveSelectedToFoundation(int foundationIndex) {
    if (foundationIndex < 0 || foundationIndex >= finishedCards.length) {
      return;
    }
    if (selected == null) {
      return;
    }

    final card = _selectedCard;
    if (card == null) {
      return;
    }

    final foundation = finishedCards[foundationIndex];
    if (!_canMoveToFoundation(card, foundation)) {
      return;
    }

    _removeSelectedCardAndReveal();
    foundation.add(card);
    selected = null;
    notifyListeners();
  }

  void tryMoveSelectedToTableau(int column) {
    if (column < 0 || column >= mainCards.length) {
      return;
    }
    if (selected == null) {
      return;
    }

    final card = _selectedCard;
    if (card == null) {
      return;
    }

    final pile = mainCards[column];
    if (!_canMoveToTableau(card, pile)) {
      return;
    }

    _removeSelectedCardAndReveal();
    pile.add(card);
    selected = null;
    notifyListeners();
  }

  bool canDropOnFoundation(DragPayload payload, int foundationIndex) {
    if (foundationIndex < 0 || foundationIndex >= finishedCards.length) {
      return false;
    }
    final cards = _cardsFromSource(payload);
    if (cards.isEmpty || cards.length != 1) {
      return false;
    }
    return _canMoveToFoundation(cards.first, finishedCards[foundationIndex]);
  }

  bool canDropOnTableau(DragPayload payload, int column) {
    if (column < 0 || column >= mainCards.length) {
      return false;
    }
    if (payload.source == PileType.mainCards && payload.pileIndex == column) {
      return false;
    }
    final cards = _cardsFromSource(payload);
    if (cards.isEmpty) {
      return false;
    }
    return _canMoveToTableau(cards.first, mainCards[column]);
  }

  void moveDragToFoundation(DragPayload payload, int foundationIndex) {
    if (!canDropOnFoundation(payload, foundationIndex)) {
      return;
    }
    final cards = _cardsFromSource(payload);
    if (cards.isEmpty) {
      return;
    }
    _removeCardsFromSource(payload);
    finishedCards[foundationIndex].add(cards.first);
    selected = null;
    notifyListeners();
  }

  void moveDragToTableau(DragPayload payload, int column) {
    if (!canDropOnTableau(payload, column)) {
      return;
    }
    final cards = _cardsFromSource(payload);
    if (cards.isEmpty) {
      return;
    }
    _removeCardsFromSource(payload);
    mainCards[column].addAll(cards);
    selected = null;
    notifyListeners();
  }

  SolitaireCard? get _selectedCard {
    if (selected == null) {
      return null;
    }
    switch (selected!.source) {
      case PileType.drawingOpenedCards:
        return drawingOpenedCards.isNotEmpty ? drawingOpenedCards.last : null;
      case PileType.mainCards:
        final pile = mainCards[selected!.pileIndex];
        return pile.isNotEmpty ? pile.last : null;
      default:
        return null;
    }
  }

  void _removeSelectedCardAndReveal() {
    if (selected == null) {
      return;
    }
    switch (selected!.source) {
      case PileType.drawingOpenedCards:
        if (drawingOpenedCards.isNotEmpty) {
          drawingOpenedCards.removeLast();
        }
        break;
      case PileType.mainCards:
        final pile = mainCards[selected!.pileIndex];
        if (pile.isNotEmpty) {
          pile.removeLast();
        }
        if (pile.isNotEmpty && !pile.last.faceUp) {
          pile.last.faceUp = true;
        }
        break;
      default:
        break;
    }
  }

  List<SolitaireCard> _cardsFromSource(DragPayload payload) {
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

  void _removeCardsFromSource(DragPayload payload) {
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
        final pile = finishedCards[payload.pileIndex];
        if (pile.isNotEmpty) {
          pile.removeLast();
        }
        break;
      case PileType.mainCards:
        if (payload.pileIndex < 0 || payload.pileIndex >= mainCards.length) {
          return;
        }
        final pile = mainCards[payload.pileIndex];
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
        break;
      default:
        break;
    }
  }

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

  bool _canMoveToFoundation(SolitaireCard card, List<SolitaireCard> foundation) {
    if (foundation.isEmpty) {
      return card.rank == 1;
    }
    final top = foundation.last;
    return card.suit == top.suit && card.rank == top.rank + 1;
  }

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
}
