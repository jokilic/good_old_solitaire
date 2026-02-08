import 'package:flutter/material.dart';

import 'screens/main/main_screen.dart';
import 'util/dependencies.dart';

Future<void> main() async {
  await initializeServices();
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF2E7D32),
    ),
    home: const MainScreen(
      instanceId: 'main',
      key: ValueKey('main'),
    ),
  );
}
