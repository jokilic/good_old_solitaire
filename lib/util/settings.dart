import '../models/settings/animation_speed.dart';
import '../models/settings/draw_cards_number.dart';
import '../models/settings/draw_cards_position.dart';

String getDrawCardsPositionText(DrawCardsPosition position) => switch (position) {
  DrawCardsPosition.left => 'Left',
  DrawCardsPosition.right => 'Right',
};

String getDrawCardsNumberText(DrawCardsNumber number) => switch (number) {
  DrawCardsNumber.one => '1',
  DrawCardsNumber.three => '3',
};

String getAnimationSpeedText(AnimationSpeed speed) => switch (speed) {
  AnimationSpeed.normal => 'Normal',
  AnimationSpeed.fast => 'Fast',
};
