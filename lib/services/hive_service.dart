import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive_ce.dart';

import '../models/cards/solitaire_card.dart';
import '../models/cards/suit.dart';
import '../models/game/game_persistence_snapshot.dart';
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
  late final Box<Map> gameState;

  static const String currentGameKey = 'currentGame';

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
    gameState = await Hive.openBox<Map>('gameStateBox');

    updateState();
  }

  ///
  /// DISPOSE
  ///

  @override
  Future<void> onDispose() async {
    await settings.close();
    await theme.close();
    await gameState.close();

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

  /// Stores the current in-progress game so it can be resumed after app restart.
  Future<void> writeCurrentGame(GamePersistenceSnapshot snapshot) async {
    await gameState.put(
      currentGameKey,
      {
        'drawingUnopenedCards': encodeCards(snapshot.drawingUnopenedCards),
        'drawingOpenedCards': encodeCards(snapshot.drawingOpenedCards),
        'drawingRevealVersion': snapshot.drawingRevealVersion,
        'drawingRevealCardKey': snapshot.drawingRevealCardKey,
        'elapsedSeconds': snapshot.elapsedSeconds,
        'moveCounter': snapshot.moveCounter,
        'score': snapshot.score,
        'mainCards': encodeCardColumns(snapshot.mainCards),
        'finishedCards': encodeCardColumns(snapshot.finishedCards),
        'mainRevealVersions': List<int>.from(snapshot.mainRevealVersions),
        'mainRevealCardKeys': List<String?>.from(snapshot.mainRevealCardKeys),
        'initialDrawingUnopenedCards': encodeCards(snapshot.initialDrawingUnopenedCards),
        'initialMainCards': encodeCardColumns(snapshot.initialMainCards),
      },
    );
  }

  /// Returns the last stored in-progress game, if any.
  GamePersistenceSnapshot? getCurrentGame() {
    final rawSnapshot = gameState.get(currentGameKey);

    if (rawSnapshot == null) {
      return null;
    }

    final snapshot = Map<String, dynamic>.from(rawSnapshot.cast<dynamic, dynamic>());

    return GamePersistenceSnapshot(
      drawingUnopenedCards: decodeCards(snapshot['drawingUnopenedCards']),
      drawingOpenedCards: decodeCards(snapshot['drawingOpenedCards']),
      drawingRevealVersion: snapshot['drawingRevealVersion'] as int? ?? 0,
      drawingRevealCardKey: snapshot['drawingRevealCardKey'] as String?,
      elapsedSeconds: snapshot['elapsedSeconds'] as int? ?? 0,
      moveCounter: snapshot['moveCounter'] as int? ?? 0,
      score: snapshot['score'] as int? ?? 0,
      mainCards: decodeCardColumns(snapshot['mainCards']),
      finishedCards: decodeCardColumns(snapshot['finishedCards']),
      mainRevealVersions: decodeIntList(snapshot['mainRevealVersions']),
      mainRevealCardKeys: decodeNullableStringList(snapshot['mainRevealCardKeys']),
      initialDrawingUnopenedCards: decodeCards(snapshot['initialDrawingUnopenedCards']),
      initialMainCards: decodeCardColumns(snapshot['initialMainCards']),
    );
  }

  Future<void> clearCurrentGame() async {
    await gameState.delete(currentGameKey);
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

  List<Map<String, dynamic>> encodeCards(List<SolitaireCard> cards) => [
    for (final card in cards)
      {
        'suit': card.suit.name,
        'rank': card.rank,
        'faceUp': card.faceUp,
      },
  ];

  List<List<Map<String, dynamic>>> encodeCardColumns(List<List<SolitaireCard>> columns) => [
    for (final column in columns) encodeCards(column),
  ];

  List<SolitaireCard> decodeCards(dynamic rawCards) {
    if (rawCards is! List) {
      return [];
    }

    return [
      for (final rawCard in rawCards)
        if (rawCard is Map)
          SolitaireCard(
            suit: Suit.values.byName(rawCard['suit'] as String),
            rank: rawCard['rank'] as int,
            faceUp: rawCard['faceUp'] as bool,
          ),
    ];
  }

  List<List<SolitaireCard>> decodeCardColumns(dynamic rawColumns) {
    if (rawColumns is! List) {
      return [];
    }

    return [
      for (final rawColumn in rawColumns) decodeCards(rawColumn),
    ];
  }

  List<int> decodeIntList(dynamic rawValues) {
    if (rawValues is! List) {
      return [];
    }

    return [
      for (final value in rawValues)
        if (value is int) value,
    ];
  }

  List<String?> decodeNullableStringList(dynamic rawValues) {
    if (rawValues is! List) {
      return [];
    }

    return [
      for (final value in rawValues) value as String?,
    ];
  }
}
