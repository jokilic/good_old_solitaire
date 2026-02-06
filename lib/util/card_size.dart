import '../constants/constants.dart';

double mainStackOffsetFromCardWidth(
  double cardWidth, {
  required bool isWideUi,
}) => cardWidth * SolitaireConstants.mainStackOffsetFactor(isWideUi: isWideUi);

double mainStackFaceDownOffsetFromCardWidth(double cardWidth) => cardWidth * SolitaireConstants.mainStackFaceDownOffsetFactor;

double mainStackHeightMultiplier({
  required double cardHeight,
  required double cardWidth,
  required bool isWideUi,
}) {
  if (cardHeight <= 0) {
    return 0;
  }

  final maxStackOffset =
      (SolitaireConstants.maxMainStackCards - 1) *
      mainStackOffsetFromCardWidth(
        cardWidth,
        isWideUi: isWideUi,
      );

  return (cardHeight + maxStackOffset) / cardHeight;
}
