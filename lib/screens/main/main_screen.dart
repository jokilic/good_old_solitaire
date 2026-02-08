import 'package:flutter/material.dart';

import '../../widgets/game/game_widget.dart';

class MainScreen extends StatelessWidget {
  final String instanceId;

  const MainScreen({
    required this.instanceId,
    required super.key,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Main'),
    ),
    body: GameWidget(
      instanceId: instanceId,
      key: key,
    ),
  );
}
