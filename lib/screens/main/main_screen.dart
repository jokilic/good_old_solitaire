import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../services/sound_service.dart';
import '../../util/dependencies.dart';
import 'widgets/game/game_controller.dart';
import 'widgets/game/game_widget.dart';
import 'widgets/main_buttons_new_reset.dart';
import 'widgets/main_buttons_theme_settings.dart';
import 'widgets/main_buttons_undo_hint.dart';

class MainScreen extends StatefulWidget {
  final String instanceId;

  const MainScreen({
    required this.instanceId,
    required super.key,
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
  Widget build(BuildContext context) => Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: SolitaireColors.greenGradientColors,
        ),
      ),
      child: Column(
        children: [
          ///
          /// SCORE
          ///
          Row(
            children: [
              Text('Score'),
            ],
          ),

          ///
          /// GAME & BUTTONS
          ///
          Expanded(
            child: Stack(
              children: [
                ///
                /// GAME
                ///
                GameWidget(
                  instanceId: widget.instanceId,
                  key: ValueKey(widget.instanceId),
                ),

                ///
                /// BOTTOM BUTTONS
                ///
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      ///
                      /// NEW & RESET
                      ///
                      MainButtonsNewReset(),

                      ///
                      /// UNDO & HINT
                      ///
                      MainButtonsUndoHint(),

                      ///
                      /// THEME & SETTINGS
                      ///
                      MainButtonsThemeSettings(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
