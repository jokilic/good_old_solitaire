import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 8)
enum Suit {
  @HiveField(1)
  clubs,
  @HiveField(2)
  diamonds,
  @HiveField(3)
  hearts,
  @HiveField(4)
  spades,
}
