import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../../constants/constants.dart';
import '../../../../../../models/solitaire_card.dart';
import 'card_label.dart';

class CardFront extends StatelessWidget {
  final SolitaireCard card;
  final double height;
  final double width;

  const CardFront({
    required this.card,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final color = card.isRed ? Colors.redAccent : Colors.black87;
    final label = card.cardLabel;
    final icon = card.suitIcon;

    final isWideUi = MediaQuery.sizeOf(context).width > SolitaireConstants.compactLayoutMaxWidth;

    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SolitaireConstants.borderRadius),
        border: Border.all(
          width: SolitaireConstants.borderWidth,
        ),
        color: Colors.white,
      ),
      child: isWideUi
          ? WideCardFace(
              label: label,
              color: color,
              icon: icon,
              width: width,
            )
          : Stack(
              children: [
                ///
                /// LABEL
                ///
                Positioned(
                  top: 2,
                  left: 4,
                  child: CardLabel(
                    label: label,
                    color: color,
                  ),
                ),

                ///
                /// ICON
                ///
                Positioned(
                  bottom: -8,
                  left: 0,
                  right: -24,
                  child: ClipRect(
                    child: PhosphorIcon(
                      icon,
                      color: color,
                      size: 56,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class WideCardFace extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final double width;

  const WideCardFace({
    required this.label,
    required this.color,
    required this.icon,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final smallIconSize = width * 0.2;
    final centerIconSize = width * 0.5;

    final labelStyle = TextStyle(
      color: color,
      fontSize: width * 0.25,
      fontWeight: FontWeight.w700,
      height: 1,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 4,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ///
              /// LABEL & ICON
              ///
              Text(
                label,
                style: labelStyle,
              ),
              PhosphorIcon(
                icon,
                color: color,
                size: smallIconSize,
              ),
            ],
          ),

          ///
          /// CENTER ICON
          ///
          Expanded(
            child: Center(
              child: PhosphorIcon(
                icon,
                color: color,
                size: centerIconSize,
              ),
            ),
          ),

          ///
          /// ICON & LABEL
          ///
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PhosphorIcon(
                icon,
                color: color,
                size: smallIconSize,
              ),
              Transform.rotate(
                angle: math.pi,
                child: Text(
                  label,
                  style: labelStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
