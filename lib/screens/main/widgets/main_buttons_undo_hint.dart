import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/durations.dart';

class MainButtonsUndoHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      ///
      /// UNDO
      ///
      TextButton.icon(
        onPressed: () {},
        style: TextButton.styleFrom(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          iconSize: 24,
          animationDuration: SolitaireDurations.animationLong,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.yellow,
          disabledForegroundColor: Colors.blue,
        ),
        label: const Text('Undo'),
        icon: PhosphorIcon(
          PhosphorIcons.eraser(
            PhosphorIconsStyle.bold,
          ),
        ),
      ),

      const SizedBox(width: 8),

      ///
      /// HINT
      ///
      TextButton.icon(
        onPressed: () {},
        style: TextButton.styleFrom(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          iconSize: 24,
          animationDuration: SolitaireDurations.animationLong,
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.yellow,
          disabledForegroundColor: Colors.blue,
        ),
        label: const Text('Hint'),
        icon: PhosphorIcon(
          PhosphorIcons.questionMark(
            PhosphorIconsStyle.bold,
          ),
        ),
      ),
    ],
  );
}
