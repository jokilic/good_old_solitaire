import 'package:flutter/material.dart';

import '../../../constants/constants.dart';
import '../../../constants/icons.dart';
import '../../../widgets/solitaire_icon_button.dart';

class MainBottomButtons extends StatelessWidget {
  final String instanceId;
  final Function() newGamePressed;

  const MainBottomButtons({
    required this.instanceId,
    required this.newGamePressed,
  });

  @override
  Widget build(BuildContext context) {
    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;
    final buttonSpacing = isWideUi ? 16 : 8;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
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
                onPressed: () {
                  // TODO: Reset game
                },
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
                onPressed: () {
                  // TODO: Undo
                },
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
                onPressed: () {
                  // TODO: Hint
                },
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
                onPressed: () {
                  // TODO: Theme
                },
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
                onPressed: () {
                  // TODO: Settings
                },
                icon: SolitaireIcons.settings,
                text: 'Settings',
                isWideUi: isWideUi,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
