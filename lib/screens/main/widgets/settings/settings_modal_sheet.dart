import 'dart:ui';

import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/icons.dart';
import '../../../../widgets/solitaire_icon_button.dart';

class SettingsModalSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;
    final buttonSpacing = isWideUi ? 16 : 8;

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
                'Settings',
                style: TextStyle(
                  fontSize: isWideUi ? 36 : 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          ///
          /// LAYOUT DIRECTION
          ///
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: SolitaireConstants.blurRadius,
                  sigmaY: SolitaireConstants.blurRadius,
                ),
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 800),
                  padding: EdgeInsets.symmetric(
                    horizontal: isWideUi ? 24 : 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white12,
                      width: SolitaireConstants.borderWidth,
                    ),
                    color: Colors.white12,
                  ),

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    spacing: buttonSpacing.toDouble(),
                    children: [
                      ///
                      /// TEXT
                      ///
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ///
                            /// TITLE
                            ///
                            BorderedText(
                              strokeColor: Colors.black54,
                              strokeWidth: isWideUi ? 6 : 4,
                              child: Text(
                                'Draw cards position',
                                style: TextStyle(
                                  fontSize: isWideUi ? 20 : 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),

                            ///
                            /// SUBTITLE
                            ///
                            BorderedText(
                              strokeColor: Colors.black54,
                              strokeWidth: isWideUi ? 4 : 2,
                              child: Text(
                                'Location of draw cards on the table',
                                style: TextStyle(
                                  fontSize: isWideUi ? 14 : 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      ///
                      /// BUTTONS
                      ///
                      Container(
                        color: Colors.yellow,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: buttonSpacing.toDouble(),
                          children: [
                            Container(
                              color: Colors.red,
                              width: 56,
                              child: SolitaireIconButton(
                                onPressed: () {},
                                icon: SolitaireIcons.hint,
                                text: 'Left',
                                isWideUi: isWideUi,
                              ),
                            ),

                            Container(
                              color: Colors.green,
                              width: 56,
                              child: SolitaireIconButton(
                                onPressed: () {},
                                icon: SolitaireIcons.hint,
                                text: 'Right',
                                isWideUi: isWideUi,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
