class SolitaireConstants {
  static const compactLayoutMaxWidth = 560;

  static const cardAspectRatio = 1.65;

  static const padding = 8.0;
  static const borderRadius = 4.0;
  static const borderWidth = 1.5;

  static const blurRadius = 24.0;

  ///
  /// SCORES
  ///

  static const scoreForStockToTableau = 5;
  static const scoreForMoveToFoundation = 10;
  static const scoreForRevealTableauCard = 5;

  static const scoreForFoundationToTableau = 0;
  static const scorePenaltyForHint = 0;
  static const scorePenaltyForUndo = 0;

  ///
  /// OFFSETS
  ///

  static const maxVisibleCardsForDrawThree = 3;
  static const visibleCardOffsetFactor = 0.35;

  static const mainStackOffsetFactorPortrait = 0.45;
  static const mainStackOffsetFactorLandscape = 0.35;

  static const mainStackFaceDownOffsetFactor = 0.225;

  static const maxMainStackCards = 13;

  static double mainStackOffsetFactor({
    required bool isWideUi,
  }) => isWideUi ? mainStackOffsetFactorLandscape : mainStackOffsetFactorPortrait;
}
