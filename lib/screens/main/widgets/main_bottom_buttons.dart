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
    final buttonSpacing = isWideUi ? 16 : 8;

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            spacing: buttonSpacing.toDouble(),
            children: [
              Expanded(
                child: SolitaireIconButton(
                  onPressed: newGamePressed,
                  iconData: PhosphorIcons.plus(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
              ),

              Expanded(
                child: SolitaireIconButton(
                  onPressed: () {
                    // TODO: Reset game
                  },
                  iconData: PhosphorIcons.arrowCounterClockwise(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
              ),

              Expanded(
                flex: 2,
                child: SolitaireTextButton(
                  onPressed: () {
                    // TODO: Undo
                  },
                  label: 'Undo',
                  iconData: PhosphorIcons.eraser(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
              ),

              Expanded(
                flex: 2,
                child: SolitaireTextButton(
                  onPressed: () {
                    // TODO: Hint
                  },
                  label: 'Hint',
                  iconData: PhosphorIcons.lightbulb(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
              ),

              Expanded(
                child: SolitaireIconButton(
                  onPressed: () {
                    // TODO: Theme
                  },
                  iconData: PhosphorIcons.palette(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
              ),

              Expanded(
                child: SolitaireIconButton(
                  onPressed: () {
                    // TODO: Settings
                  },
                  iconData: PhosphorIcons.gearSix(
                    PhosphorIconsStyle.bold,
                  ),
                  isWideUi: isWideUi,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
