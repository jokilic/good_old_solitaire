import 'package:hive_ce/hive_ce.dart';

import 'animation_speed.dart';
import 'draw_cards_number.dart';
import 'draw_cards_position.dart';

@HiveType(typeId: 0)
class SolitaireSettings {
  @HiveField(1)
  final DrawCardsPosition drawCardPosition;

  @HiveField(2)
  final DrawCardsNumber drawCardsNumber;

  @HiveField(3)
  final AnimationSpeed animationSpeed;

  @HiveField(4)
  final double soundVolume;

  SolitaireSettings({
    required this.drawCardPosition,
    required this.drawCardsNumber,
    required this.animationSpeed,
    required this.soundVolume,
  });

  SolitaireSettings copyWith({
    DrawCardsPosition? drawCardPosition,
    DrawCardsNumber? drawCardsNumber,
    AnimationSpeed? animationSpeed,
    double? soundVolume,
  }) => SolitaireSettings(
    drawCardPosition: drawCardPosition ?? this.drawCardPosition,
    drawCardsNumber: drawCardsNumber ?? this.drawCardsNumber,
    animationSpeed: animationSpeed ?? this.animationSpeed,
    soundVolume: soundVolume ?? this.soundVolume,
  );

  @override
  String toString() => 'SolitaireSettings(drawCardPosition: $drawCardPosition, drawCardsNumber: $drawCardsNumber, animationSpeed: $animationSpeed, soundVolume: $soundVolume)';

  @override
  bool operator ==(covariant SolitaireSettings other) {
    if (identical(this, other)) {
      return true;
    }

    return other.drawCardPosition == drawCardPosition && other.drawCardsNumber == drawCardsNumber && other.animationSpeed == animationSpeed && other.soundVolume == soundVolume;
  }

  @override
  int get hashCode => drawCardPosition.hashCode ^ drawCardsNumber.hashCode ^ animationSpeed.hashCode ^ soundVolume.hashCode;
}
