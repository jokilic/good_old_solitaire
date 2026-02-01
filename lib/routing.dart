import 'package:flutter/material.dart';

import 'screens/game/game_screen.dart';
import 'util/navigation.dart';

/// Opens [GameScreen]
void openGame(
  BuildContext context, {
  required String instanceId,
}) => pushScreen(
  GameScreen(
    instanceId: instanceId,
    key: ValueKey(instanceId),
  ),
  context: context,
);
