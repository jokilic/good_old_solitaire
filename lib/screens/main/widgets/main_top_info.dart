import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import 'game/game_controller.dart';

class MainTopInfo extends WatchingWidget {
  final String instanceId;

  const MainTopInfo({
    required this.instanceId,
  });

  @override
  Widget build(BuildContext context) {
    final gameState = watchIt<GameController>(
      instanceName: instanceId,
    ).value;

    final moveCounter = gameState.moveCounter;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Row(
          children: [
            ///
            /// SCORE
            ///
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Score'.toUpperCase(),
                  // TODO
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white12,
                  ),
                ),
                Text(
                  '--',
                  // TODO
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const Spacer(),

            ///
            /// TIME
            ///
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Time'.toUpperCase(),
                  // TODO
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white12,
                  ),
                ),
                const Text(
                  '--:--',
                  // TODO
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 24),

            ///
            /// MOVES
            ///
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Moves'.toUpperCase(),
                  // TODO
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white12,
                  ),
                ),
                Text(
                  '$moveCounter',
                  // TODO
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
