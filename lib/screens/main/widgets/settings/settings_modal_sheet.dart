import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../../constants/colors.dart';
import '../../../../constants/constants.dart';
import '../../../../constants/icons.dart';
import '../../../../models/settings/animation_speed.dart';
import '../../../../models/settings/draw_cards_position.dart';
import '../../../../models/settings/solitaire_settings.dart';
import '../../../../services/hive_service.dart';
import '../../../../services/sound_service.dart';
import '../../../../util/dependencies.dart';
import '../../../../util/settings.dart';
import 'widgets/settings_list_tile.dart';
import 'widgets/settings_text_button.dart';
import 'widgets/settings_volume_slider.dart';

class SettingsModalSheet extends WatchingWidget {
  @override
  Widget build(BuildContext context) {
    final hive = getIt.get<HiveService>();
    final sound = getIt.get<SoundService>();

    final settings =
        watchPropertyValue<HiveService, SolitaireSettings?>(
          (x) => x.value.settings,
        ) ??
        hive.defaultSettings;

    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;
    final elementSpacing = isWideUi ? 20 : 12;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: SolitaireConstants.padding,
        vertical: SolitaireConstants.padding * 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: SolitaireGradients.blueGradient,
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
            title: 'Draw cards',
            subtitle: 'Position on the table',
            buttons: DrawCardsPosition.values
                .map(
                  (position) => SettingsTextButton(
                    onPressed: () => hive.onDrawCardsPositionPressed(position),
                    text: getDrawCardsPositionText(position),
                    isWideUi: isWideUi,
                    isActive: settings.drawCardPosition == position,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 16),

          ///
          /// ANIMATION SPEED
          ///
          SettingsListTile(
            isWideUi: isWideUi,
            elementSpacing: elementSpacing,
            buttonSpacing: elementSpacing,
            icon: SolitaireIcons.hint,
            title: 'Animation',
            subtitle: 'Speed of cards',
            buttons: AnimationSpeed.values
                .map(
                  (speed) => SettingsTextButton(
                    onPressed: () => hive.onAnimationSpeedPressed(speed),
                    text: getAnimationSpeedText(speed),
                    isWideUi: isWideUi,
                    isActive: settings.animationSpeed == speed,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 16),

          ///
          /// SOUND VOLUME
          ///
          SettingsListTile(
            isWideUi: isWideUi,
            elementSpacing: elementSpacing,
            buttonSpacing: elementSpacing,
            icon: SolitaireIcons.hint,
            title: 'Sound',
            subtitle: 'Volume of effects',
            buttons: [
              SettingsVolumeSlider(
                onVolumeChanged: (newValue) {
                  final newVolume = newValue.clamp(0, 1).toDouble();

                  hive.onSoundVolumeChanged(newVolume);
                  sound.setVolume(newVolume);
                },
                soundVolume: settings.soundVolume,
                isWideUi: isWideUi,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
