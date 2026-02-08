import 'package:flutter/material.dart';

import 'screens/main/main_screen.dart';
import 'util/dependencies.dart';

Future<void> main() async {
  await initializeServices();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: MainScreen(
      instanceId: 'main',
      key: ValueKey('main'),
    ),
  );
}
