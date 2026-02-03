import '../constants/constants.dart';

double mainStackOffsetFromCardWidth(double cardWidth) => cardWidth * mainStackOffsetFactor;

double mainStackFaceDownOffsetFromCardWidth(double cardWidth) => cardWidth * mainStackFaceDownOffsetFactor;

double mainStackHeightMultiplier({
  required double cardHeight,
  required double cardWidth,
}) {
  if (cardHeight <= 0) {
    return 0;
  }

  final maxStackOffset = (maxMainStackCards - 1) * mainStackOffsetFromCardWidth(cardWidth);

  return (cardHeight + maxStackOffset) / cardHeight;
}
