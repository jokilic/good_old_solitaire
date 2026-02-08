import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/durations.dart';

class MainButtonsNewReset extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      ///
      /// NEW GAME
      ///
      IconButton.filled(
        onPressed: () {},
        style: IconButton.styleFrom(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(22, 20, 20, 20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(100),
              right: Radius.circular(16),
            ),
          ),
          elevation: 0,
          iconSize: 24,
          animationDuration: SolitaireDurations.animationLong,
          highlightColor: Colors.green,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.yellow,
          disabledForegroundColor: Colors.blue,
        ),
        icon: PhosphorIcon(
          PhosphorIcons.plus(
            PhosphorIconsStyle.bold,
          ),
        ),
      ),

      const SizedBox(width: 8),

      ///
      /// RESET GAME
      ///
      IconButton.filled(
        onPressed: () {},
        style: IconButton.styleFrom(
          alignment: Alignment.center,
          padding: const EdgeInsets.fromLTRB(20, 20, 22, 20),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.horizontal(
              left: Radius.circular(16),
              right: Radius.circular(100),
            ),
          ),
          elevation: 0,
          iconSize: 24,
          animationDuration: SolitaireDurations.animationLong,
          highlightColor: Colors.green,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.yellow,
          disabledForegroundColor: Colors.blue,
        ),
        icon: PhosphorIcon(
          PhosphorIcons.arrowCounterClockwise(
            PhosphorIconsStyle.bold,
          ),
        ),
      ),
    ],
  );
}
