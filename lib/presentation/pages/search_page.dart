import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/data/providers/labels_provider.dart';
import 'package:keepit/presentation/providers/search_provider.dart';

import 'package:keepit/presentation/widgets/note_grid.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  double get _screenWidth => MediaQuery.of(context).size.width;
  double get _screenHeight => MediaQuery.of(context).size.height;

  // Adaptive sizes
  double get _normalSize => _screenWidth * 0.20; // 22% of screen width
  double get _colorSize => _screenWidth * 0.12; // 14% of screen width
  double get _iconScale => 0.4;

  // Adaptive paddings
  EdgeInsets get _sectionPadding => EdgeInsets.all(_screenWidth * 0.04);
  double get _spacing => _screenWidth * 0.04;

  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;

  // Add this variable to track search mode
  bool get isSearchMode =>
      _searchController.text.isNotEmpty ||
      ref.watch(selectedSearchLabelsProvider).isNotEmpty ||
      ref.watch(selectedSearchColorProvider) != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Widget _buildFilterSection(String title, List<Widget> children) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: _sectionPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: _screenHeight * 0.02),
            Wrap(
              alignment: WrapAlignment.start,
              spacing: _spacing,
              runSpacing: _spacing,
              children: children,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleItem({
    IconData? icon,
    required String label,
    bool isSelected = false,
    Color? backgroundColor,
    VoidCallback? onTap,
    bool isColorItem = false,
    int? colorIndex, // Add colorIndex parameter
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final itemSize = isColorItem ? _colorSize : _normalSize;

    final circleButton = Material(
      shape: CircleBorder(
        side: isColorItem
            ? BorderSide(
                color: colorScheme.outline.withOpacity(0.7),
                width: _screenWidth * 0.002,
              )
            : BorderSide.none,
      ),
      color: backgroundColor ?? colorScheme.surfaceContainerHighest,
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: itemSize,
          height: itemSize,
          child: icon != null
              ? Icon(
                  icon,
                  size: itemSize * _iconScale,
                  color: colorScheme.onSurfaceVariant,
                )
              : isColorItem &&
                      colorIndex == AppTheme.noColorIndex // Check noColorIndex
                  ? Icon(
                      Icons.format_color_reset,
                      size: itemSize * _iconScale,
                      color: colorScheme.onSurfaceVariant,
                    )
                  : null,
        ),
      ),
    );

    if (isColorItem) return circleButton;

    return Column(
      children: [
        circleButton,
        if (label.isNotEmpty) ...[
          SizedBox(height: itemSize * 0.1),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  void _onSearchQueryChanged(String query) {
    setState(() {
      ref.read(searchQueryProvider.notifier).setQuery(query);
      ref.read(showSearchResultsProvider.notifier).setShow(query.isNotEmpty);
    });
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      ref.read(searchQueryProvider.notifier).setQuery('');
      ref.read(showSearchResultsProvider.notifier).setShow(false);
      ref.read(selectedSearchLabelsProvider.notifier).clear();
      ref.read(selectedSearchColorProvider.notifier).setColor(null);
    });
  }

  void _handleBackPress() {
    if (isSearchMode) {
      _clearSearch();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = ref.watch(labelsProvider);
    final selectedLabels = ref.watch(selectedSearchLabelsProvider);
    final selectedColor = ref.watch(selectedSearchColorProvider);
    final filteredNotes = ref.watch(searchFilteredNotesProvider);
    final showResults = ref.watch(showSearchResultsProvider);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + _screenHeight * 0.015),
        child: Hero(
          tag: 'search_bar',
          child: Material(
            elevation: 0,
            child: AppBar(
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHigh,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _handleBackPress,
              ),
              title: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: isSearchMode
                      ? 'Search in filtered notes'
                      : 'Search notes',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
                onChanged: _onSearchQueryChanged,
              ),
              actions: [
                if (isSearchMode)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: _clearSearch,
                  ),
              ],
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          if (!isSearchMode) ...[
            // Show filters only when not in search mode
            _buildFilterSection(
              'TYPE',
              [
                _buildCircleItem(
                  icon: Icons.list_alt_outlined,
                  label: 'Lists',
                  onTap: () {/* TODO: Implement type filtering */},
                ),
                _buildCircleItem(
                  icon: Icons.alarm_outlined,
                  label: 'Reminders',
                  onTap: () {/* TODO: Implement type filtering */},
                ),
                _buildCircleItem(
                  icon: Icons.draw_outlined,
                  label: 'Drawings',
                  onTap: () {/* TODO: Implement type filtering */},
                ),
                _buildCircleItem(
                  icon: Icons.link_outlined,
                  label: 'URLs',
                  onTap: () {/* TODO: Implement type filtering */},
                ),
              ],
            ),
            _buildFilterSection(
              'LABELS',
              labels.map((label) {
                final isSelected = selectedLabels.contains(label.id);
                return _buildCircleItem(
                  icon: Icons.label_outline,
                  label: label.name,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() {
                      ref
                          .read(selectedSearchLabelsProvider.notifier)
                          .toggleLabel(label.id);
                      ref
                          .read(showSearchResultsProvider.notifier)
                          .setShow(true);
                      _searchFocusNode.requestFocus();
                    });
                  },
                );
              }).toList(),
            ),
            _buildFilterSection(
              'COLORS',
              List.generate(
                AppTheme.lightColors.length,
                (index) => _buildCircleItem(
                  label: '',
                  isSelected: selectedColor == index,
                  backgroundColor: getNoteColor(context, index),
                  isColorItem: true,
                  colorIndex: index == 0
                      ? AppTheme.noColorIndex
                      : index, // Set proper index
                  onTap: () {
                    setState(() {
                      ref
                          .read(selectedSearchColorProvider.notifier)
                          .setColor(selectedColor == index ? null : index);
                      ref
                          .read(showSearchResultsProvider.notifier)
                          .setShow(true);
                      _searchFocusNode.requestFocus();
                    });
                  },
                ),
              ),
            ),
          ],

          // Show results
          if (showResults)
            filteredNotes.isEmpty
                ? const SliverFillRemaining(
                    child: Center(child: Text('No notes found')),
                  )
                : NoteGrid(notes: filteredNotes)
        ],
      ),
    );
  }
}
