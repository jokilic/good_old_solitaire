import 'package:audioplayers/audioplayers.dart';

import '../constants/enums.dart';

class SoundService {
  ///
  /// VARIABLES
  ///

  final players = <GameSound, Future<AudioPlayer>>{};
  var volume = 0.5;

  ///
  /// METHODS
  ///

  Future<void> playCardLift() => play(
    sound: GameSound.cardLift,
    assetPath: 'sounds/card_lift.m4a',
  );

  Future<void> playCardPlace() => play(
    sound: GameSound.cardPlace,
    assetPath: 'sounds/card_place.m4a',
  );

  Future<void> playCardFlip() => play(
    sound: GameSound.cardFlip,
    assetPath: 'sounds/card_flip.m4a',
  );

  Future<void> playCardDraw() => play(
    sound: GameSound.cardDraw,
    assetPath: 'sounds/card_draw.m4a',
  );

  Future<void> playDrawPileReset() => play(
    sound: GameSound.drawPileReset,
    assetPath: 'sounds/card_draw_pile_reset.m4a',
  );

  Future<void> playShuffle() => play(
    sound: GameSound.shuffle,
    assetPath: 'sounds/card_shuffle.m4a',
  );

  Future<void> play({
    required GameSound sound,
    required String assetPath,
  }) async {
    try {
      final player = await playerFor(sound);

      await player.stop();

      await player.play(
        AssetSource(assetPath),
      );
    } catch (_) {
      return;
    }
  }

  Future<void> setVolume(double newVolume) async {
    volume = newVolume.clamp(0, 1);

    for (final player in players.values) {
      try {
        await (await player).setVolume(volume);
      } catch (_) {
        continue;
      }
    }
  }

  Future<AudioPlayer> playerFor(GameSound sound) => players.putIfAbsent(
    sound,
    () async {
      final player = AudioPlayer();

      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(volume);

      return player;
    },
  );
}
