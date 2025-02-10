import 'package:flutter/material.dart';

class NoteHeroWidget extends StatelessWidget {
  final Widget child;
  final String tag;

  const NoteHeroWidget({
    super.key,
    required this.child,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      flightShuttleBuilder: (
        BuildContext flightContext,
        Animation<double> animation,
        HeroFlightDirection flightDirection,
        BuildContext fromHeroContext,
        BuildContext toHeroContext,
      ) {
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, child) {
            return Material(
              color: Colors.transparent,
              child: child,
            );
          },
        );
      },
      child: child,
    );
  }
}
