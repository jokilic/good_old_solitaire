import '../models/solitaire_card.dart';
import 'card_size.dart';

double mainStackOffsetForCard(
  SolitaireCard card, {
  required double cardWidth,
}) => card.faceUp ? mainStackOffsetFromCardWidth(cardWidth) : mainStackFaceDownOffsetFromCardWidth(cardWidth);

double mainStackTopOffset(
  List<SolitaireCard> cards,
  int index, {
  required double cardWidth,
}) {
  var top = 0.0;

  for (var i = 1; i <= index && i < cards.length; i += 1) {
    top += mainStackOffsetForCard(
      cards[i - 1],
      cardWidth: cardWidth,
    );
  }

  return top;
}

double mainStackTotalOffset(
  List<SolitaireCard> cards, {
  required double cardWidth,
}) {
  var total = 0.0;

  for (var i = 1; i < cards.length; i += 1) {
    total += mainStackOffsetForCard(
      cards[i - 1],
      cardWidth: cardWidth,
    );
  }

  return total;
}
