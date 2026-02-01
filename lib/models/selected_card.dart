import '../constants/enums.dart';

class SelectedCard {
  final PileType source;
  final int pileIndex;

  const SelectedCard({
    required this.source,
    required this.pileIndex,
  });
}
