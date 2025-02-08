import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/providers/search_provider.dart';

class AppSearchBar extends ConsumerWidget {
  final bool isSearchActive;
  const AppSearchBar({super.key, required this.isSearchActive});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      sliver: SliverAppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        floating: true,
        snap: true,
        expandedHeight: 57,
        automaticallyImplyLeading: false,
        flexibleSpace: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SearchBar(
              onChanged: (value) =>
                  ref.read(searchQueryProvider.notifier).update(value),

  leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
              // leading: IconButton(
              //   icon: const Icon(Icons.arrow_back),
              //   onPressed: () =>
              //       ref.read(searchActiveProvider.notifier).toggle(),
              // ),
              constraints: const BoxConstraints.tightFor(height: 47),
              hintText: 'Search notes...',
              elevation: const WidgetStatePropertyAll(3),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 9)),
              trailing: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () =>
                      ref.read(searchQueryProvider.notifier).update(''),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
