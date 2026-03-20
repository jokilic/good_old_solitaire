import '../models/settings/animation_speed.dart';
import '../services/hive_service.dart';
import '../util/dependencies.dart';

class SolitaireDurations {
  static Duration get animation => durations.animation;
  static Duration get animationLong => durations.animationLong;

  static const Duration initialDealStaggerDuration = Duration(milliseconds: 50);
  static const Duration initialDealMoveDuration = Duration(milliseconds: 500);
  static const int initialDealCardCount = 28;

  static ({Duration animation, Duration animationLong}) get durations {
    final speed = currentAnimationSpeed;

    return switch (speed) {
      AnimationSpeed.fast => (
        animation: const Duration(milliseconds: 100),
        animationLong: const Duration(milliseconds: 200),
      ),
      AnimationSpeed.normal => (
        animation: const Duration(milliseconds: 500),
        animationLong: const Duration(milliseconds: 1000),
      ),
    };
  }

  static AnimationSpeed get currentAnimationSpeed {
    if (!getIt.isRegistered<HiveService>()) {
      return AnimationSpeed.normal;
    }

    final hive = getIt.get<HiveService>();
    return hive.value.settings?.animationSpeed ?? hive.defaultSettings.animationSpeed;
  }

  static Duration get initialDealTotalDuration {
    final totalDelayMs = (initialDealCardCount - 1) * initialDealStaggerDuration.inMilliseconds;
    return Duration(
      milliseconds: totalDelayMs + initialDealMoveDuration.inMilliseconds,
    );
  }
}
