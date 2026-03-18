import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 6)
enum CardBackTheme {
  @HiveField(0)
  blue,
  @HiveField(1)
  red,
}
