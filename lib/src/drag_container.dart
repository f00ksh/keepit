import 'dart:async';
import 'package:flutter/material.dart';
import 'package:keepit/src/drag_callbacks.dart';
import 'package:keepit/src/models.dart';

import 'drag_item.dart';
import 'drag_notification.dart';
import 'render_box_size.dart';

// Helper class for managing drag item state
class DragItemState extends State<DragItem> {
  void updatePosition(Offset position) {
    // Implementation will be added later
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

typedef DraggableWidget = Widget Function(Widget child);
typedef DragTargetOn<T> = Widget Function(T? moveData, T data);

/// A widget that allows for drag-and-drop functionality within a list of items.
///
/// The [DragContainer] provides a highly customizable drag-and-drop system for reordering
/// items within a list. It handles the complex interactions and animations required for
/// smooth reordering, with support for both vertical and horizontal lists.
///
/// ## Key Features
/// - Supports both vertical and horizontal layouts
/// - Long-press or immediate drag activation
/// - Custom feedback widgets during dragging
/// - Auto-scrolling when dragging near container edges
/// - Extensive callback system for all drag events
/// - Customizable hit testing and drop detection
/// - Ability to exclude specific items from being draggable
///
/// ## Example Usage
/// ```dart
/// DragContainer<MyListItem>(
///   buildItems: (children) => ListView(children: children),
///   dataList: myItemsList,
///   items: (data, draggableWidget) => draggableWidget(
///     MyListItemWidget(data: data),
///   ),
///   isLongPressDraggable: true,
///   scrollDirection: Axis.vertical,
///   dragCallbacks: DragCallbacks(
///     onDragStarted: (item) => print('Started dragging ${item.id}'),
///     onAccept: (movedItem, targetItem, isFront, acceptDetails) {
///       print('Moved from ${acceptDetails?.oldIndex} to ${acceptDetails?.newIndex}');
///     },
///   ),
/// )
/// ```
class DragContainer<T extends DragListItem> extends StatefulWidget {
  /// Function to build the container for the draggable items
  final Widget Function(List<Widget> children) buildItems;

  /// Function to build each draggable item
  final Widget Function(T data, DraggableWidget draggableWidget) items;

  /// The data list that provides the source items
  final List<T> dataList;

  /// Optional function to build a custom feedback widget during dragging
  final Widget Function(T data, Widget child, Size size)? buildFeedback;

  /// Whether dragging requires a long press to initiate
  final bool isLongPressDraggable;

  /// Axis constraint for dragging movement (optional)
  final Axis? axis;

  /// Primary scroll direction of the container
  final Axis scrollDirection;

  /// Hit test behavior for drag detection
  final HitTestBehavior hitTestBehavior;

  /// Optional scroll controller for the container
  final ScrollController? scrollController;

  /// Whether to use drag notification to detect scroll actions
  final bool isDragNotification;

  /// Opacity of the original widget while being dragged
  final double draggingWidgetOpacity;

  /// Proportion of the screen size used for edge scrolling detection
  final double edgeScroll;

  /// Duration in milliseconds for edge scrolling animation
  final int edgeScrollSpeedMilliseconds;

  /// Whether drag-and-drop is enabled
  final bool isDrag;

  /// Optional list of items that should not be draggable
  final List<T>? isNotDragList;

  /// Optional decoration for the dragged child
  final BoxDecoration? dragChildBoxDecoration;

  /// Callbacks for various drag events
  final DragCallbacks<T> dragCallbacks;

  const DragContainer({
    required this.buildItems,
    required this.dataList,
    required this.items,
    this.isLongPressDraggable = true,
    this.buildFeedback,
    this.axis,
    this.hitTestBehavior = HitTestBehavior.translucent,
    this.scrollDirection = Axis.vertical,
    this.scrollController,
    this.isDragNotification = false,
    this.draggingWidgetOpacity = 0.5,
    this.edgeScroll = 0.1,
    this.edgeScrollSpeedMilliseconds = 100,
    this.isDrag = true,
    this.isNotDragList,
    this.dragChildBoxDecoration,
    this.dragCallbacks = const DragCallbacks(),
    super.key,
  });

  @override
  State<DragContainer> createState() => _DragContainerState();
}

class _DragContainerState<T extends DragListItem> extends State<DragContainer> {
  Timer? _timer;
  Timer? _scrollableTimer;
  ScrollableState? _scrollable;
  bool _isDragStart = false;
  T? _dragData;
  final Map<String, Size> _sizeMap = <String, Size>{};
  AcceptDetails? _acceptDetails;
  int? _originalIndex;

  // Change to use Key-based mapping rather than object identity
  final Map<String, GlobalKey> _keyCache = {};

  // Add missing scroll delay flag
  bool _isScrollDelayActive = false;

  @override
  void initState() {
    super.initState();
    // Initialize GlobalKeys for each item
    for (var item in widget.dataList) {
      _keyCache[item.key.toString()] = GlobalKey();
    }
  }

  /// Stops the willAccept timer and clears related state
  void _endWillAccept() {
    _timer?.cancel();
    _acceptDetails = null;
  }

  /// Sets the drag start state and manages associated state changes
  void _setDragStart({bool isDragStart = true}) {
    if (this._isDragStart != isDragStart) {
      setState(() {
        this._isDragStart = isDragStart;
        if (!this._isDragStart) {
          // Process final drag state
          if (_acceptDetails != null &&
              _dragData != null &&
              widget.dragCallbacks.onAccept != null) {
            // Force call onAccept with the last known drag data
            widget.dragCallbacks.onAccept?.call(
                _dragData, widget.dataList[_acceptDetails!.newIndex], true,
                acceptDetails: _acceptDetails);
          }
          _dragData = null;
        } else {
          if (_dragData != null) {
            _originalIndex = widget.dataList.indexOf(_dragData!);
          }
          _endWillAccept();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final items =
        widget.dataList.map((e) => _buildDraggableItem(e as T)).toList();
    if (widget.isDragNotification) {
      return DragNotification(
        child: widget.buildItems(items),
      );
    } else {
      return widget.buildItems(items);
    }
  }

  @override
  void didUpdateWidget(DragContainer<DragListItem> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check for changes that would require size updates
    bool needsRemeasure = oldWidget.scrollDirection != widget.scrollDirection ||
        oldWidget.dataList.length != widget.dataList.length;

    // If layout likely changed, clear size cache to force remeasurement
    if (needsRemeasure) {
      // Clear size cache to force remeasurement of all items
      _sizeMap.clear();

      // Force a rebuild to ensure sizes are remeasured quickly
      //! check here
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      // If not a layout change, just clean up items no longer in the list
      List<String> sizesToRemove = [];
      for (var key in _sizeMap.keys) {
        if (!widget.dataList.any((item) => item.key.toString() == key)) {
          sizesToRemove.add(key);
        }
      }

      for (final key in sizesToRemove) {
        _sizeMap.remove(key);
      }
    }

    // Create any missing keys for new items
    for (var item in widget.dataList) {
      if (!_keyCache.containsKey(item.key.toString())) {
        _keyCache[item.key.toString()] = GlobalKey();
      }
    }

    // Optionally clean up unused keys
    List<String> keysToRemove = [];
    for (var id in _keyCache.keys) {
      if (!widget.dataList.any((item) => item.key.toString() == id)) {
        keysToRemove.add(id);
      }
    }

    for (var id in keysToRemove) {
      _keyCache.remove(id);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.scrollController == null) {
      try {
        _scrollable = Scrollable.of(context);
      } catch (e, s) {
        debugPrint('No scrollController found!, $e \n $s');
      }
    }
  }

  /// Handles the willAccept event for drag targets
  ///
  /// This is the core method for determining what happens when an item
  /// is dragged over a potential drop target. It manages reordering
  /// the data list immediately for responsive feedback.
  ///
  /// Parameters:
  /// - moveData: The item being dragged
  /// - data: The target item being hovered over
  /// - isFront: Whether the drop would be before (true) or after (false) the target
  void _handleWillAccept(T? moveData, T data, {bool isFront = true}) {
    if (moveData == data) return;

    // Cancel any existing timers to avoid conflicts
    _endWillAccept();

    // Process immediately for responsive drag and drop - REMOVED scroll check
    if (moveData != null) {
      if (widget.dragCallbacks.onWillAccept != null) {
        widget.dragCallbacks.onWillAccept
            ?.call(moveData, data, isFront, acceptDetails: _acceptDetails);
      } else {
        final oldIndex = widget.dataList.indexOf(moveData);
        int newIndex = widget.dataList.indexOf(data);

        setState(() {
          if (isFront) {
            widget.dataList.removeAt(oldIndex);
            widget.dataList.insert(newIndex, moveData);
          } else {
            widget.dataList.removeAt(oldIndex);
            if (newIndex + 1 < widget.dataList.length) {
              newIndex += 1;
            }
            widget.dataList.insert(newIndex, moveData);
          }
        });

        _acceptDetails =
            AcceptDetails(oldIndex: _originalIndex!, newIndex: newIndex);
      }
    }
  }

  /// Determines if a specific item should be draggable
  bool _isItemDraggable(T data) {
    if (widget.isNotDragList?.toList() != null) {
      return !widget.isNotDragList!.toList().contains(data);
    }
    return true;
  }

  /// Gets the cached size of an item
  Size _getItemSize(T? data) {
    if (data == null) return Size.zero;
    return _sizeMap[data.key.toString()] ?? Size.zero;
  }

  /// Builds the main widget structure for a draggable item
  ///
  /// This wraps the item in a Stack that contains:
  /// 1. The original item content
  /// 2. A semi-transparent version when being dragged
  /// 3. The drop target areas when other items are being dragged
  Widget _buildDragScope(T data, Widget child) {
    return DragItem(
      duration: const Duration(milliseconds: 300),
      child: Stack(
        children: [
          // Main content layer
          if (!_isDragStart || _dragData != data)
            child
          else
            // Dragging opacity layer
            AnimatedOpacity(
              opacity: widget.draggingWidgetOpacity,
              duration: const Duration(milliseconds: 300),
              child: child,
            ),

          // Drop target layer - Only show when not being dragged
          if (_isDragStart && _isItemDraggable(data) && _dragData != data)
            _buildDropTargets(data),
        ],
      ),
    );
  }

  /// Builds the drop target areas for an item
  ///
  /// Creates two drop targets for each item - one for dropping before
  /// the item and one for dropping after it. Uses fixed sizes based on
  /// the item's dimensions to ensure proper layout constraints.
  Widget _buildDropTargets(T data) {
    // Get the size of the item to create properly sized drop targets
    final Size size = _getItemSize(data);

    return Flex(
      direction: widget.scrollDirection,
      mainAxisSize: MainAxisSize.min, // Prevents unbounded height errors
      children: <Widget>[
        // Front target
        SizedBox(
          width: widget.scrollDirection == Axis.horizontal
              ? size.width / 2
              : size.width,
          height: widget.scrollDirection == Axis.vertical
              ? size.height / 2
              : size.height,
          child: DragTarget<T>(
            onWillAcceptWithDetails: (DragTargetDetails<T> details) {
              _handleWillAccept(details.data, data);
              return true;
            },
            onAcceptWithDetails: widget.dragCallbacks.onAccept == null
                ? null
                : (DragTargetDetails<T> details) {
                    widget.dragCallbacks.onAccept?.call(
                        details.data, data, true,
                        acceptDetails: _acceptDetails);
                  },
            onLeave: widget.dragCallbacks.onLeave == null
                ? null
                : (T? moveData) =>
                    widget.dragCallbacks.onLeave?.call(moveData, data, true),
            onMove: widget.dragCallbacks.onMove == null
                ? null
                : (DragTargetDetails<T> details) =>
                    widget.dragCallbacks.onMove?.call(data, details, true),
            hitTestBehavior: HitTestBehavior.opaque, // Improved hit detection
            builder: (_, __, ___) => Container(color: Colors.transparent),
          ),
        ),
        // Back target
        SizedBox(
          width: widget.scrollDirection == Axis.horizontal
              ? size.width / 2
              : size.width,
          height: widget.scrollDirection == Axis.vertical
              ? size.height / 2
              : size.height,
          child: DragTarget<T>(
            onWillAcceptWithDetails: (DragTargetDetails<T> details) {
              _handleWillAccept(details.data, data, isFront: false);
              return true;
            },
            onAcceptWithDetails: widget.dragCallbacks.onAccept == null
                ? null
                : (DragTargetDetails<T> details) {
                    widget.dragCallbacks.onAccept?.call(
                        details.data, data, false,
                        acceptDetails: _acceptDetails);
                  },
            onLeave: widget.dragCallbacks.onLeave == null
                ? null
                : (T? moveData) =>
                    widget.dragCallbacks.onLeave?.call(moveData, data, false),
            onMove: widget.dragCallbacks.onMove == null
                ? null
                : (DragTargetDetails<T> details) =>
                    widget.dragCallbacks.onMove?.call(data, details, false),
            hitTestBehavior: HitTestBehavior.opaque, // Improved hit detection
            builder: (_, __, ___) => Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  /// Creates a draggable widget with all necessary configurations
  Widget _buildDraggableItem(T data) {
    // Get key from Key-based cache
    final key = _keyCache[data.key.toString()];

    final Widget draggable = widget.items(data, (Widget father) {
      Widget child = _buildDragScope(data, father);

      // Apply drag functionality if needed
      if (widget.isDrag && _isItemDraggable(data)) {
        if (widget.isLongPressDraggable) {
          child = LongPressDraggable<T>(
            feedback: _buildFeedback(data, father),
            axis: widget.axis,
            data: data,
            onDragStarted: () {
              _dragData = data;
              _setDragStart();
              widget.dragCallbacks.onDragStarted?.call(data);
            },
            onDragUpdate: (DragUpdateDetails details) {
              _autoScrollIfNecessary(details.globalPosition, father);
              widget.dragCallbacks.onDragUpdate?.call(details, data);
            },
            onDraggableCanceled: (Velocity velocity, Offset offset) {
              _setDragStart(isDragStart: false);
              _endAnimation();
              widget.dragCallbacks.onDraggableCanceled
                  ?.call(velocity, offset, data);
            },
            onDragEnd: (details) {
              _setDragStart(isDragStart: false);
              widget.dragCallbacks.onDragEnd?.call(details, data);
            },
            onDragCompleted: () {
              _setDragStart(isDragStart: false);
              _endAnimation();
              widget.dragCallbacks.onDragCompleted?.call(data);
            },
            child: child,
          );
        } else {
          child = Draggable<T>(
            feedback: _buildFeedback(data, father),
            axis: widget.axis,
            data: data,
            onDragStarted: () {
              _dragData = data;
              _setDragStart();
              widget.dragCallbacks.onDragStarted?.call(data);
            },
            onDragUpdate: (DragUpdateDetails details) {
              _autoScrollIfNecessary(details.globalPosition, father);
              widget.dragCallbacks.onDragUpdate?.call(details, data);
            },
            onDraggableCanceled: (Velocity velocity, Offset offset) {
              _setDragStart(isDragStart: false);
              _endAnimation();
              widget.dragCallbacks.onDraggableCanceled
                  ?.call(velocity, offset, data);
            },
            onDragEnd: (DraggableDetails details) {
              _setDragStart(isDragStart: false);
              widget.dragCallbacks.onDragEnd?.call(details, data);
            },
            onDragCompleted: () {
              _setDragStart(isDragStart: false);
              _endAnimation();
              widget.dragCallbacks.onDragCompleted?.call(data);
            },
            child: child,
          );
        }
      }
      return child;
    });

    return RenderBoxSize(
      draggable,
      (Size size) {
        final itemKey = data.key.toString();
        if (_sizeMap[itemKey] != size) {
          _sizeMap[itemKey] = size;
          if (_sizeMap.length == widget.dataList.length) {
            setState(() {});
          }
        }
      },
      key: key,
    );
  }

  /// Builds the feedback widget shown during dragging
  Widget _buildFeedback(T data, Widget child) {
    // Get the GlobalKey associated with this item
    final key = _keyCache[data.key.toString()];
    // Force measure the size immediately before creating the feedback
    Size currentSize = Size.zero;
    if (key?.currentContext != null) {
      final RenderBox? renderBox =
          key?.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        currentSize = renderBox.size;

        // Update the size map with the latest measurement
        _sizeMap[data.key.toString()] = currentSize;
      }
    }

    // Fall back to cached size if we couldn't measure
    if (currentSize == Size.zero) {
      currentSize = _getItemSize(data);
    }

    // Create a material wrapper for better shadow and elevation effects
    final Widget defaultFeedback = Container(
      width: currentSize.width,
      height: currentSize.height,
      decoration: widget.dragChildBoxDecoration,
      child: child,
    );

    // Use the custom feedback builder with the actual current size
    return widget.buildFeedback?.call(data, defaultFeedback, currentSize) ??
        defaultFeedback;
  }

  /// Handles auto-scrolling when dragging near the edges of the container
  void _autoScrollIfNecessary(Offset position, Widget child) {
    // Skip if scrolling is not possible
    if (_scrollable == null && widget.scrollController == null) {
      return;
    }

    // Get appropriate RenderBox
    final RenderBox scrollRenderBox;
    if (_scrollable != null) {
      scrollRenderBox = _scrollable!.context.findRenderObject()! as RenderBox;
    } else {
      scrollRenderBox = context.findRenderObject()! as RenderBox;
    }

    // Calculate scroll boundaries
    final Offset scrollOrigin = scrollRenderBox.localToGlobal(Offset.zero);
    final double scrollStart =
        _offsetExtent(scrollOrigin, widget.scrollDirection);
    final double scrollEnd =
        scrollStart + _sizeExtent(scrollRenderBox.size, widget.scrollDirection);
    final double currentOffset =
        _offsetExtent(position, widget.scrollDirection);

    // Calculate edge detection zone
    final double mediaQuery =
        _sizeExtent(MediaQuery.of(context).size, widget.scrollDirection) *
            widget.edgeScroll;

    // Check if cursor is in scroll trigger zones - but allow animations to continue
    if (currentOffset < (scrollStart + mediaQuery)) {
      // Add slight delay before starting scroll but don't block animations
      if (!_isScrollDelayActive) {
        _isScrollDelayActive = true;
        Future.delayed(const Duration(milliseconds: 50), () {
          _animateTo(mediaQuery, isNext: false);
          _isScrollDelayActive = false;
        });
      }
    } else if (currentOffset > (scrollEnd - mediaQuery)) {
      if (!_isScrollDelayActive) {
        _isScrollDelayActive = true;
        Future.delayed(const Duration(milliseconds: 50), () {
          _animateTo(mediaQuery);
          _isScrollDelayActive = false;
        });
      }
    } else {
      _endAnimation();
    }
  }

  /// Animates the scroll view when auto-scrolling is triggered
  void _animateTo(double amount, {bool isNext = true}) {
    final ScrollPosition position =
        _scrollable?.position ?? widget.scrollController!.position;

    // First stop any existing scroll animation
    _scrollableTimer?.cancel();

    // Check if we're already at the edge
    if (isNext && position.pixels >= position.maxScrollExtent) {
      return;
    } else if (!isNext && position.pixels <= position.minScrollExtent) {
      return;
    }

    // IMPORTANT: Don't set this flag - it blocks animations
    // DragNotification.isScroll = true;

    // Use a more gentle scroll approach that doesn't interfere with animations
    _scrollableTimer = Timer.periodic(
        Duration(milliseconds: widget.edgeScrollSpeedMilliseconds),
        (Timer timer) {
      if (isNext && position.pixels >= position.maxScrollExtent) {
        _endAnimation();
      } else if (!isNext && position.pixels <= position.minScrollExtent) {
        _endAnimation();
      } else {
        // Don't cancel willAccept for better responsiveness during scrolling
        // Only handle the scroll part
        position.animateTo(
          position.pixels + (isNext ? amount : -amount),
          duration: Duration(milliseconds: widget.edgeScrollSpeedMilliseconds),
          curve: Curves.linear,
        );
      }
    });

    // Record the time when animation started
  }

  /// Stops any ongoing auto-scroll animations without disrupting item animations
  void _endAnimation() {
    // Just cancel the timer but don't interfere with ongoing item animations
    _scrollableTimer?.cancel();

    // Don't set this flag as it blocks animations during scrolling
    // DragNotification.isScroll = false;
  }

  /// Utility to get the appropriate coordinate from an offset based on scroll direction
  double _offsetExtent(Offset offset, Axis scrollDirection) {
    switch (scrollDirection) {
      case Axis.horizontal:
        return offset.dx;
      case Axis.vertical:
        return offset.dy;
    }
  }

  /// Utility to get the appropriate dimension from a size based on scroll direction
  double _sizeExtent(Size size, Axis scrollDirection) {
    switch (scrollDirection) {
      case Axis.horizontal:
        return size.width;
      case Axis.vertical:
        return size.height;
    }
  }

  @override
  void dispose() {
    _endWillAccept();
    _endAnimation();
    super.dispose();
  }
}
