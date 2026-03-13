import 'package:flutter/material.dart';

import '../../constants/durations.dart';

class MainController {
  final Function() onNewGame;
  final Function() onResetGame;
  final Function() onUndo;

  MainController({
    required this.onNewGame,
    required this.onResetGame,
    required this.onUndo,
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

    onNewGame();
  }

  /// Triggered when the user presses `Reset game` button
  Future<void> resetGamePressed(BuildContext context) async {
    final shouldResetGame =
        await showDialog<bool>(
          context: context,
          animationStyle: const AnimationStyle(
            duration: SolitaireDurations.animation,
            curve: Curves.easeIn,
          ),
          builder: (context) => AlertDialog(
            title: const Text('Reset this game?'),
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

    if (!shouldResetGame) {
      return;
    }

    onResetGame();
  }

  /// Triggered when the user presses `Undo` button
  void undoPressed() {
    onUndo();
  }
}
