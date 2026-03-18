import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';

import '../models/hive_registrar.g.dart';
import '../models/settings/animation_speed.dart';
import '../models/settings/draw_cards_number.dart';
import '../models/settings/draw_cards_position.dart';
import '../models/settings/solitaire_settings.dart';
import '../models/theme/card_back_theme.dart';
import '../models/theme/card_front_theme.dart';
import '../models/theme/solitaire_theme.dart';
import '../models/theme/table_theme.dart';
import '../util/path.dart';

class HiveService extends ValueNotifier<({SolitaireSettings? settings, SolitaireTheme? theme})> implements Disposable {
  ///
  /// CONSTRUCTOR
  ///

  HiveService() : super((settings: null, theme: null));

  ///
  /// VARIABLES
  ///

  late final Box<SolitaireSettings> settings;
  late final Box<SolitaireTheme> theme;

  final defaultSettings = SolitaireSettings(
    drawCardPosition: DrawCardsPosition.left,
    drawCardsNumber: DrawCardsNumber.one,
    animationSpeed: AnimationSpeed.normal,
    soundVolume: 0.5,
  );

  final defaultTheme = SolitaireTheme(
    tableTheme: TableTheme.green,
    cardBackTheme: CardBackTheme.blue,
    cardFrontTheme: CardFrontTheme.classic,
  );

  ///
  /// INIT
  ///

  Future<void> init() async {
    final directory = await getHiveDirectory();

    Hive
      ..init(directory?.path)
      ..registerAdapters();

    settings = await Hive.openBox<SolitaireSettings>('settingsBox');
    theme = await Hive.openBox<SolitaireTheme>('themeBox');

    updateState();
  }

  ///
  /// DISPOSE
  ///

  @override
  Future<void> onDispose() async {
    await settings.close();
    await theme.close();

    await Hive.close();
  }

  ///
  /// METHODS
  ///

  /// Called to get `settings` from [Hive]
  SolitaireSettings getSettings() => settings.values.toList().firstOrNull ?? defaultSettings;

  /// Called to get `theme` from [Hive]
  SolitaireTheme getTheme() => theme.values.toList().firstOrNull ?? defaultTheme;

  /// Stores new `settings` in [Hive]
  Future<void> writeSettings(SolitaireSettings newSettings) async {
    await settings.clear();
    await settings.add(newSettings);
    updateState();
  }

  /// Stores new `theme` in [Hive]
  Future<void> writeTheme(SolitaireTheme newTheme) async {
    await theme.clear();
    await theme.add(newTheme);
    updateState();
  }

  /// Called when user presses button to change `drawCardPosition`
  void onDrawCardsPositionPressed(DrawCardsPosition newDrawCardPosition) {
    final currentSettings = getSettings();
    final newSettings = currentSettings.copyWith(
      drawCardPosition: newDrawCardPosition,
    );
    writeSettings(newSettings);
  }

  /// Called when user presses button to change `animationSpeed`
  void onAnimationSpeedPressed(AnimationSpeed newAnimationSpeed) {
    final currentSettings = getSettings();
    final newSettings = currentSettings.copyWith(
      animationSpeed: newAnimationSpeed,
    );
    writeSettings(newSettings);
  }

  /// Called when user changes sound effect volume
  void onSoundVolumeChanged(double newSoundVolume) {
    final currentSettings = getSettings();
    final newSettings = currentSettings.copyWith(
      soundVolume: newSoundVolume,
    );
    writeSettings(newSettings);
  }

  /// Updates `state`
  void updateState({
    SolitaireSettings? newSettings,
    SolitaireTheme? newTheme,
  }) => value = (
    settings: newSettings ?? getSettings(),
    theme: newTheme ?? getTheme(),
  );
}
