import 'package:hive_ce/hive_ce.dart';

import '../cards/solitaire_card.dart';

@HiveType(typeId: 10)
class GamePersistenceSnapshot {
  @HiveField(1)
  final List<SolitaireCard> drawingUnopenedCards;
  @HiveField(2)
  final List<SolitaireCard> drawingOpenedCards;
  @HiveField(3)
  final int drawingRevealVersion;
  @HiveField(4)
  final String? drawingRevealCardKey;
  @HiveField(5)
  final int elapsedSeconds;
  @HiveField(6)
  final int moveCounter;
  @HiveField(7)
  final int score;
  @HiveField(8)
  final List<List<SolitaireCard>> mainCards;
  @HiveField(9)
  final List<List<SolitaireCard>> finishedCards;
  @HiveField(10)
  final List<int> mainRevealVersions;
  @HiveField(11)
  final List<String?> mainRevealCardKeys;
  @HiveField(12)
  final List<SolitaireCard> initialDrawingUnopenedCards;
  @HiveField(13)
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
