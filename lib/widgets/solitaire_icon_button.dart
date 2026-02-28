import 'package:flutter/material.dart';

import '../constants/durations.dart';

class SolitaireIconButton extends StatelessWidget {
  final Function() onPressed;
  final String icon;
  final String text;
  final bool isWideUi;

  const SolitaireIconButton({
    required this.onPressed,
    required this.icon,
    required this.text,
    required this.isWideUi,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ///
      /// ICON
      ///
      SizedBox(
        height: isWideUi ? 72 : 60,
        child: IconButton(
          onPressed: onPressed,
          style: IconButton.styleFrom(
            alignment: Alignment.center,
            padding: EdgeInsets.zero,
            shape: const StadiumBorder(),
            elevation: 0,
            iconSize: isWideUi ? 24 : 20,
            animationDuration: SolitaireDurations.animationLong,
          ),
          icon: Image.asset(
            icon,
            height: isWideUi ? 64 : 48,
          ),
        ),
      ),
      const SizedBox(height: 4),

      ///
      /// TEXT
      ///
      // TODO: Make text adaptive and it should always scale to fit the button
      Text(
        text,
        style: TextStyle(
          fontSize: isWideUi ? 14 : 12,
          color: Colors.white,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}
