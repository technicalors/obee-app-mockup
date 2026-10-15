import 'package:flutter/material.dart';

/// Horizontal swipe navigation with a slide transition between pages.
class ScheduleSwipePager extends StatelessWidget {
  const ScheduleSwipePager({
    super.key,
    required this.pageKey,
    required this.direction,
    required this.onShift,
    required this.child,
  });

  final Key pageKey;
  final int direction;
  final ValueChanged<int> onShift;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        final velocity = details.primaryVelocity;
        if (velocity == null) {
          return;
        }
        if (velocity < -200) {
          onShift(1);
        } else if (velocity > 200) {
          onShift(-1);
        }
      },
      child: ClipRect(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final isIncoming = child.key == pageKey;
            final begin = Offset(
              isIncoming ? 0.25 * direction : -0.25 * direction,
              0,
            );
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(
                  begin: begin,
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: KeyedSubtree(key: pageKey, child: child),
        ),
      ),
    );
  }
}
