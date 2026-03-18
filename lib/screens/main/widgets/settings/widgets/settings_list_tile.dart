import 'dart:ui';

import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import 'settings_text_button.dart';

class SettingsListTile extends StatelessWidget {
  final bool isWideUi;
  final int elementSpacing;
  final int buttonSpacing;
  final String title;
  final String subtitle;
  final String icon;
  final List<SettingsTextButton> buttons;

  const SettingsListTile({
    required this.isWideUi,
    required this.elementSpacing,
    required this.buttonSpacing,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttons,
  });

  @override
  Widget build(BuildContext context) => Center(
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
            spacing: elementSpacing.toDouble(),
            children: [
              ///
              /// ICON
              ///
              Image.asset(
                icon,
                height: isWideUi ? 50 : 36,
              ),

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
                        title,
                        style: TextStyle(
                          fontSize: isWideUi ? 18 : 14,
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
                        subtitle,
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
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: buttonSpacing.toDouble(),
                children: buttons,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
