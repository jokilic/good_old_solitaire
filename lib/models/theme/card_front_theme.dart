import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 7)
enum CardFrontTheme {
  @HiveField(0)
  classic,
  @HiveField(1)
  modern,
}
