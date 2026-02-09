import 'package:flutter/material.dart';

class SolitaireColors {
  static const blue1 = Color(0xFF8EA4D2);
  static const blue2 = Color(0xFF6279B8);
  static const blue3 = Color(0xFF49516F);

  static const green1 = Color(0xFF32533D);
  static const green2 = Color(0xFF496F5D);
  static const green3 = Color(0xFF758E4F);
}

class SolitaireGradients {
  static const blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      SolitaireColors.blue1,
      SolitaireColors.blue2,
      SolitaireColors.blue3,
    ],
  );

  static const greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      SolitaireColors.green1,
      SolitaireColors.green2,
      SolitaireColors.green3,
    ],
  );
}

class SolitaireBoxShadows {
  static const lift = BoxShadow(
    color: Colors.black38,
    blurRadius: 12,
    offset: Offset(0, 8),
  );
}
