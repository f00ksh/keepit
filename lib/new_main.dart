import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/src/drag_masonryview.dart';
import 'package:keepit/src/models.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drag Grid Scroll Test',
      home: Scaffold(
        appBar: AppBar(title: const Text('Drag Grid Scroll Test')),
        body: const DragGridScrollTestPage(),
      ),
    );
  }
}

class DragGridScrollTestPage extends StatefulWidget {
  const DragGridScrollTestPage({super.key});

  @override
  DragGridScrollTestPageState createState() => DragGridScrollTestPageState();
}

class DragGridScrollTestPageState extends State<DragGridScrollTestPage> {
  List<int> items = List.generate(50, (index) => index);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Drag to Scroll'),
          pinned: true,
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 600, // Make sure there's enough content to scroll
            child: ReorderableGrid(),
          ),
        ),
      ],
    );
  }

  Widget ReorderableGrid() {
    return DragMasonryGrid(
      isDragNotification: true,
      isLongPressDraggable: true,
      draggingWidgetOpacity: 0.3,
      enableReordering: true,
      crossAxisCount: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      edgeScroll: 0.1,
      edgeScrollSpeedMilliseconds: 150,
      children: items.map((index) {
        return DragGridExtentItem(
          key: ValueKey(index),
          widget: Container(
            height: 150,
            color: Colors
                .blue[100 + index * 5 % 8 * 100], // Simple color variation
            alignment: Alignment.center,
            child: Text('Item $index'),
          ),
          mainAxisExtent: 150,
          crossAxisCellCount: 1,
        );
      }).toList(),
    );
  }
}
