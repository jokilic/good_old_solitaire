import '../constants/constants.dart';

double mainStackOffsetFromCardWidth(double cardWidth) => cardWidth * SolitaireConstants.mainStackOffsetFactor;

double mainStackFaceDownOffsetFromCardWidth(double cardWidth) => cardWidth * SolitaireConstants.mainStackFaceDownOffsetFactor;

double mainStackHeightMultiplier({
  required double cardHeight,
  required double cardWidth,
}) {
  if (cardHeight <= 0) {
    return 0;
  }

  final maxStackOffset = (SolitaireConstants.maxMainStackCards - 1) * mainStackOffsetFromCardWidth(cardWidth);

  return (cardHeight + maxStackOffset) / cardHeight;
}
