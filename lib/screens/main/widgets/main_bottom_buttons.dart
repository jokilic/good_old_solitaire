import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../widgets/solitaire_icon_button.dart';
import '../../../widgets/solitaire_text_button.dart';

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

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SolitaireIconButton(
                  onPressed: newGamePressed,
                  iconData: PhosphorIcons.plus(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
                const SizedBox(width: 6),
                SolitaireIconButton(
                  onPressed: () {
                    // TODO: Reset game
                  },
                  iconData: PhosphorIcons.arrowCounterClockwise(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SolitaireTextButton(
                  onPressed: () {
                    // TODO: Undo
                  },
                  label: 'Undo',
                  iconData: PhosphorIcons.eraser(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
                const SizedBox(width: 6),
                SolitaireTextButton(
                  onPressed: () {
                    // TODO: Hint
                  },
                  label: 'Hint',
                  iconData: PhosphorIcons.lifebuoy(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SolitaireIconButton(
                  onPressed: () {
                    // TODO: Theme
                  },
                  iconData: PhosphorIcons.palette(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
                const SizedBox(width: 6),
                SolitaireIconButton(
                  onPressed: () {
                    // TODO: Settings
                  },
                  iconData: PhosphorIcons.gearSix(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
