import 'dart:ui';

import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/material.dart';

import '../../../../../constants/constants.dart';
import '../../../../../constants/durations.dart';

class SettingsTextButton extends StatefulWidget {
  final Function()? onPressed;
  final String text;
  final bool isActive;
  final bool isWideUi;

  const SettingsTextButton({
    required this.onPressed,
    required this.text,
    required this.isActive,
    required this.isWideUi,
  });

  @override
  State<SettingsTextButton> createState() => _SettingsTextButtonState();
}

class _SettingsTextButtonState extends State<SettingsTextButton> {
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
  Widget build(BuildContext context) {
    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;

    return MouseRegion(
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: SolitaireConstants.blurRadius,
                sigmaY: SolitaireConstants.blurRadius,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isWideUi ? 24 : 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.isActive ? Colors.white12 : Colors.transparent,
                    width: SolitaireConstants.borderWidth,
                  ),
                  color: widget.isActive ? Colors.white12 : Colors.transparent,
                ),
                child: BorderedText(
                  strokeColor: Colors.black54,
                  strokeWidth: isWideUi ? 6 : 4,
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: isWideUi ? 20 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
