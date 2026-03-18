import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';

import '../constants/durations.dart';

class SolitaireIconButton extends StatefulWidget {
  final Function()? onPressed;
  final String icon;
  final String text;
  final bool isWideUi;

  const SolitaireIconButton({
    required this.onPressed,
    required this.icon,
    required this.text,
    required this.isWideUi,
  });

  @override
  State<SolitaireIconButton> createState() => _SolitaireIconButtonState();
}

class _SolitaireIconButtonState extends State<SolitaireIconButton> {
  var isHovered = false;
  var isPressed = false;

  bool get isEnabled => widget.onPressed != null;

  double get targetScale {
    if (!isEnabled) {
      return 1;
    }

    if (isPressed) {
      return 0.9;
    }

    if (isHovered) {
      return 0.95;
    }

    return 1;
  }

  void setHovered(bool value) {
    if (isHovered == value) {
      return;
    }

    setState(
      () => isHovered = value,
    );
  }

  void setPressed(bool value) {
    if (isPressed == value) {
      return;
    }

    setState(
      () => isPressed = value,
    );
  }

  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: isEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
    onEnter: (_) => isEnabled ? setHovered(true) : null,
    onExit: (_) {
      setHovered(false);
      setPressed(false);
    },
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onPressed,
      onTapDown: (_) => isEnabled ? setPressed(true) : null,
      onTapUp: (_) => setPressed(false),
      onTapCancel: () => setPressed(false),
      child: AnimatedScale(
        scale: targetScale,
        duration: SolitaireDurations.animationLong,
        curve: Curves.easeIn,
        child: Column(
          children: [
            ///
            /// ICON
            ///
            Image.asset(
              widget.icon,
              height: widget.isWideUi ? 56 : 40,
              color: isEnabled ? null : Colors.white54,
            ),

            ///
            /// SPACING
            ///
            SizedBox(
              height: widget.isWideUi ? 8 : 4,
            ),

            ///
            /// TEXT
            ///
            LayoutBuilder(
              builder: (context, constraints) => SizedBox(
                width: constraints.maxWidth,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: BorderedText(
                    strokeColor: Colors.black54,
                    strokeWidth: widget.isWideUi ? 4 : 2,
                    child: Text(
                      widget.text,
                      style: TextStyle(
                        fontSize: widget.isWideUi ? 12 : 10,
                        color: isEnabled ? Colors.white : Colors.white54,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
