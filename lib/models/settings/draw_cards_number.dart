import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 2)
enum DrawCardsNumber {
  @HiveField(0)
  one,
  @HiveField(1)
  three,
}
