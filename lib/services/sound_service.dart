import 'package:audioplayers/audioplayers.dart';

import '../constants/enums.dart';

class SoundService {
  final Map<GameSound, Future<AudioPlayer>> players = {};

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

  Future<AudioPlayer> playerFor(GameSound sound) => players.putIfAbsent(
    sound,
    () async {
      final player = AudioPlayer();

      await player.setPlayerMode(PlayerMode.lowLatency);
      await player.setReleaseMode(ReleaseMode.stop);
      await player.setVolume(0.5);

      return player;
    },
  );
}
