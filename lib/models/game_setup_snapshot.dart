import 'solitaire_card.dart';

class GameSetupSnapshot {
  final List<SolitaireCard> drawingUnopenedCards;
  final List<List<SolitaireCard>> mainCards;

  const GameSetupSnapshot({
    required this.drawingUnopenedCards,
    required this.mainCards,
  });
}
