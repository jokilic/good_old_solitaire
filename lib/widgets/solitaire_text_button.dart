import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/durations.dart';

class SolitaireTextButton extends StatelessWidget {
  final String label;
  final IconData iconData;
  final bool isWideUi;

  const SolitaireTextButton({
    required this.label,
    required this.iconData,
    required this.isWideUi,
  });

  @override
  Widget build(BuildContext context) => TextButton(
    onPressed: () {},
    style: TextButton.styleFrom(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        horizontal: isWideUi ? 20 : 18,
        vertical: isWideUi ? 34 : 28,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      iconSize: isWideUi ? 24 : 20,
      animationDuration: SolitaireDurations.animationLong,
      backgroundColor: Colors.white12,
      foregroundColor: Colors.white,
    ),
    child: Row(
      children: [
        PhosphorIcon(iconData),
        SizedBox(width: isWideUi ? 12 : 10),
        Text(label),
      ],
    ),
  );
}
