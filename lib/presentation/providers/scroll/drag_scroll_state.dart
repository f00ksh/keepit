import 'dart:async';

class DragScrollState {
  final bool isDragging;
  final double? lastDragY;
  final Timer? scrollTimer;

  const DragScrollState({
    this.isDragging = false,
    this.lastDragY,
    this.scrollTimer,
  });

  DragScrollState copyWith({
    bool? isDragging,
    double? lastDragY,
    Timer? scrollTimer,
  }) {
    return DragScrollState(
      isDragging: isDragging ?? this.isDragging,
      lastDragY: lastDragY ?? this.lastDragY,
      scrollTimer: scrollTimer ?? this.scrollTimer,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DragScrollState &&
        other.isDragging == isDragging &&
        other.lastDragY == lastDragY &&
        other.scrollTimer == scrollTimer;
  }

  @override
  int get hashCode =>
      isDragging.hashCode ^ lastDragY.hashCode ^ scrollTimer.hashCode;
}
