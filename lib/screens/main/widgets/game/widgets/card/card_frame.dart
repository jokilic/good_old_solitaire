import 'package:flutter/cupertino.dart';

class CardFrame extends StatelessWidget {
  final double height;
  final double width;
  final Widget child;
  final double heightMultiplier;

  const CardFrame({
    required this.height,
    required this.width,
    required this.child,
    super.key,
    this.heightMultiplier = 1,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height * heightMultiplier,
    width: width,
    child: Align(
      alignment: Alignment.topCenter,
      child: child,
    ),
  );
}
