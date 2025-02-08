import 'package:flutter/material.dart';

/// A widget that displays an empty state message within a SliverFillRemaining.
class SliverEmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isSearchActive;
  final String? searchQuery;

  const SliverEmptyState({
    super.key,
    this.message = 'No notes',
    this.icon = Icons.note_outlined,
    this.isSearchActive = false,
    this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              isSearchActive && searchQuery != null
                  ? 'No results for "$searchQuery"'
                  : message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
