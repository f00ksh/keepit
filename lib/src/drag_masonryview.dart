import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:keepit/src/drag_container.dart';
import 'package:keepit/src/drag_notification.dart';
import 'package:keepit/src/drag_scrollview_base.dart';
import 'package:keepit/src/models.dart';

/// Masonry grid implementation with drag-and-drop reordering
class DragMasonryGrid extends DragScrollViewBase {
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final bool enableShakeAnimation;

  const DragMasonryGrid({
    super.key,
    super.enableReordering = false,
    required List<DragGridItem> super.children,
    required this.crossAxisCount,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    super.isLongPressDraggable = true,
    super.buildFeedback,
    super.axis,
    super.dragCallbacks,
    super.hitTestBehavior = HitTestBehavior.translucent,
    super.scrollController,
    super.isDragNotification = false,
    super.draggingWidgetOpacity = 0.5,
    super.edgeScroll = 0.1,
    super.edgeScrollSpeedMilliseconds = 500,
    super.isNotDragList,
    this.enableShakeAnimation = false,
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
      enableShakeAnimation: widget.enableShakeAnimation,
      items: (DragListItem element, DraggableWidget draggableWidget) {
        if (element is DragGridExtentItem) {
          return SizedBox(
            width: element.mainAxisExtent,
            key: ValueKey(element.key.toString()),
            child: draggableWidget(element.widget),
          );
        } else {
          throw FlutterError(
              'Item should be of type DragGridExtentItem for masonry layout.');
        }
      },
      dataList: _children,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DragNotification(
      child: SingleChildScrollView(
        scrollDirection: widget.scrollViewOptions.scrollDirection,
        reverse: widget.scrollViewOptions.reverse,
        controller: widget.scrollViewOptions.controller,
        primary: widget.scrollViewOptions.primary,
        physics: widget.scrollViewOptions.physics,
        padding: widget.scrollViewOptions.padding,
        dragStartBehavior: widget.scrollViewOptions.dragStartBehavior,
        keyboardDismissBehavior:
            widget.scrollViewOptions.keyboardDismissBehavior,
        restorationId: widget.scrollViewOptions.restorationId,
        clipBehavior: widget.scrollViewOptions.clipBehavior,
        child: buildContainer(
          buildItems: (List<Widget> children) {
            return MasonryGridView.count(
              padding:
                  const EdgeInsets.only(right: 8, left: 8, bottom: 25, top: 12),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: widget.crossAxisCount,
              mainAxisSpacing: widget.mainAxisSpacing,
              crossAxisSpacing: widget.crossAxisSpacing,
              itemCount: children.length,
              itemBuilder: (context, index) {
                return children[index];
              },
            );
          },
        ),
      ),
    );
  }
}
