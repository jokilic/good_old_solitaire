import '../constants/constants.dart';
import '../models/solitaire_card.dart';

double mainStackOffsetForCard(SolitaireCard card) => card.faceUp ? mainStackOffset : mainStackFaceDownOffset;

double mainStackTopOffset(List<SolitaireCard> cards, int index) {
  var top = 0.0;

  for (var i = 1; i <= index && i < cards.length; i += 1) {
    top += mainStackOffsetForCard(cards[i - 1]);
  }

  return top;
}

double mainStackTotalOffset(List<SolitaireCard> cards) {
  var total = 0.0;

  for (var i = 1; i < cards.length; i += 1) {
    total += mainStackOffsetForCard(cards[i - 1]);
  }

  return total;
}
