import 'package:flutter/material.dart';

import 'screens/game/game_screen.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: GameScreen(
      key: ValueKey('game'),
    ),
  );
}
