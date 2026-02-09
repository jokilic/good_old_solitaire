import 'package:flutter/material.dart';

import '../../constants/durations.dart';

class MainController {
  final Function() onRestartGame;

  MainController({
    required this.onRestartGame,
  });

  ///
  /// METHODS
  ///

  /// Triggered when the user presses `New game` button
  Future<void> newGamePressed(BuildContext context) async {
    final shouldStartNewGame =
        await showDialog<bool>(
          context: context,
          animationStyle: const AnimationStyle(
            duration: SolitaireDurations.animation,
            curve: Curves.easeIn,
          ),
          builder: (context) => AlertDialog(
            title: const Text('Start new game?'),
            content: const Text('Current game progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldStartNewGame) {
      return;
    }

    onRestartGame();
  }
}
