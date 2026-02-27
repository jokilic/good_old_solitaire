import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../constants/durations.dart';

class SolitaireTextButton extends StatelessWidget {
  final Function() onPressed;
  final String label;
  final IconData iconData;
  final bool isWideUi;

  const SolitaireTextButton({
    required this.onPressed,
    required this.label,
    required this.iconData,
    required this.isWideUi,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: isWideUi ? 72 : 60,
    child: TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        textStyle: TextStyle(
          fontSize: isWideUi ? 16 : 14,
          fontWeight: FontWeight.bold,
        ),
        alignment: Alignment.center,
        padding: EdgeInsets.zero,
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PhosphorIcon(iconData),
          SizedBox(width: isWideUi ? 12 : 10),
          Text(label),
        ],
      ),
    ),
  );
}
