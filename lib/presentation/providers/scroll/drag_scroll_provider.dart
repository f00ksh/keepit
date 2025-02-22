import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'drag_scroll_state.dart';

part 'drag_scroll_provider.g.dart';

@riverpod
class DragScroll extends _$DragScroll {
  @override
  DragScrollState build(ScrollController scrollController) {
    ref.onDispose(() {
      state.scrollTimer?.cancel();
    });
    return const DragScrollState();
  }

  void startDrag() {
    state = state.copyWith(isDragging: true);
  }

  void cancelScroll() {
    debugPrint('Cancelling scroll timer and resetting drag state');
    state.scrollTimer?.cancel();
    state = const DragScrollState();
  }

  void handleDragScroll(double dragPositionY, BuildContext context) {
    if (!state.isDragging) {
      startDrag();
    }

    state.scrollTimer?.cancel();
    final timer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _performScroll(dragPositionY, context),
    );
    state = state.copyWith(lastDragY: dragPositionY, scrollTimer: timer);
  }

  void _performScroll(double dragPositionY, BuildContext context) {
    if (!scrollController.hasClients || !state.isDragging) {
      cancelScroll();
      return;
    }

    const double edgeThreshold = 100.0;
    final double maxScroll = scrollController.position.maxScrollExtent;
    final double minScroll = scrollController.position.minScrollExtent;
    final double currentScroll = scrollController.offset;
    final double screenHeight = MediaQuery.of(context).size.height;

    bool nearTopEdge = dragPositionY < edgeThreshold;
    bool nearBottomEdge = dragPositionY > screenHeight - edgeThreshold;

    if (!nearTopEdge && !nearBottomEdge) {
      cancelScroll();
      return;
    }

    if (nearTopEdge && currentScroll > minScroll) {
      final double amount = (edgeThreshold - dragPositionY) * 0.5;
      final double newOffset =
          (currentScroll - amount).clamp(minScroll, maxScroll);
      scrollController.jumpTo(newOffset);
    } else if (nearBottomEdge && currentScroll < maxScroll) {
      final double amount =
          (dragPositionY - (screenHeight - edgeThreshold)) * 0.5;
      final double newOffset =
          (currentScroll + amount).clamp(minScroll, maxScroll);
      scrollController.jumpTo(newOffset);
    } else {
      cancelScroll();
    }
  }
}
