import 'dart:ui';

import '../constants/enums.dart';
import 'drag_payload.dart';
import 'selected_card.dart';
import 'solitaire_card.dart';

class GameHistorySnapshot {
  final List<SolitaireCard> drawingUnopenedCards;
  final List<SolitaireCard> drawingOpenedCards;
  final int drawingRevealVersion;
  final String? drawingRevealCardKey;
  final int elapsedSeconds;
  final int moveCounter;
  final List<List<SolitaireCard>> mainCards;
  final List<List<SolitaireCard>> finishedCards;
  final List<int> mainRevealVersions;
  final List<String?> mainRevealCardKeys;
  final SelectedCard? selectedCard;
  final DragPayload? draggingPayload;
  final int dropSettleVersion;
  final PileType? dropSettleTarget;
  final int? dropSettlePileIndex;
  final List<String> dropSettleCardKeys;
  final Offset? dropSettleFromOffset;
  final PileType? undoTarget;
  final int? undoTargetPileIndex;
  final List<String> undoCardKeys;

  const GameHistorySnapshot({
    required this.drawingUnopenedCards,
    required this.drawingOpenedCards,
    required this.drawingRevealVersion,
    required this.drawingRevealCardKey,
    required this.elapsedSeconds,
    required this.moveCounter,
    required this.mainCards,
    required this.finishedCards,
    required this.mainRevealVersions,
    required this.mainRevealCardKeys,
    required this.selectedCard,
    required this.draggingPayload,
    required this.dropSettleVersion,
    required this.dropSettleTarget,
    required this.dropSettlePileIndex,
    required this.dropSettleCardKeys,
    required this.dropSettleFromOffset,
    required this.undoTarget,
    required this.undoTargetPileIndex,
    required this.undoCardKeys,
  });
}
