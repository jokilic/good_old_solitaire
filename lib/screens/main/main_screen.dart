import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/constants.dart';
import '../../services/sound_service.dart';
import '../../util/dependencies.dart';
import 'main_controller.dart';
import 'widgets/game/game_controller.dart';
import 'widgets/game/game_widget.dart';
import 'widgets/main_bottom_buttons.dart';
import 'widgets/main_top_info.dart';

class MainScreen extends StatefulWidget {
  final String instanceId;

  const MainScreen({
    required this.instanceId,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var gameNumber = 0;

  void newGameWithAnimation({
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

    setState(
      () => gameNumber += 1,
    );
  }

  void resetGameWithAnimation({
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

    setState(
      () => gameNumber += 1,
    );
  }

  @override
  void initState() {
    super.initState();

    registerIfNotInitialized<MainController>(
      () => MainController(
        onNewGame: () => newGameWithAnimation(
          instanceId: widget.instanceId,
        ),
        onResetGame: () => resetGameWithAnimation(
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
                key: ValueKey(
                  '${widget.instanceId}-$gameNumber',
                ),
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
