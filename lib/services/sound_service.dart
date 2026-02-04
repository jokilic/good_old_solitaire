import 'package:audioplayers/audioplayers.dart';

import '../constants/enums.dart';

class SoundService {
  final Map<GameSound, Future<AudioPlayer>> players = {};

  Future<void> playCardLift() => play(
    sound: GameSound.cardLift,
    assetPath: 'sounds/card_lift.ogg',
  );

  Future<void> playCardPlace() => play(
    sound: GameSound.cardPlace,
    assetPath: 'sounds/card_place.ogg',
  );

  Future<void> playCardFlip() => play(
    sound: GameSound.cardFlip,
    assetPath: 'sounds/card_flip.ogg',
  );

  Future<void> playCardDraw() => play(
    sound: GameSound.cardDraw,
    assetPath: 'sounds/card_draw.ogg',
  );

  Future<void> playDrawPileExhausted() => play(
    sound: GameSound.drawPileExhausted,
    assetPath: 'sounds/draw_pile_exhausted.ogg',
  );

  Future<void> playDrawPileReset() => play(
    sound: GameSound.drawPileReset,
    assetPath: 'sounds/draw_pile_reset.ogg',
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

      return player;
    },
  );
}
