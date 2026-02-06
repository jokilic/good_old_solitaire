enum Suit {
  clubs,
  diamonds,
  hearts,
  spades,
}

enum PileType {
  /// Main cards section
  mainCards,

  /// Drawing cards unopened section
  drawingUnopenedCards,

  /// Drawing cards opened section
  drawingOpenedCards,

  /// Finished cards section
  finishedCards,
}

enum GameSound {
  cardLift,
  cardPlace,
  cardFlip,
  cardDraw,
  drawPileExhausted,
  drawPileReset,
  shuffle,
}
