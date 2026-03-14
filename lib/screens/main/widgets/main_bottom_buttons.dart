import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../constants/icons.dart';
import '../../../widgets/solitaire_icon_button.dart';

class MainBottomButtons extends StatelessWidget {
  final String instanceId;
  final Function() newGamePressed;
  final Function() resetGamePressed;
  final Function()? undoPressed;
  final Function()? hintPressed;
  final Function()? themePressed;
  final Function()? settingsPressed;

  const MainBottomButtons({
    required this.instanceId,
    required this.newGamePressed,
    required this.resetGamePressed,
    required this.undoPressed,
    required this.hintPressed,
    required this.themePressed,
    required this.settingsPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;
    final buttonSpacing = isWideUi ? 16 : 8;

    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: SolitaireConstants.blurRadius,
            sigmaY: SolitaireConstants.blurRadius,
          ),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white12,
                width: SolitaireConstants.borderWidth,
              ),
              color: Colors.white12,
            ),
            constraints: const BoxConstraints(maxWidth: 800),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: buttonSpacing.toDouble(),
              children: [
                ///
                /// NEW GAME
                ///
                Expanded(
                  child: SolitaireIconButton(
                    onPressed: newGamePressed,
                    icon: SolitaireIcons.newIcon,
                    text: 'New',
                    isWideUi: isWideUi,
                  ),
                ),

                ///
                /// RESET GAME
                ///
                Expanded(
                  child: SolitaireIconButton(
                    onPressed: resetGamePressed,
                    icon: SolitaireIcons.reset,
                    text: 'Reset',
                    isWideUi: isWideUi,
                  ),
                ),

                ///
                /// UNDO
                ///
                Expanded(
                  child: SolitaireIconButton(
                    onPressed: undoPressed,
                    icon: SolitaireIcons.undo,
                    text: 'Undo',
                    isWideUi: isWideUi,
                  ),
                ),

                ///
                /// HINT
                ///
                Expanded(
                  child: SolitaireIconButton(
                    onPressed: hintPressed,
                    icon: SolitaireIcons.hint,
                    text: 'Hint',
                    isWideUi: isWideUi,
                  ),
                ),

                ///
                /// THEME
                ///
                Expanded(
                  child: SolitaireIconButton(
                    onPressed: themePressed,
                    icon: SolitaireIcons.theme,
                    text: 'Theme',
                    isWideUi: isWideUi,
                  ),
                ),

                ///
                /// SETTINGS
                ///
                Expanded(
                  child: SolitaireIconButton(
                    onPressed: settingsPressed,
                    icon: SolitaireIcons.settings,
                    text: 'Settings',
                    isWideUi: isWideUi,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
