import '../constants/constants.dart';

double mainStackHeightMultiplier({required double cardHeight}) {
  if (cardHeight <= 0) {
    return 0;
  }

  const maxStackOffset = (maxMainStackCards - 1) * mainStackOffset;

  return (cardHeight + maxStackOffset) / cardHeight;
}
