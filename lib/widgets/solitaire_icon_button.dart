import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/durations.dart';

class SolitaireIconButton extends StatelessWidget {
  final IconData iconData;
  final bool isWideUi;

  const SolitaireIconButton({
    required this.iconData,
    required this.isWideUi,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: () {},
    style: IconButton.styleFrom(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: isWideUi ? 14 : 12,
        vertical: isWideUi ? 26 : 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
      ),
      elevation: 0,
      iconSize: isWideUi ? 24 : 20,
      animationDuration: SolitaireDurations.animationLong,
      backgroundColor: Colors.white12,
      foregroundColor: Colors.white,
    ),
    icon: PhosphorIcon(iconData),
  );
}
