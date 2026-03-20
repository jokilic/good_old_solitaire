import 'package:hive_ce/hive_ce.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'suit.dart';

@HiveType(typeId: 9)
class SolitaireCard {
  @HiveField(1)
  final Suit suit;
  @HiveField(2)
  final int rank; // Between 1 and 13
  @HiveField(3)
  bool faceUp;

  SolitaireCard({
    required this.suit,
    required this.rank,
    required this.faceUp,
  });

  bool get isRed => suit == Suit.diamonds || suit == Suit.hearts;
  String get revealKey => '${suit.name}-$rank';

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
