import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../constants/constants.dart';
import '../../../widgets/solitaire_icon_button.dart';
import '../../../widgets/solitaire_text_button.dart';

class MainBottomButtons extends StatelessWidget {
  final String instanceId;

  const MainBottomButtons({
    required this.instanceId,
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
                  iconData: PhosphorIcons.plus(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
                const SizedBox(width: 6),
                SolitaireIconButton(
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
                  label: 'Undo',
                  iconData: PhosphorIcons.eraser(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
                const SizedBox(width: 6),
                SolitaireTextButton(
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
                  iconData: PhosphorIcons.palette(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
                const SizedBox(width: 6),
                SolitaireIconButton(
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
