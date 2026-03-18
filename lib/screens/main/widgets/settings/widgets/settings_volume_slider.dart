import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import '../../../../../constants/durations.dart';

class SettingsVolumeSlider extends StatelessWidget {
  final Function(double newValue) onVolumeChanged;
  final double soundVolume;
  final bool isWideUi;

  const SettingsVolumeSlider({
    required this.onVolumeChanged,
    required this.soundVolume,
    required this.isWideUi,
  });

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: SolitaireConstants.blurRadius,
        sigmaY: SolitaireConstants.blurRadius,
      ),
      child: AnimatedContainer(
        duration: SolitaireDurations.animationLong,
        curve: Curves.easeIn,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white12,
            width: SolitaireConstants.borderWidth,
          ),
          color: Colors.white12,
        ),
        child: SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white12,
            thumbColor: Colors.white,
            overlayColor: Colors.transparent,
            trackHeight: isWideUi ? 6 : 4,
          ),
          child: Slider(
            value: soundVolume,
            divisions: 10,
            onChanged: onVolumeChanged,
          ),
        ),
      ),
    ),
  );
}
