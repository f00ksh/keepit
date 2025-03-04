import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart'
    show MasonryGridView; // Only import MasonryGridView
import 'package:keepit/src/drag_container.dart';
import 'package:keepit/src/drag_notification.dart';
import 'package:keepit/src/drag_scrollview_base.dart';
import 'package:keepit/src/models.dart';

/// Masonry grid implementation with drag-and-drop reordering
class DragMasonryGrid extends DragScrollViewBase {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Duration animationDuration;

  const DragMasonryGrid({
    super.key,
    super.enableReordering = false,
    required List<DragGridItem> super.children,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.animationDuration = const Duration(milliseconds: 300),
    super.isLongPressDraggable = true,
    super.buildFeedback,
    super.axis,
    super.dragCallbacks,
    super.hitTestBehavior = HitTestBehavior.translucent,
    super.scrollController,
    super.isDragNotification = false,
    super.draggingWidgetOpacity = 0.7,
    super.edgeScroll = 0.1,
    super.edgeScrollSpeedMilliseconds = 150,
    super.isNotDragList,
    super.dragChildBoxDecoration,
    super.scrollViewOptions,
  });

  @override
  State<DragMasonryGrid> createState() => _DragMasonryGridState();
}

class _DragMasonryGridState extends State<DragMasonryGrid> {
  List<DragListItem> _children = const [];

  @override
  void initState() {
    super.initState();
    _children = widget.children;
  }

  @override
  void didUpdateWidget(DragMasonryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children != oldWidget.children) {
      setState(() {
        _children = widget.children;
      });
    }
  }

  Widget buildContainer({
    required Widget Function(List<Widget>) buildItems,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DragContainer(
          isDrag: widget.enableReordering,
          scrollDirection: widget.scrollViewOptions.scrollDirection,
          isLongPressDraggable: widget.isLongPressDraggable,
          buildItems: buildItems,
          buildFeedback: widget.buildFeedback,
          axis: widget.axis,
          dragChildBoxDecoration: widget.dragChildBoxDecoration,
          dragCallbacks: widget.dragCallbacks,
          hitTestBehavior: widget.hitTestBehavior,
          scrollController: widget.scrollController,
          isDragNotification: widget.isDragNotification,
          draggingWidgetOpacity: widget.draggingWidgetOpacity,
          edgeScroll: widget.edgeScroll,
          edgeScrollSpeedMilliseconds: widget.edgeScrollSpeedMilliseconds,
          isNotDragList: widget.isNotDragList,
          items: (DragListItem element, DraggableWidget draggableWidget) {
            if (element is DragMasonryItem) {
              return Container(
                key: ValueKey(element.key.toString()),
                child: draggableWidget(element.widget),
              );
            } else {
              throw FlutterError(
                  'Item should be DragMasonryItem but was ${element.runtimeType}');
            }
          },
          dataList: _children,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragNotification(
      child: buildContainer(
        buildItems: (List<Widget> children) {
          return MasonryGridView.count(
            addRepaintBoundaries: false,
            shrinkWrap: true,
            padding:
                const EdgeInsets.only(right: 4, left: 4, bottom: 25, top: 12),
            scrollDirection: widget.scrollViewOptions.scrollDirection,
            reverse: widget.scrollViewOptions.reverse,
            controller: widget.scrollViewOptions.controller,
            primary: widget.scrollViewOptions.primary,
            physics: widget.scrollViewOptions.physics,
            dragStartBehavior: widget.scrollViewOptions.dragStartBehavior,
            keyboardDismissBehavior:
                widget.scrollViewOptions.keyboardDismissBehavior,
            clipBehavior: widget.scrollViewOptions.clipBehavior,
            crossAxisCount: widget.crossAxisCount,
            mainAxisSpacing: widget.mainAxisSpacing,
            crossAxisSpacing: widget.crossAxisSpacing,
            itemCount: children.length,
            itemBuilder: (context, index) {
              // Wrap each child in an AnimatedContainer
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                child: children[index],
              );
            },
          );
        },
      ),
    );
  }
}
