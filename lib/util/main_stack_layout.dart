import '../models/solitaire_card.dart';
import 'card_size.dart';

double mainStackOffsetForCard(
  SolitaireCard card, {
  required double cardWidth,
  required bool isWideUi,
}) =>
    card.faceUp
        ? mainStackOffsetFromCardWidth(
            cardWidth,
            isWideUi: isWideUi,
          )
        : mainStackFaceDownOffsetFromCardWidth(cardWidth);

double mainStackTopOffset(
  List<SolitaireCard> cards,
  int index, {
  required double cardWidth,
  required bool isWideUi,
}) {
  var top = 0.0;

  for (var i = 1; i <= index && i < cards.length; i += 1) {
    top += mainStackOffsetForCard(
      cards[i - 1],
      cardWidth: cardWidth,
      isWideUi: isWideUi,
    );
  }

  return top;
}

double mainStackTotalOffset(
  List<SolitaireCard> cards, {
  required double cardWidth,
  required bool isWideUi,
}) {
  var total = 0.0;

  for (var i = 1; i < cards.length; i += 1) {
    total += mainStackOffsetForCard(
      cards[i - 1],
      cardWidth: cardWidth,
      isWideUi: isWideUi,
    );
  }

  return total;
}
