import '../constants/enums.dart';

class DragPayload {
  final PileType source;
  final int pileIndex;
  final int cardIndex;

  const DragPayload({
    required this.source,
    required this.pileIndex,
    this.cardIndex = -1,
  });
}
