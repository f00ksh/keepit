import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/auth_provider.dart';

class AppSearchBar extends ConsumerWidget {
  const AppSearchBar({super.key});

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
            Hero(
              tag: 'search_bar',
              child: Material(
                elevation: 5,
                shadowColor: Colors.transparent,
                borderRadius: BorderRadius.circular(28),
                surfaceTintColor: colorScheme.surfaceTint,
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/search'),
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    height: 47,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    child: Row(
                      children: [
                        // Menu Icon
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                        ),

                        // Search Hint Text
                        Expanded(
                          child: Text(
                            'Search notes...',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),

                        // Profile Picture
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/settings');
                            },
                            customBorder: const CircleBorder(),
                            child: user?.photoUrl != null
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(user!.photoUrl!),
                                    radius: 16,
                                  )
                                : CircleAvatar(
                                    backgroundColor:
                                        colorScheme.tertiaryContainer,
                                    radius: 16,
                                    child: Text(
                                      user?.name
                                              ?.substring(0, 1)
                                              .toUpperCase() ??
                                          'G',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
