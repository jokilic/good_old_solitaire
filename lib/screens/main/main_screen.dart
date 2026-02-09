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
  @override
  void initState() {
    super.initState();

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
      body: SafeArea(
        child: Container(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
