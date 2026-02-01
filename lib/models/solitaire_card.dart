import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/enums.dart';

class SolitaireCard {
  final Suit suit;
  final int rank; // Between 1 and 13
  bool faceUp;

  SolitaireCard({
    required this.suit,
    required this.rank,
    required this.faceUp,
  });

  bool get isRed => suit == Suit.diamonds || suit == Suit.hearts;

  String get cardLabel => switch (rank) {
    1 => 'A',
    11 => 'J',
    12 => 'Q',
    13 => 'K',
    _ => '$rank',
  };

  PhosphorIconData get suitIcon => switch (suit) {
    Suit.clubs => PhosphorIcons.club(
      PhosphorIconsStyle.fill,
    ),
    Suit.diamonds => PhosphorIcons.diamond(
      PhosphorIconsStyle.fill,
    ),
    Suit.hearts => PhosphorIcons.heart(
      PhosphorIconsStyle.fill,
    ),
    Suit.spades => PhosphorIcons.spade(
      PhosphorIconsStyle.fill,
    ),
  };
}
