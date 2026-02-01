import 'dart:math' as math;

import '../constants/constants.dart';

double getCardWidth({
  required double shortestAvailableSide,
  required double padding,
  required double cardAspectRatio,
}) {
  final widthLimitMain = shortestAvailableSide > padding * 6
      ? (shortestAvailableSide - padding * 6) / 7
      : 0.0;
  final widthLimitTop = shortestAvailableSide > padding * 5
      ? (shortestAvailableSide - padding * 5) / 6
      : 0.0;

  final baseWidth = math
      .max(
        0,
        math.min(widthLimitMain, widthLimitTop),
      )
      .toDouble();

  return baseWidth;
}

double mainStackHeightMultiplier({required double cardHeight}) {
  if (cardHeight <= 0) {
    return 0;
  }

  const maxStackOffset = (maxMainStackCards - 1) * mainStackOffset;

  return (cardHeight + maxStackOffset) / cardHeight;
}
