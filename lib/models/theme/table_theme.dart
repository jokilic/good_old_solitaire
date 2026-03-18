import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 5)
enum TableTheme {
  @HiveField(0)
  green,
  @HiveField(1)
  blue,
}
