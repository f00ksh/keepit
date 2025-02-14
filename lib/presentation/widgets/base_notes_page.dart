import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/widgets/app_drawer.dart';
import 'package:keepit/presentation/widgets/navigation_drawer_destination_item.dart';
import 'package:keepit/presentation/widgets/search_bar.dart';

final scrollControllerProvider = Provider<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(() => controller.dispose());
  return controller;
});

class BaseNotesPage extends ConsumerStatefulWidget {
  final Widget content;
  final Widget? floatingActionButton;
  final bool showDrawer;
  final int currentIndex;
  final ValueChanged<int>? onDestinationSelected;
  final String title;

  const BaseNotesPage({
    super.key,
    required this.content,
    required this.title,
    this.floatingActionButton,
    this.showDrawer = true,
    this.currentIndex = 0,
    this.onDestinationSelected,
  });

  @override
  ConsumerState<BaseNotesPage> createState() => _BaseNotesPageState();
}

class _BaseNotesPageState extends ConsumerState<BaseNotesPage> {
  late bool showNavigationDrawer;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    showNavigationDrawer = MediaQuery.of(context).size.width >= 640;
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ref.watch(scrollControllerProvider);

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        drawer: !showNavigationDrawer && widget.showDrawer
            ? AppDrawer(
                currentIndex: widget.currentIndex,
                onDestinationSelected: widget.onDestinationSelected ?? (_) {},
              )
            : null,
        body: Row(
          children: [
            if (showNavigationDrawer && widget.showDrawer)
              NavigationRail(
                extended: MediaQuery.of(context).size.width >= 840,
                destinations: destinations
                    .map((d) => NavigationRailDestination(
                          icon: d.icon,
                          selectedIcon: d.selectedIcon,
                          label: Text(d.label),
                        ))
                    .toList(),
                selectedIndex: widget.currentIndex,
                onDestinationSelected: widget.onDestinationSelected ?? (_) {},
              ),
            Expanded(
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  AppSearchBar(
                    isSearchActive: false,
                    focusNode: _searchFocusNode,
                  ),
                  widget.content,
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
      ),
    );
  }
}
