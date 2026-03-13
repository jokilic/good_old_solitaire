import 'dart:ui';

import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../constants/colors.dart';
import '../../../constants/constants.dart';
import '../../../util/time.dart';
import 'game/game_controller.dart';

class MainTopInfo extends WatchingWidget {
  final String instanceId;

  const MainTopInfo({
    required this.instanceId,
  });

  @override
  Widget build(BuildContext context) {
    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;
    final buttonSpacing = isWideUi ? 16 : 8;

    final moveCounter = watchPropertyValue<GameController, int>(
      (x) => x.value.moveCounter,
      instanceName: instanceId,
    );
    final elapsedSeconds = watchPropertyValue<GameController, int>(
      (x) => x.value.elapsedSeconds,
      instanceName: instanceId,
    );
    final score = watchPropertyValue<GameController, int>(
      (x) => x.value.score,
      instanceName: instanceId,
    );

    final formattedMoveCounter = moveCounter.toString().padLeft(2, '0');
    final formattedScore = score.toString().padLeft(2, '0');

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: SolitaireConstants.blurRadius,
            sigmaY: SolitaireConstants.blurRadius,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isWideUi ? 24 : 16,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white12,
                width: SolitaireConstants.borderWidth,
              ),
              color: Colors.white12,
            ),
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              spacing: buttonSpacing.toDouble(),
              children: [
                ///
                /// SCORE
                ///
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BorderedText(
                        strokeColor: Colors.black87,
                        strokeWidth: isWideUi ? 4 : 2,
                        child: Text(
                          'Score',
                          style: TextStyle(
                            fontSize: isWideUi ? 12 : 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      BorderedText(
                        strokeColor: Colors.black87,
                        strokeWidth: isWideUi ? 6 : 4,
                        child: Text(
                          formattedScore,
                          style: TextStyle(
                            fontSize: isWideUi ? 36 : 28,
                            fontWeight: FontWeight.bold,
                            color: SolitaireColors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ///
                /// TIME & MOVES
                ///
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ///
                      /// TIME
                      ///
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BorderedText(
                            strokeColor: Colors.black87,
                            strokeWidth: isWideUi ? 4 : 2,
                            child: Text(
                              'Time',
                              style: TextStyle(
                                fontSize: isWideUi ? 12 : 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          BorderedText(
                            strokeColor: Colors.black87,
                            strokeWidth: isWideUi ? 6 : 4,
                            child: Text(
                              formatElapsedTime(elapsedSeconds),
                              style: TextStyle(
                                fontSize: isWideUi ? 36 : 28,
                                fontWeight: FontWeight.bold,
                                color: SolitaireColors.purple,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: isWideUi ? 40 : 24),

                      ///
                      /// MOVES
                      ///
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BorderedText(
                            strokeColor: Colors.black87,
                            strokeWidth: isWideUi ? 4 : 2,
                            child: Text(
                              'Moves',
                              style: TextStyle(
                                fontSize: isWideUi ? 12 : 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          BorderedText(
                            strokeColor: Colors.black87,
                            strokeWidth: isWideUi ? 6 : 4,
                            child: Text(
                              formattedMoveCounter,
                              style: TextStyle(
                                fontSize: isWideUi ? 36 : 28,
                                fontWeight: FontWeight.bold,
                                color: SolitaireColors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
