import 'dart:math';

import 'package:flutter/foundation.dart';

enum Suit { clubs, diamonds, hearts, spades }

enum PileType { stock, waste, tableau, foundation }

class CardModel {
  CardModel({
    required this.suit,
    required this.rank,
    this.faceUp = false,
  });

  final Suit suit;
  final int rank; // 1-13
  bool faceUp;

  bool get isRed => suit == Suit.diamonds || suit == Suit.hearts;

  String get rankLabel {
    switch (rank) {
      case 1:
        return 'A';
      case 11:
        return 'J';
      case 12:
        return 'Q';
      case 13:
        return 'K';
      default:
        return rank.toString();
    }
  }

  String get suitLabel {
    switch (suit) {
      case Suit.clubs:
        return 'C';
      case Suit.diamonds:
        return 'D';
      case Suit.hearts:
        return 'H';
      case Suit.spades:
        return 'S';
    }
  }

  String get label => '${rankLabel}${suitLabel}';
}

class SelectedCard {
  const SelectedCard({
    required this.source,
    required this.pileIndex,
  });

  final PileType source;
  final int pileIndex;
}

class DragPayload {
  const DragPayload({
    required this.source,
    required this.pileIndex,
    this.cardIndex = -1,
  });

  final PileType source;
  final int pileIndex;
  final int cardIndex;
}

class GameController extends ChangeNotifier {
  GameController() {
    newGame();
  }

  final List<CardModel> stock = [];
  final List<CardModel> waste = [];
  final List<List<CardModel>> tableau = List.generate(7, (_) => []);
  final List<List<CardModel>> foundations = List.generate(4, (_) => []);

  SelectedCard? selected;

  void newGame() {
    final deck = <CardModel>[];
    for (final suit in Suit.values) {
      for (var rank = 1; rank <= 13; rank += 1) {
        deck.add(CardModel(suit: suit, rank: rank));
      }
    }

    deck.shuffle(Random());

    for (final pile in tableau) {
      pile.clear();
    }
    for (final pile in foundations) {
      pile.clear();
    }
    stock.clear();
    waste.clear();
    selected = null;

    for (var col = 0; col < tableau.length; col += 1) {
      for (var row = 0; row <= col; row += 1) {
        final card = deck.removeLast();
        card.faceUp = row == col;
        tableau[col].add(card);
      }
    }

    while (deck.isNotEmpty) {
      final card = deck.removeLast();
      card.faceUp = false;
      stock.add(card);
    }

    notifyListeners();
  }

  void drawFromStock() {
    if (stock.isNotEmpty) {
      final card = stock.removeLast();
      card.faceUp = true;
      waste.add(card);
    } else if (waste.isNotEmpty) {
      while (waste.isNotEmpty) {
        final card = waste.removeLast();
        card.faceUp = false;
        stock.add(card);
      }
    }
    selected = null;
    notifyListeners();
  }

  void selectWasteTop() {
    if (waste.isEmpty) return;
    final next = const SelectedCard(source: PileType.waste, pileIndex: 0);
    if (selected?.source == next.source) {
      selected = null;
    } else {
      selected = next;
    }
    notifyListeners();
  }

  void selectTableauTop(int column) {
    if (column < 0 || column >= tableau.length) return;
    final pile = tableau[column];
    if (pile.isEmpty) return;
    final top = pile.last;
    if (!top.faceUp) return;

    final next = SelectedCard(source: PileType.tableau, pileIndex: column);
    if (selected?.source == next.source && selected?.pileIndex == next.pileIndex) {
      selected = null;
    } else {
      selected = next;
    }
    notifyListeners();
  }

  void flipTableauTop(int column) {
    if (column < 0 || column >= tableau.length) return;
    final pile = tableau[column];
    if (pile.isEmpty) return;
    final top = pile.last;
    if (top.faceUp) return;
    top.faceUp = true;
    notifyListeners();
  }

  void tryMoveSelectedToFoundation(int foundationIndex) {
    if (foundationIndex < 0 || foundationIndex >= foundations.length) return;
    if (selected == null) return;

    final card = _selectedCard;
    if (card == null) return;

    final foundation = foundations[foundationIndex];
    if (!_canMoveToFoundation(card, foundation)) return;

    _removeSelectedCardAndReveal();
    foundation.add(card);
    selected = null;
    notifyListeners();
  }

  void tryMoveSelectedToTableau(int column) {
    if (column < 0 || column >= tableau.length) return;
    if (selected == null) return;

    final card = _selectedCard;
    if (card == null) return;

    final pile = tableau[column];
    if (!_canMoveToTableau(card, pile)) return;

    _removeSelectedCardAndReveal();
    pile.add(card);
    selected = null;
    notifyListeners();
  }

