import 'package:flutter/material.dart';

import '../../widgets/game/game_widget.dart';

class MainScreen extends StatelessWidget {
  final String instanceId;

  const MainScreen({
    required this.instanceId,
    required super.key,
  });

  void showToolbarMessage(
    String message, {
    required BuildContext context,
  }) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Good old Solitaire'),
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Container(
          decoration: ShapeDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.casino_outlined),
                  label: const Text('New game'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Reset game'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.undo_outlined),
                  label: const Text('Undo moves'),
                ),
                FilledButton.tonalIcon(
                  onPressed: () {},
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Hint'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    body: GameWidget(
      instanceId: instanceId,
      key: key,
    ),
  );
}
