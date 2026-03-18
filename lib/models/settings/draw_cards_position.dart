import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 1)
enum DrawCardsPosition {
  @HiveField(0)
  left,
  @HiveField(1)
  right,
}
