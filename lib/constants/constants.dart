class SolitaireConstants {
  static const compactLayoutMaxWidth = 560;

  static const cardAspectRatio = 1.65;

  static const padding = 8.0;
  static const borderRadius = 5.0;
  static const borderWidth = 0.0;

  static const mainStackOffsetFactorPortrait = 0.45;
  static const mainStackOffsetFactorLandscape = 0.225;
  static const mainStackFaceDownOffsetFactor = 0.225;

  static const maxMainStackCards = 13;

  static double mainStackOffsetFactor({
    required bool isWideUi,
  }) => isWideUi ? mainStackOffsetFactorLandscape : mainStackOffsetFactorPortrait;
}
