class SolitaireDurations {
  static const animation = Duration(milliseconds: 100);
  static const animationLong = Duration(milliseconds: 200);

  static const Duration initialDealStaggerDuration = Duration(milliseconds: 50);
  static const Duration initialDealMoveDuration = Duration(milliseconds: 500);
  static const int initialDealCardCount = 28;

  static Duration get initialDealTotalDuration {
    final totalDelayMs = (initialDealCardCount - 1) * initialDealStaggerDuration.inMilliseconds;
    return Duration(
      milliseconds: totalDelayMs + initialDealMoveDuration.inMilliseconds,
    );
  }
}
