import '../cards/solitaire_card.dart';

class GamePersistenceSnapshot {
  final List<SolitaireCard> drawingUnopenedCards;
  final List<SolitaireCard> drawingOpenedCards;
  final int drawingRevealVersion;
  final String? drawingRevealCardKey;
  final int elapsedSeconds;
  final int moveCounter;
  final int score;
  final List<List<SolitaireCard>> mainCards;
  final List<List<SolitaireCard>> finishedCards;
  final List<int> mainRevealVersions;
  final List<String?> mainRevealCardKeys;
  final List<SolitaireCard> initialDrawingUnopenedCards;
  final List<List<SolitaireCard>> initialMainCards;

  const GamePersistenceSnapshot({
    required this.drawingUnopenedCards,
    required this.drawingOpenedCards,
    required this.drawingRevealVersion,
    required this.drawingRevealCardKey,
    required this.elapsedSeconds,
    required this.moveCounter,
    required this.score,
    required this.mainCards,
    required this.finishedCards,
    required this.mainRevealVersions,
    required this.mainRevealCardKeys,
    required this.initialDrawingUnopenedCards,
    required this.initialMainCards,
  });
}
