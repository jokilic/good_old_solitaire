import 'package:flutter/material.dart';

import 'screens/main/main_screen.dart';
import 'util/navigation.dart';

/// Opens [MainScreen]
void openMain(
  BuildContext context, {
  required String instanceId,
}) => pushScreen(
  MainScreen(
    instanceId: instanceId,
    key: ValueKey(instanceId),
  ),
  context: context,
);
