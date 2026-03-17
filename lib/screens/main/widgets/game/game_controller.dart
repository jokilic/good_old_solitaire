import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../../constants/enums.dart';
import '../../../../models/drag_payload.dart';
import '../../../../models/game_history_snapshot.dart';
import '../../../../models/game_setup_snapshot.dart';
import '../../../../models/selected_card.dart';
import '../../../../models/solitaire_card.dart';
import '../../../../services/sound_service.dart';
import '../../../../util/main_stack_layout.dart';
import '../../../../util/nullable_objects.dart';

class GameController
    extends
        ValueNotifier<
          ({
            bool canHint,
            bool canUndo,
            List<SolitaireCard> drawingUnopenedCards,
            List<SolitaireCard> drawingOpenedCards,
            int drawingRevealVersion,
            String? drawingRevealCardKey,
            int elapsedSeconds,
            int moveCounter,
            int score,
            List<List<SolitaireCard>> mainCards,
            List<List<SolitaireCard>> finishedCards,
            List<int> mainRevealVersions,
            List<String?> mainRevealCardKeys,
            SelectedCard? selectedCard,
            DragPayload? draggingPayload,
            int dropSettleVersion,
            PileType? dropSettleTarget,
            int? dropSettlePileIndex,
            List<String> dropSettleCardKeys,
            Offset? dropSettleFromOffset,
          })
        >
    with Disposable {
  ///
  /// CONSTRUCTOR
  ///

  final SoundService sound;

  GameController({
    required this.sound,
  }) : super(
         (
           canHint: true,
           canUndo: false,
           drawingUnopenedCards: [],
           drawingOpenedCards: [],
           drawingRevealVersion: 0,
           drawingRevealCardKey: null,
           elapsedSeconds: 0,
           moveCounter: 0,
           score: 0,
           mainCards: List.generate(7, (_) => []),
           finishedCards: List.generate(4, (_) => []),
           mainRevealVersions: List.filled(7, 0),
           mainRevealCardKeys: List.filled(7, null),
           selectedCard: null,
           draggingPayload: null,
           dropSettleVersion: 0,
           dropSettleTarget: null,
           dropSettlePileIndex: null,
           dropSettleCardKeys: const [],
           dropSettleFromOffset: null,
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

  Timer? gameTimer;
  DateTime? gameTimerStartedAt;

  GameSetupSnapshot? initialGameSetup;
  final moveHistory = <GameHistorySnapshot>[];

  GameHistorySnapshot? get lastMoveSnapshot => moveHistory.isEmpty ? null : moveHistory.last;

  static const int scoreForStockToTableau = 5;
  static const int scoreForMoveToFoundation = 10;
  static const int scoreForRevealTableauCard = 5;

  static const int scoreForFoundationToTableau = 0;
  static const int scorePenaltyForHint = 0;
  static const int scorePenaltyForUndo = 0;

  ///
  /// INIT
  ///

  void init() {
    newGame();
  }

  ///
  /// DISPOSE
  ///

  @override
  void onDispose() {
    gameTimer?.cancel();
  }

  ///
  /// METHODS
  ///

  /// Builds and deals a fresh game
  void newGame() {
    moveHistory.clear();
    resetAndStartTimer();

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

    // Keep a stable snapshot of the initial deal so reset can restore it.
    initialGameSetup = GameSetupSnapshot(
      drawingUnopenedCards: cloneCards(
        newDrawingUnopenedCards,
      ),
      mainCards: cloneCardColumns(
        newMainCards,
      ),
    );

    /// Commit the new game state in one notifier update
    updateState(
      newDrawingUnopenedCards: newDrawingUnopenedCards,
      newDrawingOpenedCards: const [],
      newDrawingRevealVersion: 0,
      newDrawingRevealCardKey: null,
      newMoveCounter: 0,
      newScore: 0,
      newMainCards: newMainCards,
      newFinishedCards: newFinishedCards,
      newMainRevealVersions: List.filled(7, 0),
      newMainRevealCardKeys: List.filled(7, null),
      newSelectedCard: null,
      newDropSettleTarget: null,
      newDropSettlePileIndex: null,
      newDropSettleCardKeys: const [],
      newDropSettleFromOffset: null,
    );
  }

  /// Restores the current game to its original dealt layout
  void resetGame() {
    final setup = initialGameSetup;

    if (setup == null) {
      newGame();
      return;
    }

    moveHistory.clear();
    resetAndStartTimer();

    updateState(
      newDrawingUnopenedCards: cloneCards(
        setup.drawingUnopenedCards,
      ),
      newDrawingOpenedCards: const [],
      newDrawingRevealVersion: 0,
      newDrawingRevealCardKey: null,
      newMoveCounter: 0,
      newScore: 0,
      newMainCards: cloneCardColumns(
        setup.mainCards,
      ),
      newFinishedCards: List.generate(
        4,
        (_) => <SolitaireCard>[],
      ),
      newMainRevealVersions: List.filled(7, 0),
      newMainRevealCardKeys: List.filled(7, null),
      newSelectedCard: null,
      newDraggingPayload: null,
      newDropSettleVersion: 0,
      newDropSettleTarget: null,
      newDropSettlePileIndex: null,
      newDropSettleCardKeys: const [],
      newDropSettleFromOffset: null,
    );
  }

  void resetAndStartTimer() {
    gameTimer?.cancel();
    gameTimerStartedAt = DateTime.now();

    updateState(
      newElapsedSeconds: 0,
      newScore: value.score,
    );

    gameTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final startedAt = gameTimerStartedAt;

        if (startedAt == null) {
          return;
        }

        final nextSeconds = DateTime.now().difference(startedAt).inSeconds;

        if (value.elapsedSeconds == nextSeconds) {
          return;
        }

        updateState(
          newElapsedSeconds: nextSeconds,
        );
      },
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

    saveCurrentStateToHistory();

    /// Work on copies to keep notifier updates atomic
    final drawingUnopened = List<SolitaireCard>.from(value.drawingUnopenedCards);
    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    var drawingRevealVersion = value.drawingRevealVersion;
    var drawingRevealCardKey = value.drawingRevealCardKey;
    var didDrawCard = false;
    var didResetDrawPile = false;

    /// Move one card from drawing unopened to drawing opened
    if (drawingUnopened.isNotEmpty) {
      final card = drawingUnopened.removeLast()..faceUp = true;
      drawingOpened.add(card);
      drawingRevealVersion += 1;
      drawingRevealCardKey = card.revealKey;
      didDrawCard = true;
    }
    /// Recycle drawing opened back to drawing unopened, flipping face-down
    else if (drawingOpened.isNotEmpty) {
      while (drawingOpened.isNotEmpty) {
        final card = drawingOpened.removeLast()..faceUp = false;
        drawingUnopened.add(card);
      }
      drawingRevealCardKey = null;
      didResetDrawPile = true;
    }

    /// Commit the new game state in one notifier update
    updateState(
      newDrawingUnopenedCards: drawingUnopened,
      newDrawingOpenedCards: drawingOpened,
      newDrawingRevealVersion: drawingRevealVersion,
      newDrawingRevealCardKey: drawingRevealCardKey,
      newSelectedCard: null,
    );

    if (didDrawCard) {
      unawaited(sound.playCardDraw());
    }

    if (didResetDrawPile) {
      unawaited(sound.playDrawPileReset());
    }
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

    saveCurrentStateToHistory();
    top.faceUp = true;

    /// Update value to notify listeners
    updateState(
      newMainCards: List<List<SolitaireCard>>.from(
        value.mainCards,
      ),
      newScore: value.score + scoreForRevealTableauCard,
    );

    unawaited(sound.playCardFlip());
  }

  /// Selects a legal move source so the UI can visually point the player at a hint
  void selectHint() {
    final hintSelection = hintSelectionFromState(
      drawingOpenedCards: value.drawingOpenedCards,
      mainCards: value.mainCards,
      finishedCards: value.finishedCards,
    );

    if (hintSelection != null) {
      updateState(
        newSelectedCard: hintSelection,
        newScore: value.score + scorePenaltyForHint,
      );
      return;
    }

    updateState(
      newSelectedCard: const SelectedCard(
        source: PileType.drawingUnopenedCards,
        pileIndex: 0,
      ),
      newScore: value.score + scorePenaltyForHint,
    );

    if (value.drawingUnopenedCards.isNotEmpty) {
      return;
    }

    if (value.drawingOpenedCards.isNotEmpty) {
      return;
    }

    updateState(
      newSelectedCard: null,
      newScore: value.score,
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

    saveCurrentStateToHistory(
      undoTarget: selectedCard.source,
      undoTargetPileIndex: selectedCard.source == PileType.drawingOpenedCards ? null : selectedCard.pileIndex,
      undoCardKeys: [card.revealKey],
    );

    /// Perform move on copies and commit in a single update
    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    final mainCards = List<List<SolitaireCard>>.from(value.mainCards);
    final finishedCards = List<List<SolitaireCard>>.from(value.finishedCards);
    final mainRevealVersions = List<int>.from(value.mainRevealVersions);
    final mainRevealCardKeys = List<String?>.from(value.mainRevealCardKeys);
    final finished = List<SolitaireCard>.from(currentFinished);

    final scoreDelta = removeSelectedCardAndReveal(
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
      newMoveCounter: value.moveCounter + 1,
      newScore: value.score + scoreForMoveToFoundation + scoreDelta,
      newSelectedCard: null,
    );

    unawaited(sound.playCardPlace());
  }

  /// Resolves the next available hint without mutating the board
  SelectedCard? hintSelectionFromState({
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> mainCards,
    required List<List<SolitaireCard>> finishedCards,
  }) {
    final drawingOpenedSelection = hintFromDrawingOpenedToFinishedState(
      drawingOpenedCards: drawingOpenedCards,
      finishedCards: finishedCards,
    );

    if (drawingOpenedSelection != null) {
      return drawingOpenedSelection;
    }

    final mainToFinishedSelection = hintFromMainToFinishedState(
      mainCards: mainCards,
      finishedCards: finishedCards,
    );

    if (mainToFinishedSelection != null) {
      return mainToFinishedSelection;
    }

    final drawingOpenedToMainSelection = hintFromDrawingOpenedToMainState(
      drawingOpenedCards: drawingOpenedCards,
      mainCards: mainCards,
    );

    if (drawingOpenedToMainSelection != null) {
      return drawingOpenedToMainSelection;
    }

    return hintFromMainToMainState(
      mainCards: mainCards,
    );
  }

  SelectedCard? hintFromDrawingOpenedToFinished() => hintFromDrawingOpenedToFinishedState(
    drawingOpenedCards: value.drawingOpenedCards,
    finishedCards: value.finishedCards,
  );

  SelectedCard? hintFromDrawingOpenedToFinishedState({
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> finishedCards,
  }) {
    if (drawingOpenedCards.isEmpty) {
      return null;
    }

    final card = drawingOpenedCards.last;

    for (var finishedIndex = 0; finishedIndex < finishedCards.length; finishedIndex += 1) {
      if (canMoveToFinished(card, finishedCards[finishedIndex])) {
        return const SelectedCard(
          source: PileType.drawingOpenedCards,
          pileIndex: 0,
        );
      }
    }

    return null;
  }

  SelectedCard? hintFromMainToFinished() => hintFromMainToFinishedState(
    mainCards: value.mainCards,
    finishedCards: value.finishedCards,
  );

  SelectedCard? hintFromMainToFinishedState({
    required List<List<SolitaireCard>> mainCards,
    required List<List<SolitaireCard>> finishedCards,
  }) {
    for (var column = 0; column < mainCards.length; column += 1) {
      final pile = mainCards[column];

      if (pile.isEmpty || !pile.last.faceUp) {
        continue;
      }

      final card = pile.last;

      for (var finishedIndex = 0; finishedIndex < finishedCards.length; finishedIndex += 1) {
        if (canMoveToFinished(card, finishedCards[finishedIndex])) {
          return SelectedCard(
            source: PileType.mainCards,
            pileIndex: column,
            cardIndex: pile.length - 1,
          );
        }
      }
    }

    return null;
  }

  SelectedCard? hintFromDrawingOpenedToMain() => hintFromDrawingOpenedToMainState(
    drawingOpenedCards: value.drawingOpenedCards,
    mainCards: value.mainCards,
  );

  SelectedCard? hintFromDrawingOpenedToMainState({
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> mainCards,
  }) {
    if (drawingOpenedCards.isEmpty) {
      return null;
    }

    final card = drawingOpenedCards.last;

    for (var column = 0; column < mainCards.length; column += 1) {
      if (canMoveToMain(card, mainCards[column])) {
        return const SelectedCard(
          source: PileType.drawingOpenedCards,
          pileIndex: 0,
        );
      }
    }

    return null;
  }

  SelectedCard? hintFromMainToMain() => hintFromMainToMainState(
    mainCards: value.mainCards,
  );

  SelectedCard? hintFromMainToMainState({
    required List<List<SolitaireCard>> mainCards,
  }) {
    for (var column = 0; column < mainCards.length; column += 1) {
      final pile = mainCards[column];

      if (pile.isEmpty) {
        continue;
      }

      for (var cardIndex = 0; cardIndex < pile.length; cardIndex += 1) {
        final card = pile[cardIndex];

        if (!card.faceUp) {
          continue;
        }

        final stack = pile.sublist(cardIndex);

        if (!isValidMainStack(stack)) {
          continue;
        }

        for (var targetColumn = 0; targetColumn < mainCards.length; targetColumn += 1) {
          if (targetColumn == column) {
            continue;
          }

          if (canMoveToMain(stack.first, mainCards[targetColumn])) {
            return SelectedCard(
              source: PileType.mainCards,
              pileIndex: column,
              cardIndex: cardIndex,
            );
          }
        }
      }
    }

    return null;
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

    saveCurrentStateToHistory(
      undoTarget: selectedCard.source,
      undoTargetPileIndex: selectedCard.source == PileType.drawingOpenedCards ? null : selectedCard.pileIndex,
      undoCardKeys: [
        for (final card in stack) card.revealKey,
      ],
    );

    /// Perform move on copies and commit in a single update
    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    final mainCards = List<List<SolitaireCard>>.from(value.mainCards);
    final mainRevealVersions = List<int>.from(value.mainRevealVersions);
    final mainRevealCardKeys = List<String?>.from(value.mainRevealCardKeys);
    final pile = List<SolitaireCard>.from(currentPile);

    var scoreDelta = 0;

    if (selectedCard.source == PileType.mainCards) {
      final sourcePile = mainCards[selectedCard.pileIndex];
      final startIndex = sourcePile.length - stack.length;

      final payload = DragPayload(
        source: PileType.mainCards,
        pileIndex: selectedCard.pileIndex,
        cardIndex: startIndex,
      );

      scoreDelta = removeCardsFromSource(
        payload,
        drawingOpenedCards: drawingOpened,
        finishedCards: value.finishedCards,
        mainCards: mainCards,
        mainRevealVersions: mainRevealVersions,
        mainRevealCardKeys: mainRevealCardKeys,
      );
    } else {
      scoreDelta = removeSelectedCardAndReveal(
        selectedCard,
        drawingOpenedCards: drawingOpened,
        mainCards: mainCards,
        mainRevealVersions: mainRevealVersions,
        mainRevealCardKeys: mainRevealCardKeys,
      );
    }

    pile.addAll(stack);
    mainCards[column] = pile;

    final moveScore = selectedCard.source == PileType.drawingOpenedCards ? scoreForStockToTableau : 0;

    updateState(
      newDrawingOpenedCards: drawingOpened,
      newMainCards: mainCards,
      newMainRevealVersions: mainRevealVersions,
      newMainRevealCardKeys: mainRevealCardKeys,
      newMoveCounter: value.moveCounter + 1,
      newScore: value.score + moveScore + scoreDelta,
      newSelectedCard: null,
    );

    unawaited(sound.playCardPlace());
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
  void moveDragToFinished(
    DragPayload payload,
    int finishedIndex, {
    Offset? dropOffset,
  }) {
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

    saveCurrentStateToHistory(
      undoTarget: payload.source,
      undoTargetPileIndex: payload.source == PileType.drawingOpenedCards ? null : payload.pileIndex,
      undoCardKeys: [cards.first.revealKey],
    );

    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    final finishedCards = List<List<SolitaireCard>>.from(value.finishedCards);
    final mainCards = List<List<SolitaireCard>>.from(value.mainCards);
    final mainRevealVersions = List<int>.from(value.mainRevealVersions);
    final mainRevealCardKeys = List<String?>.from(value.mainRevealCardKeys);

    final scoreDelta = removeCardsFromSource(
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
      newMoveCounter: value.moveCounter + 1,
      newScore: value.score + scoreForMoveToFoundation + scoreDelta,
      newSelectedCard: null,
      newDropSettleVersion: dropOffset == null ? null : value.dropSettleVersion + 1,
      newDropSettleTarget: dropOffset == null ? noDropSettleTarget : PileType.finishedCards,
      newDropSettlePileIndex: dropOffset == null ? noDropSettlePileIndex : finishedIndex,
      newDropSettleCardKeys: dropOffset == null ? null : [cards.first.revealKey],
      newDropSettleFromOffset: dropOffset ?? noDropSettleFromOffset,
    );

    unawaited(sound.playCardPlace());
  }

  /// Executes a drag-drop move to main cards column (after validation)
  void moveDragToMain(
    DragPayload payload,
    int column, {
    Offset? dropOffset,
  }) {
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

    saveCurrentStateToHistory(
      undoTarget: payload.source,
      undoTargetPileIndex: payload.source == PileType.drawingOpenedCards ? null : payload.pileIndex,
      undoCardKeys: [
        for (final card in cards) card.revealKey,
      ],
    );

    final drawingOpened = List<SolitaireCard>.from(value.drawingOpenedCards);
    final mainCards = List<List<SolitaireCard>>.from(value.mainCards);
    final finishedCards = List<List<SolitaireCard>>.from(value.finishedCards);
    final mainRevealVersions = List<int>.from(value.mainRevealVersions);
    final mainRevealCardKeys = List<String?>.from(value.mainRevealCardKeys);

    final scoreDelta = removeCardsFromSource(
      payload,
      drawingOpenedCards: drawingOpened,
      finishedCards: finishedCards,
      mainCards: mainCards,
      mainRevealVersions: mainRevealVersions,
      mainRevealCardKeys: mainRevealCardKeys,
    );

    final pile = List<SolitaireCard>.from(mainCards[column])..addAll(cards);
    mainCards[column] = pile;

    final moveScore = switch (payload.source) {
      PileType.drawingOpenedCards => scoreForStockToTableau,
      PileType.finishedCards => scoreForFoundationToTableau,
      _ => 0,
    };

    updateState(
      newDrawingOpenedCards: drawingOpened,
      newMainCards: mainCards,
      newFinishedCards: finishedCards,
      newMainRevealVersions: mainRevealVersions,
      newMainRevealCardKeys: mainRevealCardKeys,
      newMoveCounter: value.moveCounter + 1,
      newScore: value.score + moveScore + scoreDelta,
      newSelectedCard: null,
      newDropSettleVersion: dropOffset == null ? null : value.dropSettleVersion + 1,
      newDropSettleTarget: dropOffset == null ? noDropSettleTarget : PileType.mainCards,
      newDropSettlePileIndex: dropOffset == null ? noDropSettlePileIndex : column,
      newDropSettleCardKeys: dropOffset == null ? null : cards.map((card) => card.revealKey).toList(),
      newDropSettleFromOffset: dropOffset ?? noDropSettleFromOffset,
    );

    unawaited(sound.playCardPlace());
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
  int removeSelectedCardAndReveal(
    SelectedCard selectedCard, {
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> mainCards,
    required List<int> mainRevealVersions,
    required List<String?> mainRevealCardKeys,
  }) {
    var scoreDelta = 0;

    switch (selectedCard.source) {
      case PileType.drawingOpenedCards:
        if (drawingOpenedCards.isNotEmpty) {
          drawingOpenedCards.removeLast();
        }
        return scoreDelta;

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
          scoreDelta += scoreForRevealTableauCard;
          unawaited(sound.playCardFlip());
        }

        mainCards[pileIndex] = pile;
        return scoreDelta;

      default:
        return scoreDelta;
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
  int removeCardsFromSource(
    DragPayload payload, {
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> finishedCards,
    required List<List<SolitaireCard>> mainCards,
    required List<int> mainRevealVersions,
    required List<String?> mainRevealCardKeys,
  }) {
    var scoreDelta = 0;

    switch (payload.source) {
      case PileType.drawingOpenedCards:
        if (drawingOpenedCards.isNotEmpty) {
          drawingOpenedCards.removeLast();
        }
        return scoreDelta;

      case PileType.finishedCards:
        if (payload.pileIndex < 0 || payload.pileIndex >= finishedCards.length) {
          return scoreDelta;
        }

        final pileIndex = payload.pileIndex;
        final pile = List<SolitaireCard>.from(finishedCards[pileIndex]);

        if (pile.isNotEmpty) {
          pile.removeLast();
        }

        finishedCards[pileIndex] = pile;
        return scoreDelta;

      case PileType.mainCards:
        if (payload.pileIndex < 0 || payload.pileIndex >= mainCards.length) {
          return scoreDelta;
        }

        final pileIndex = payload.pileIndex;
        final pile = List<SolitaireCard>.from(mainCards[pileIndex]);

        if (pile.isEmpty) {
          return scoreDelta;
        }

        final start = payload.cardIndex < 0 ? pile.length - 1 : payload.cardIndex;

        if (start < 0 || start >= pile.length) {
          return scoreDelta;
        }

        pile.removeRange(start, pile.length);

        if (pile.isNotEmpty && !pile.last.faceUp) {
          pile.last.faceUp = true;
          mainRevealVersions[pileIndex] += 1;
          mainRevealCardKeys[pileIndex] = pile.last.revealKey;
          scoreDelta += scoreForRevealTableauCard;
          unawaited(sound.playCardFlip());
        }

        mainCards[pileIndex] = pile;
        return scoreDelta;

      default:
        return scoreDelta;
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

    final shouldClearSelection = payload != null && value.selectedCard != null;

    updateState(
      newDraggingPayload: payload,
      newSelectedCard: shouldClearSelection ? null : noSelectedCard,
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

  Rect? mainCardRect(
    int column,
    int cardIndex, {
    required bool isWideUi,
  }) {
    final base = rectFromKey(mainColumnKeys[column]);

    if (base == null) {
      return null;
    }

    final cards = value.mainCards[column];
    double topOffset;

    if (cards.isEmpty) {
      topOffset = 0;
    } else if (cardIndex < cards.length) {
      topOffset = mainStackTopOffset(
        cards,
        cardIndex,
        cardWidth: base.width,
        isWideUi: isWideUi,
      );
    } else {
      // For insertion at the end, place after the current top card.
      topOffset =
          mainStackTopOffset(
            cards,
            cards.length - 1,
            cardWidth: base.width,
            isWideUi: isWideUi,
          ) +
          mainStackOffsetForCard(
            cards.last,
            cardWidth: base.width,
            isWideUi: isWideUi,
          );
    }

    final topLeft = base.topLeft + Offset(0, topOffset);

    return Rect.fromLTWH(
      topLeft.dx,
      topLeft.dy,
      base.width,
      base.height,
    );
  }

  /// Restores the latest state-changing action, if one exists
  void undoLastMove({
    PileType? animatedTarget,
    int? animatedPileIndex,
    List<String>? animatedCardKeys,
    Offset? animatedFromOffset,
  }) {
    if (moveHistory.isEmpty) {
      return;
    }

    final snapshot = moveHistory.removeLast();
    final shouldAnimateUndo = animatedTarget != null && animatedCardKeys != null && animatedCardKeys.isNotEmpty && animatedFromOffset != null;

    gameTimerStartedAt = DateTime.now().subtract(
      Duration(
        seconds: snapshot.elapsedSeconds,
      ),
    );

    /// Undo should restore the previous board state without replaying animations.
    updateState(
      newDrawingUnopenedCards: cloneCards(snapshot.drawingUnopenedCards),
      newDrawingOpenedCards: cloneCards(snapshot.drawingOpenedCards),
      newDrawingRevealVersion: snapshot.drawingRevealVersion,
      newDrawingRevealCardKey: snapshot.drawingRevealCardKey,
      newElapsedSeconds: snapshot.elapsedSeconds,
      newMoveCounter: snapshot.moveCounter,
      newScore: snapshot.score + scorePenaltyForUndo,
      newMainCards: cloneCardColumns(snapshot.mainCards),
      newFinishedCards: cloneCardColumns(snapshot.finishedCards),
      newMainRevealVersions: List<int>.from(snapshot.mainRevealVersions),
      newMainRevealCardKeys: List<String?>.from(snapshot.mainRevealCardKeys),
      newSelectedCard: null,
      newDraggingPayload: null,
      newDropSettleVersion: shouldAnimateUndo ? value.dropSettleVersion + 1 : value.dropSettleVersion,
      newDropSettleTarget: shouldAnimateUndo ? animatedTarget : null,
      newDropSettlePileIndex: shouldAnimateUndo ? animatedPileIndex : null,
      newDropSettleCardKeys: shouldAnimateUndo ? List<String>.from(animatedCardKeys) : const [],
      newDropSettleFromOffset: shouldAnimateUndo ? animatedFromOffset : null,
    );
  }

  /// Saves the current state to the history
  void saveCurrentStateToHistory({
    PileType? undoTarget,
    int? undoTargetPileIndex,
    List<String> undoCardKeys = const [],
  }) => moveHistory.add(
    GameHistorySnapshot(
      drawingUnopenedCards: cloneCards(value.drawingUnopenedCards),
      drawingOpenedCards: cloneCards(value.drawingOpenedCards),
      drawingRevealVersion: value.drawingRevealVersion,
      drawingRevealCardKey: value.drawingRevealCardKey,
      elapsedSeconds: value.elapsedSeconds,
      moveCounter: value.moveCounter,
      score: value.score,
      mainCards: cloneCardColumns(value.mainCards),
      finishedCards: cloneCardColumns(value.finishedCards),
      mainRevealVersions: List<int>.from(value.mainRevealVersions),
      mainRevealCardKeys: List<String?>.from(value.mainRevealCardKeys),
      selectedCard: value.selectedCard == null
          ? null
          : SelectedCard(
              source: value.selectedCard!.source,
              pileIndex: value.selectedCard!.pileIndex,
              cardIndex: value.selectedCard!.cardIndex,
            ),
      draggingPayload: value.draggingPayload == null
          ? null
          : DragPayload(
              source: value.draggingPayload!.source,
              pileIndex: value.draggingPayload!.pileIndex,
              cardIndex: value.draggingPayload!.cardIndex,
            ),
      dropSettleVersion: value.dropSettleVersion,
      dropSettleTarget: value.dropSettleTarget,
      dropSettlePileIndex: value.dropSettlePileIndex,
      dropSettleCardKeys: List<String>.from(value.dropSettleCardKeys),
      dropSettleFromOffset: value.dropSettleFromOffset,
      undoTarget: undoTarget,
      undoTargetPileIndex: undoTargetPileIndex,
      undoCardKeys: List<String>.from(undoCardKeys),
    ),
  );

  List<SolitaireCard> cloneCards(List<SolitaireCard> cards) => [
    for (final card in cards)
      SolitaireCard(
        suit: card.suit,
        rank: card.rank,
        faceUp: card.faceUp,
      ),
  ];

  List<List<SolitaireCard>> cloneCardColumns(List<List<SolitaireCard>> columns) => [
    for (final column in columns) cloneCards(column),
  ];

  bool canHintFromState({
    required List<SolitaireCard> drawingUnopenedCards,
    required List<SolitaireCard> drawingOpenedCards,
    required List<List<SolitaireCard>> mainCards,
    required List<List<SolitaireCard>> finishedCards,
  }) {
    if (hintSelectionFromState(
          drawingOpenedCards: drawingOpenedCards,
          mainCards: mainCards,
          finishedCards: finishedCards,
        ) !=
        null) {
      return true;
    }

    return drawingUnopenedCards.isNotEmpty || drawingOpenedCards.isNotEmpty;
  }

  /// Updates `state` with any passed value
  void updateState({
    bool? newCanHint,
    bool? newCanUndo,
    List<SolitaireCard>? newDrawingUnopenedCards,
    List<SolitaireCard>? newDrawingOpenedCards,
    int? newDrawingRevealVersion,
    Object? newDrawingRevealCardKey = noDrawingRevealCardKey,
    int? newElapsedSeconds,
    int? newMoveCounter,
    int? newScore,
    List<List<SolitaireCard>>? newMainCards,
    List<List<SolitaireCard>>? newFinishedCards,
    List<int>? newMainRevealVersions,
    List<String?>? newMainRevealCardKeys,
    Object? newSelectedCard = noSelectedCard,
    Object? newDraggingPayload = noDraggingPayload,
    int? newDropSettleVersion,
    Object? newDropSettleTarget = noDropSettleTarget,
    Object? newDropSettlePileIndex = noDropSettlePileIndex,
    List<String>? newDropSettleCardKeys,
    Object? newDropSettleFromOffset = noDropSettleFromOffset,
  }) {
    final drawingUnopenedCards = newDrawingUnopenedCards ?? value.drawingUnopenedCards;
    final drawingOpenedCards = newDrawingOpenedCards ?? value.drawingOpenedCards;
    final elapsedSeconds = newElapsedSeconds ?? value.elapsedSeconds;
    final moveCounter = newMoveCounter ?? value.moveCounter;
    final score = newScore ?? value.score;
    final mainCards = newMainCards ?? value.mainCards;
    final finishedCards = newFinishedCards ?? value.finishedCards;

    value = (
      canHint:
          newCanHint ??
          canHintFromState(
            drawingUnopenedCards: drawingUnopenedCards,
            drawingOpenedCards: drawingOpenedCards,
            mainCards: mainCards,
            finishedCards: finishedCards,
          ),
      canUndo: newCanUndo ?? moveHistory.isNotEmpty,
      drawingUnopenedCards: drawingUnopenedCards,
      drawingOpenedCards: drawingOpenedCards,
      drawingRevealVersion: newDrawingRevealVersion ?? value.drawingRevealVersion,
      drawingRevealCardKey: newDrawingRevealCardKey == noDrawingRevealCardKey ? value.drawingRevealCardKey : newDrawingRevealCardKey as String?,
      elapsedSeconds: elapsedSeconds,
      moveCounter: moveCounter,
      score: score,
      mainCards: mainCards,
      finishedCards: finishedCards,
      mainRevealVersions: newMainRevealVersions ?? value.mainRevealVersions,
      mainRevealCardKeys: newMainRevealCardKeys ?? value.mainRevealCardKeys,
      selectedCard: newSelectedCard == noSelectedCard ? value.selectedCard : newSelectedCard as SelectedCard?,
      draggingPayload: newDraggingPayload == noDraggingPayload ? value.draggingPayload : newDraggingPayload as DragPayload?,
      dropSettleVersion: newDropSettleVersion ?? value.dropSettleVersion,
      dropSettleTarget: newDropSettleTarget == noDropSettleTarget ? value.dropSettleTarget : newDropSettleTarget as PileType?,
      dropSettlePileIndex: newDropSettlePileIndex == noDropSettlePileIndex ? value.dropSettlePileIndex : newDropSettlePileIndex as int?,
      dropSettleCardKeys: newDropSettleCardKeys ?? value.dropSettleCardKeys,
      dropSettleFromOffset: newDropSettleFromOffset == noDropSettleFromOffset ? value.dropSettleFromOffset : newDropSettleFromOffset as Offset?,
    );
  }
}
