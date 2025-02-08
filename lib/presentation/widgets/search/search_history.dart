import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/providers/search_provider.dart';

class SearchHistory extends ConsumerWidget {
  final Function(String) onQuerySelected;

  const SearchHistory({
    super.key,
    required this.onQuerySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(searchHistoryProvider);

    if (history.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Text('No recent searches'),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final query = history[index];
          return ListTile(
            leading: const Icon(Icons.history),
            title: Text(query),
            trailing: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(searchHistoryProvider.notifier).removeQuery(query);
              },
            ),
            onTap: () => onQuerySelected(query),
          );
        },
        childCount: history.length,
      ),
    );
  }
}
