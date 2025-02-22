import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/widgets/app_drawer.dart';
import 'package:keepit/presentation/widgets/search_bar.dart';

class BaseNotesPage extends ConsumerStatefulWidget {
  final Widget content;
  final Widget? floatingActionButton;
  final bool showDrawer;
  final int currentIndex;
  final ValueChanged<int>? onDestinationSelected;
  final String title;
  final bool showSearch; // New parameter

  const BaseNotesPage({
    super.key,
    required this.content,
    required this.title,
    this.floatingActionButton,
    this.showDrawer = true,
    this.currentIndex = 0,
    this.onDestinationSelected,
    this.showSearch = true, // Make search bar optional
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
    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        drawer: !showNavigationDrawer && widget.showDrawer
            ? AppDrawer(
                currentIndex: widget.currentIndex,
                onDestinationSelected: widget.onDestinationSelected ?? (_) {},
              )
            : null,
        body: CustomScrollView(
          slivers: [
            if (widget.showSearch) // Conditionally show search bar
              AppSearchBar(
                isSearchActive: false,
                focusNode: _searchFocusNode,
              ),
            widget.content,
          ],
        ),
        floatingActionButton: widget.floatingActionButton,
      ),
    );
  }
}
