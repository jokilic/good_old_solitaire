import 'package:hive_ce/hive_ce.dart';

@HiveType(typeId: 3)
enum AnimationSpeed {
  @HiveField(0)
  slow,
  @HiveField(1)
  normal,
  @HiveField(2)
  fast,
}
