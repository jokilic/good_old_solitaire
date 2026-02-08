import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../constants/durations.dart';

class MainBottomButtons extends StatelessWidget {
  final String instanceId;

  const MainBottomButtons({
    required this.instanceId,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      constraints: const BoxConstraints(maxWidth: 800),
      padding: const EdgeInsets.symmetric(horizontal: SolitaireConstants.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ///
          /// NEW GAME
          ///
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 28,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
              iconSize: 20,
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

          const SizedBox(width: 6),

          ///
          /// RESET GAME
          ///
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 28,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
              iconSize: 20,
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

          const SizedBox(width: 6),

          ///
          /// UNDO
          ///
          TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 34,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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

          const SizedBox(width: 6),

          ///
          /// HINT
          ///
          TextButton.icon(
            onPressed: () {},
            style: TextButton.styleFrom(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 34,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
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
              PhosphorIcons.lifebuoy(
                PhosphorIconsStyle.bold,
              ),
            ),
          ),

          const SizedBox(width: 6),

          ///
          /// THEME
          ///
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 28,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
              iconSize: 20,
              animationDuration: SolitaireDurations.animationLong,
              highlightColor: Colors.green,
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.yellow,
              disabledForegroundColor: Colors.blue,
            ),
            icon: PhosphorIcon(
              PhosphorIcons.palette(
                PhosphorIconsStyle.bold,
              ),
            ),
          ),

          const SizedBox(width: 6),

          ///
          /// SETTINGS
          ///
          IconButton(
            onPressed: () {},
            style: IconButton.styleFrom(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 28,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 0,
              iconSize: 20,
              animationDuration: SolitaireDurations.animationLong,
              highlightColor: Colors.green,
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.yellow,
              disabledForegroundColor: Colors.blue,
            ),
            icon: PhosphorIcon(
              PhosphorIcons.gearSix(
                PhosphorIconsStyle.bold,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
