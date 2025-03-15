import 'package:flutter/material.dart';

class ContainerTransitionRoute extends PageRouteBuilder {
  final Widget Function(BuildContext) builder;
  final Widget openingWidget;
  final Rect openingRect;
  final Color backgroundColor;
  final Duration duration;
  final Curve curve;

  ContainerTransitionRoute({
    required this.builder,
    required this.openingWidget,
    required this.openingRect,
    this.backgroundColor = Colors.white,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return Stack(
              children: [
                // Fade in the background
                FadeTransition(
                  opacity: animation,
                  child: Container(color: backgroundColor),
                ),

                // Container transform animation
                _ContainerTransform(
                  animation: animation,
                  curve: curve,
                  openingWidget: openingWidget,
                  openingRect: openingRect,
                  closedChild: const SizedBox.shrink(),
                  openChild: child,
                ),
              ],
            );
          },
        );
}

class _ContainerTransform extends StatelessWidget {
  final Animation<double> animation;
  final Curve curve;
  final Widget openingWidget;
  final Rect openingRect;
  final Widget closedChild;
  final Widget openChild;

  const _ContainerTransform({
    required this.animation,
    required this.curve,
    required this.openingWidget,
    required this.openingRect,
    required this.closedChild,
    required this.openChild,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

    // Get the destination rect (full screen)
    final destinationRect =
        Rect.fromLTWH(0, 0, screenSize.width, screenSize.height);

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        // Interpolate between the opening rect and the full screen
        final rect =
            Rect.lerp(openingRect, destinationRect, curvedAnimation.value)!;

        return Positioned.fromRect(
          rect: rect,
          child: curvedAnimation.value < 0.5 ? openingWidget : openChild,
        );
      },
    );
  }
}
