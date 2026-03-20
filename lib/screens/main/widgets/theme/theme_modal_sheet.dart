import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';

class ThemeModalSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SolitaireConstants.padding,
        vertical: SolitaireConstants.padding * 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: SolitaireGradients.greenGradient,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///
          /// TITLE
          ///
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: BorderedText(
              strokeColor: Colors.black54,
              strokeWidth: isWideUi ? 6 : 4,
              child: Text(
                'Theme',
                style: TextStyle(
                  fontSize: isWideUi ? 36 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 800),
            padding: EdgeInsets.symmetric(
              horizontal: isWideUi ? 24 : 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white12,
                width: SolitaireConstants.borderWidth,
              ),
              color: Colors.white12,
            ),
            child: BorderedText(
              strokeColor: Colors.black54,
              strokeWidth: isWideUi ? 6 : 4,
              child: Text(
                'Currently working on this...',
                style: TextStyle(
                  fontSize: isWideUi ? 18 : 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
