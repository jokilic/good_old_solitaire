import '../constants/enums.dart';

class SelectedCard {
  final PileType source;
  final int pileIndex;
  final int cardIndex;

  const SelectedCard({
    required this.source,
    required this.pileIndex,
    this.cardIndex = -1,
  });
}
