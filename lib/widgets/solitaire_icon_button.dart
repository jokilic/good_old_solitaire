import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/durations.dart';

class SolitaireIconButton extends StatelessWidget {
  final Function() onPressed;
  final IconData iconData;
  final bool isWideUi;

  const SolitaireIconButton({
    required this.onPressed,
    required this.iconData,
    required this.isWideUi,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: isWideUi ? 72 : 60,
    width: isWideUi ? 72 : 60,
    child: IconButton(
      onPressed: onPressed,
      style: IconButton.styleFrom(
        alignment: Alignment.center,
        padding: EdgeInsets.zero,
        shape: const StadiumBorder(),
        elevation: 0,
        iconSize: isWideUi ? 24 : 20,
        animationDuration: SolitaireDurations.animationLong,
        backgroundColor: Colors.white12,
        foregroundColor: Colors.white,
      ),
      icon: PhosphorIcon(iconData),
    ),
  );
}
