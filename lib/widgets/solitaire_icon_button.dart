import 'package:flutter/material.dart';

class SolitaireIconButton extends StatelessWidget {
  final Function() onPressed;
  final String icon;
  final String text;
  final bool isWideUi;

  const SolitaireIconButton({
    required this.onPressed,
    required this.icon,
    required this.text,
    required this.isWideUi,
  });

  // TODO: Implement GestureDetector which will do an animated scale on hover and on tap (it scales down on hover and on tap, and scales back up when the hover/tap ends, like the user literally pressed the real button)

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ///
      /// ICON
      ///
      Image.asset(
        icon,
        height: isWideUi ? 56 : 40,
      ),

      ///
      /// SPACING
      ///
      SizedBox(height: isWideUi ? 8 : 4),

      ///
      /// TEXT
      ///
      LayoutBuilder(
        builder: (context, constraints) => SizedBox(
          width: constraints.maxWidth,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontSize: isWideUi ? 12 : 10,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
            ),
          ),
        ),
      ),
    ],
  );
}
