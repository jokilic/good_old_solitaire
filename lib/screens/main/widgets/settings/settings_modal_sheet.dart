import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/icons.dart';
import '../../../../models/settings/draw_cards_position.dart';
import '../../../../models/settings/solitaire_settings.dart';
import '../../../../services/hive_service.dart';
import '../../../../util/dependencies.dart';
import 'widgets/settings_list_tile.dart';
import 'widgets/settings_text_button.dart';

class SettingsModalSheet extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final settings = watchPropertyValue<HiveService, SolitaireSettings?>(
      (x) => x.value.settings,
    );

    final hive = getIt.get<HiveService>();

    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;
    final elementSpacing = isWideUi ? 20 : 12;

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
          SettingsListTile(
            isWideUi: isWideUi,
            elementSpacing: elementSpacing,
            buttonSpacing: elementSpacing,
            icon: SolitaireIcons.cardsPosition,
            title: 'Draw cards position',
            subtitle: 'Location of draw cards on the table',
            buttons: [
              ///
              /// LEFT
              ///
              SettingsTextButton(
                onPressed: () => hive.onDrawCardsPositionPressed(
                  DrawCardsPosition.left,
                ),
                text: 'Left',
                isWideUi: isWideUi,
                isActive: settings?.drawCardPosition == DrawCardsPosition.left,
              ),

              ///
              /// RIGHT
              ///
              SettingsTextButton(
                onPressed: () => hive.onDrawCardsPositionPressed(
                  DrawCardsPosition.right,
                ),
                text: 'Right',
                isWideUi: isWideUi,
                isActive: settings?.drawCardPosition == DrawCardsPosition.right,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
