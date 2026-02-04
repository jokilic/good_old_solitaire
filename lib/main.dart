import 'package:flutter/material.dart';

import 'screens/game/game_screen.dart';
import 'util/dependencies.dart';

Future<void> main() async {
  await initializeServices();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: GameScreen(
      instanceId: 'game',
      key: ValueKey('game'),
    ),
  );
}
