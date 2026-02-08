import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../constants/constants.dart';
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
        padding: const EdgeInsets.symmetric(horizontal: SolitaireConstants.padding),
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
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '$moveCounter',
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
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const Text(
                  '00:12',
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
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '$moveCounter',
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
