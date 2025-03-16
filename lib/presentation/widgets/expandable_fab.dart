import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/providers/fab_provider.dart';

class ExpandableFab extends ConsumerStatefulWidget {
  final Function() onTextNotePressed;
  final Function() onTodoNotePressed;

  const ExpandableFab({
    super.key,
    required this.onTextNotePressed,
    required this.onTodoNotePressed,
  });

  @override
  ConsumerState<ExpandableFab> createState() => ExpandableFabState();
}

class ExpandableFabState extends ConsumerState<ExpandableFab>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggle() {
    final fabNotifier = ref.read(fabExpansionProvider.notifier);
    final isExpanded = !ref.read(fabExpansionProvider);

    fabNotifier.setExpanded(isExpanded);

    if (isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isExpanded = ref.watch(fabExpansionProvider);

    return Flow(
      clipBehavior: Clip.none,
      delegate: VerticalFlowMenuDelegate(controller: _controller),
      children: <Widget>[
        // Main FAB
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FloatingActionButton(
              heroTag: 'main_add_fab',
              onPressed: toggle,
              child: Transform.rotate(
                // 30 degree
                angle: _controller.value * math.pi * .5,
                child: Icon(
                  isExpanded ? Icons.close : Icons.add,
                  size: 34.0,
                ),
              ),
            );
          },
        ),
        // Text Note Button
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final animation = CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.0, 1.0, curve: Curves.easeOut),
            );

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: _buildActionButton(
                  onPressed: () {
                    toggle();
                    widget.onTextNotePressed();
                  },
                  icon: Icons.text_fields,
                  label: 'Text',
                  heroTag: 'text_note_fab',
                ),
              ),
            );
          },
        ),
        // Todo Note Button
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final animation = CurvedAnimation(
              parent: _controller,
              curve: const Interval(0.1, 1.0, curve: Curves.easeOut),
            );

            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: animation,
                child: _buildActionButton(
                  onPressed: () {
                    toggle();
                    widget.onTodoNotePressed();
                  },
                  icon: Icons.check_box_outlined,
                  label: 'Todos',
                  heroTag: 'todo_note_fab',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    required String heroTag,
  }) {
    final isExpanded = ref.watch(fabExpansionProvider);

    return FloatingActionButton.extended(
      shape: const StadiumBorder(),
      heroTag: heroTag,
      onPressed: isExpanded ? onPressed : null,
      elevation: 1,
      foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      label: Text(label),
      icon: Icon(icon, size: 24),
    );
  }
}

class VerticalFlowMenuDelegate extends FlowDelegate {
  final Animation<double> controller;

  VerticalFlowMenuDelegate({required this.controller})
      : super(repaint: controller);

  @override
  void paintChildren(FlowPaintingContext context) {
    final size = context.size;
    final fabSize = 56.0;
    final xStart = size.width - fabSize;
    final yStart = size.height - fabSize;

    for (var i = 0; i < context.childCount; i++) {
      final childSize = context.getChildSize(i)!;
      final buttonWidth = childSize.width;

      switch (i) {
        case 0: // Main FAB
          context.paintChild(
            i,
            transform: Matrix4.translationValues(
              xStart,
              yStart,
              0.0,
            ),
          );
          break;
        default: // Action Buttons
          final xOffset = xStart - (buttonWidth - fabSize);
          final distance = 70.0 * i;

          // Calculate the vertical offset with animation
          final yOffset = yStart - (distance * controller.value);

          context.paintChild(
            i,
            transform: Matrix4.translationValues(
              xOffset,
              yOffset,
              0.0,
            ),
          );
          break;
      }
    }
  }

  @override
  bool shouldRepaint(VerticalFlowMenuDelegate oldDelegate) {
    return oldDelegate.controller != controller;
  }
}
