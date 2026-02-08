import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/durations.dart';

class MainButtonsThemeSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    mainAxisSize: MainAxisSize.min,
    children: [
      ///
      /// THEME
      ///
      IconButton.filled(
        onPressed: () {},
        style: IconButton.styleFrom(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
          PhosphorIcons.palette(
            PhosphorIconsStyle.bold,
          ),
        ),
      ),

      const SizedBox(width: 8),

      ///
      /// SETTINGS
      ///
      IconButton.filled(
        onPressed: () {},
        style: IconButton.styleFrom(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
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
          PhosphorIcons.gearSix(
            PhosphorIconsStyle.bold,
          ),
        ),
      ),
    ],
  );
}
