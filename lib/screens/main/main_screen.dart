import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../services/sound_service.dart';
import '../../util/dependencies.dart';
import 'main_controller.dart';
import 'widgets/game/game_controller.dart';
import 'widgets/game/game_widget.dart';
import 'widgets/main_bottom_buttons.dart';
import 'widgets/main_top_info.dart';

class MainScreen extends WatchingStatefulWidget {
  final String instanceId;

  const MainScreen({
    required this.instanceId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final gameWidgetKey = GlobalKey<GameWidgetState>();

  void triggerNewGame({
    required String instanceId,
  }) {
    if (!mounted) {
      return;
    }

    getIt
        .get<GameController>(
          instanceName: instanceId,
        )
        .newGame();

    final gameWidgetState = gameWidgetKey.currentState;

    if (gameWidgetState == null) {
      return;
    }

    gameWidgetState.restartInitialDealAnimation();
  }

  void triggerResetGame({
    required String instanceId,
  }) {
    if (!mounted) {
      return;
    }

    getIt
        .get<GameController>(
          instanceName: instanceId,
        )
        .resetGame();

    final gameWidgetState = gameWidgetKey.currentState;

    if (gameWidgetState == null) {
      return;
    }

    gameWidgetState.restartInitialDealAnimation();
  }

  void triggerUndo({
    required String instanceId,
  }) {
    final gameWidgetState = gameWidgetKey.currentState;

    if (gameWidgetState == null) {
      return;
    }

    gameWidgetState.undoLastMoveWithAnimation();
  }

  void triggerHint({
    required String instanceId,
  }) {
    getIt
        .get<GameController>(
          instanceName: widget.instanceId,
        )
        .selectHint();
  }

  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<MainController>(
      () => MainController(
        onNewGame: () => triggerNewGame(
          instanceId: widget.instanceId,
        ),
        onResetGame: () => triggerResetGame(
          instanceId: widget.instanceId,
        ),
        onUndo: () => triggerUndo(
          instanceId: widget.instanceId,
        ),
        onHint: () => triggerHint(
          instanceId: widget.instanceId,
        ),
      ),
      instanceName: widget.instanceId,
    );

    registerIfNotInitialized<GameController>(
      () => GameController(
        sound: getIt.get<SoundService>(),
      ),
      afterRegister: (controller) => controller.init(),
      instanceName: widget.instanceId,
    );
  }

  @override
  void dispose() {
    unRegisterIfNotDisposed<MainController>(
      instanceName: widget.instanceId,
    );
    unRegisterIfNotDisposed<GameController>(
      instanceName: widget.instanceId,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = getIt.get<MainController>(
      instanceName: widget.instanceId,
    );

    final canUndo = watchPropertyValue<GameController, bool>(
      (x) => x.value.canUndo,
      instanceName: widget.instanceId,
    );

    final canHint = watchPropertyValue<GameController, bool>(
      (x) => x.value.canHint,
      instanceName: widget.instanceId,
    );

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SolitaireConstants.padding,
          vertical: SolitaireConstants.padding * 2,
        ),
        decoration: const BoxDecoration(
          gradient: SolitaireGradients.greenGradient,
        ),
        child: Column(
          children: [
            ///
            /// TOP SPACING
            ///
            SizedBox(
              height: MediaQuery.paddingOf(context).top,
            ),

            ///
            /// TOP INFO
            ///
            MainTopInfo(
              instanceId: widget.instanceId,
            ),

            const SizedBox(
              height: SolitaireConstants.padding,
            ),

            ///
            /// GAME
            ///
            Expanded(
              child: GameWidget(
                key: gameWidgetKey,
                instanceId: widget.instanceId,
              ),
            ),

            const SizedBox(
              height: SolitaireConstants.padding,
            ),

            ///
            /// BOTTOM BUTTONS
            ///
            MainBottomButtons(
              instanceId: widget.instanceId,
              newGamePressed: () => controller.newGamePressed(context),
              resetGamePressed: () => controller.resetGamePressed(context),
              undoPressed: canUndo ? controller.undoPressed : null,
              hintPressed: canHint ? controller.hintPressed : null,
              themePressed: controller.themePressed,
              settingsPressed: controller.settingsPressed,
            ),

            ///
            /// BOTTOM SPACING
            ///
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
