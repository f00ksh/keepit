import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/auth_provider.dart';

class AppSearchBar extends ConsumerWidget {
  final bool isSearchActive;
  final FocusNode? focusNode;

  const AppSearchBar({
    super.key,
    required this.isSearchActive,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).valueOrNull;
    final colorScheme = Theme.of(context).colorScheme;

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
              focusNode: focusNode,
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  focusNode?.unfocus();
                  Scaffold.of(context).openDrawer();
                },
              ),
              constraints: const BoxConstraints.tightFor(height: 47),
              hintText: 'Search notes...',
              elevation: const WidgetStatePropertyAll(3),
              shadowColor: const WidgetStatePropertyAll(Colors.transparent),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 9)),
              trailing: [
                InkWell(
                  onTap: () {
                    focusNode?.unfocus();
                    Navigator.of(context).pushNamed('/settings');
                  },
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: user?.photoUrl != null
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(user!.photoUrl!),
                            radius: 16,
                          )
                        : CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            radius: 16,
                            child: Text(
                              user?.name?.substring(0, 1).toUpperCase() ?? 'G',
                              style: TextStyle(
                                color: colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
