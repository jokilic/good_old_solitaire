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
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(
      useMaterial3: true,
    ),
    home: const MainScreen(
      instanceId: 'main',
    ),
  );
}
