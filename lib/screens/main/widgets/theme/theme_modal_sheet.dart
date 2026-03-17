import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';

class ThemeModalSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: SolitaireConstants.padding,
      vertical: SolitaireConstants.padding * 2,
    ),
    decoration: const BoxDecoration(
      gradient: SolitaireGradients.greenGradient,
    ),
    child: const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose your theme',
        ),
      ],
    ),
  );
}
