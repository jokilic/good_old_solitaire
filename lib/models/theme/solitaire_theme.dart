import 'package:hive_ce/hive_ce.dart';

import 'card_back_theme.dart';
import 'card_front_theme.dart';
import 'table_theme.dart';

@HiveType(typeId: 4)
class SolitaireTheme {
  @HiveField(1)
  final TableTheme tableTheme;

  @HiveField(2)
  final CardBackTheme cardBackTheme;

  @HiveField(3)
  final CardFrontTheme cardFrontTheme;

  SolitaireTheme({
    required this.tableTheme,
    required this.cardBackTheme,
    required this.cardFrontTheme,
  });

  SolitaireTheme copyWith({
    TableTheme? tableTheme,
    CardBackTheme? cardBackTheme,
    CardFrontTheme? cardFrontTheme,
  }) => SolitaireTheme(
    tableTheme: tableTheme ?? this.tableTheme,
    cardBackTheme: cardBackTheme ?? this.cardBackTheme,
    cardFrontTheme: cardFrontTheme ?? this.cardFrontTheme,
  );

  @override
  String toString() => 'SolitaireTheme(tableTheme: $tableTheme, cardBackTheme: $cardBackTheme, cardFrontTheme: $cardFrontTheme)';

  @override
  bool operator ==(covariant SolitaireTheme other) {
    if (identical(this, other)) {
      return true;
    }

    return other.tableTheme == tableTheme && other.cardBackTheme == cardBackTheme && other.cardFrontTheme == cardFrontTheme;
  }

  @override
  int get hashCode => tableTheme.hashCode ^ cardBackTheme.hashCode ^ cardFrontTheme.hashCode;
}
