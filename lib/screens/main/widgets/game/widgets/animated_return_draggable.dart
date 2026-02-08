import 'package:flutter/material.dart';

import '../../../../../constants/durations.dart';

class AnimatedReturnDraggable<T extends Object> extends StatefulWidget {
  final T data;
  final Widget feedback;
  final Widget child;
  final Widget? childWhenDragging;
  final VoidCallback? onDragStarted;
  final VoidCallback? onDragCompleted;
  final DragEndCallback? onDragEnd;
  final DraggableCanceledCallback? onDraggableCanceled;
  final VoidCallback? onReturnAnimationCompleted;

  const AnimatedReturnDraggable({
    required this.data,
    required this.feedback,
    required this.child,
    this.childWhenDragging,
    this.onDragStarted,
    this.onDragCompleted,
    this.onDragEnd,
    this.onDraggableCanceled,
    this.onReturnAnimationCompleted,
    super.key,
  });

  @override
  State<AnimatedReturnDraggable<T>> createState() => _AnimatedReturnDraggableState<T>();
}

class _AnimatedReturnDraggableState<T extends Object> extends State<AnimatedReturnDraggable<T>> with TickerProviderStateMixin {
  final anchorKey = GlobalKey();
  bool isReturning = false;

  Future<void> animateReturn(Offset from) async {
    final anchorContext = anchorKey.currentContext;
    final overlay = Overlay.maybeOf(context, rootOverlay: true);

    if (anchorContext == null || overlay == null) {
      return;
    }

    final box = anchorContext.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) {
      return;
    }

    final to = box.localToGlobal(Offset.zero);

    final controller = AnimationController(
      vsync: this,
      duration: SolitaireDurations.animation,
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    final entry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) {
          final offset = Offset.lerp(
            from,
            to,
            animation.value,
          )!;

          return Positioned(
            left: offset.dx,
            top: offset.dy,
            child: child!,
          );
        },
        child: IgnorePointer(
          child: widget.feedback,
        ),
      ),
    );

    overlay.insert(entry);

    try {
      await controller.forward();
    } finally {
      entry.remove();
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(
    key: anchorKey,
    child: Draggable<T>(
      data: widget.data,
      feedback: widget.feedback,
      onDragStarted: widget.onDragStarted,
      onDragCompleted: () {
        if (isReturning) {
          setState(() {
            isReturning = false;
          });
        }

        widget.onDragCompleted?.call();
      },
      onDragEnd: widget.onDragEnd,
      onDraggableCanceled: (velocity, offset) {
        widget.onDraggableCanceled?.call(velocity, offset);
        setState(() {
          isReturning = true;
        });

        animateReturn(offset).whenComplete(() {
          if (!mounted) {
            return;
          }

          setState(() {
            isReturning = false;
          });
          widget.onReturnAnimationCompleted?.call();
        });
      },
      childWhenDragging: widget.childWhenDragging ?? widget.child,
      child: isReturning ? (widget.childWhenDragging ?? widget.child) : widget.child,
    ),
  );
}