  bool canDropOnFoundation(DragPayload payload, int foundationIndex) {
    if (foundationIndex < 0 || foundationIndex >= foundations.length) return false;
    final cards = _cardsFromSource(payload);
    if (cards.isEmpty || cards.length != 1) return false;
    return _canMoveToFoundation(cards.first, foundations[foundationIndex]);
  }

  bool canDropOnTableau(DragPayload payload, int column) {
    if (column < 0 || column >= tableau.length) return false;
    if (payload.source == PileType.tableau && payload.pileIndex == column) {
      return false;
    }
    final cards = _cardsFromSource(payload);
    if (cards.isEmpty) return false;
    return _canMoveToTableau(cards.first, tableau[column]);
  }

  void moveDragToFoundation(DragPayload payload, int foundationIndex) {
    if (!canDropOnFoundation(payload, foundationIndex)) return;
    final cards = _cardsFromSource(payload);
    if (cards.isEmpty) return;
    _removeCardsFromSource(payload);
    foundations[foundationIndex].add(cards.first);
    selected = null;
    notifyListeners();
  }

  void moveDragToTableau(DragPayload payload, int column) {
    if (!canDropOnTableau(payload, column)) return;
    final cards = _cardsFromSource(payload);
    if (cards.isEmpty) return;
    _removeCardsFromSource(payload);
    tableau[column].addAll(cards);
    selected = null;
    notifyListeners();
  }

  CardModel? get _selectedCard {
    if (selected == null) return null;
    switch (selected!.source) {
      case PileType.waste:
        return waste.isNotEmpty ? waste.last : null;
      case PileType.tableau:
        final pile = tableau[selected!.pileIndex];
        return pile.isNotEmpty ? pile.last : null;
      default:
        return null;
    }
  }

  void _removeSelectedCardAndReveal() {
    if (selected == null) return;
    switch (selected!.source) {
      case PileType.waste:
        if (waste.isNotEmpty) {
          waste.removeLast();
        }
        break;
      case PileType.tableau:
        final pile = tableau[selected!.pileIndex];
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

  List<CardModel> _cardsFromSource(DragPayload payload) {
    switch (payload.source) {
      case PileType.waste:
        return waste.isNotEmpty ? [waste.last] : const [];
      case PileType.foundation:
        if (payload.pileIndex < 0 || payload.pileIndex >= foundations.length) {
          return const [];
        }
        final pile = foundations[payload.pileIndex];
        return pile.isNotEmpty ? [pile.last] : const [];
      case PileType.tableau:
        if (payload.pileIndex < 0 || payload.pileIndex >= tableau.length) {
          return const [];
        }
        final pile = tableau[payload.pileIndex];
        if (pile.isEmpty) return const [];
        final start = payload.cardIndex < 0 ? pile.length - 1 : payload.cardIndex;
        if (start < 0 || start >= pile.length) return const [];
        final slice = pile.sublist(start);
        if (slice.any((card) => !card.faceUp)) return const [];
        if (!_isValidTableauStack(slice)) return const [];
        return slice;
      default:
        return const [];
    }
  }

  void _removeCardsFromSource(DragPayload payload) {
    switch (payload.source) {
      case PileType.waste:
        if (waste.isNotEmpty) {
          waste.removeLast();
        }
        break;
      case PileType.foundation:
        if (payload.pileIndex < 0 || payload.pileIndex >= foundations.length) {
          return;
        }
        final pile = foundations[payload.pileIndex];
        if (pile.isNotEmpty) {
          pile.removeLast();
        }
        break;
      case PileType.tableau:
        if (payload.pileIndex < 0 || payload.pileIndex >= tableau.length) {
          return;
        }
        final pile = tableau[payload.pileIndex];
        if (pile.isEmpty) return;
        final start = payload.cardIndex < 0 ? pile.length - 1 : payload.cardIndex;
        if (start < 0 || start >= pile.length) return;
        pile.removeRange(start, pile.length);
        if (pile.isNotEmpty && !pile.last.faceUp) {
          pile.last.faceUp = true;
        }
        break;
      default:
        break;
    }
  }

  bool _isValidTableauStack(List<CardModel> cards) {
    if (cards.isEmpty) return false;
    for (var i = 0; i < cards.length - 1; i += 1) {
      final current = cards[i];
      final next = cards[i + 1];
      if (current.isRed == next.isRed) return false;
      if (current.rank != next.rank + 1) return false;
    }
    return true;
  }

  bool _canMoveToFoundation(CardModel card, List<CardModel> foundation) {
    if (foundation.isEmpty) {
      return card.rank == 1;
    }
    final top = foundation.last;
    return card.suit == top.suit && card.rank == top.rank + 1;
  }

  bool _canMoveToTableau(CardModel card, List<CardModel> pile) {
    if (pile.isEmpty) {
      return card.rank == 13;
    }
    final top = pile.last;
    if (!top.faceUp) return false;
    final isOppositeColor = card.isRed != top.isRed;
    return isOppositeColor && card.rank == top.rank - 1;
  }
}
