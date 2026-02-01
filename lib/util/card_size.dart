import 'dart:math' as math;

double getCardWidth({
  required bool isLandscape,
  required double availableWidth,
  required double availableHeight,
  required double padding,
  required double cardAspectRatio,
}) {
  if (isLandscape) {
    final widthLimit = availableWidth > padding * 2 ? (availableWidth - padding * 2) / 9 : 0.0;
    final heightLimit = availableHeight / (10 * cardAspectRatio);

    return math.max(
      0,
      math.min(
        widthLimit,
        heightLimit,
      ),
    );
  }

  final widthLimitMain = availableWidth / 7;
  final widthLimitTop = availableWidth > padding * 5 ? (availableWidth - padding * 5) / 6 : 0.0;
  final heightLimit = availableHeight > padding ? (availableHeight - padding) / (11 * cardAspectRatio) : 0.0;

  return math.max(
    0,
    math.min(
      widthLimitMain,
      math.min(
        widthLimitTop,
        heightLimit,
      ),
    ),
  );
}
