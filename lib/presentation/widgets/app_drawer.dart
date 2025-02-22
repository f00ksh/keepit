import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/data/providers/auth_provider.dart';
import 'package:keepit/core/utils/error_handler.dart';
import 'package:keepit/domain/models/user.dart';
import 'package:keepit/presentation/widgets/user_avatar.dart';

class AppDrawer extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const AppDrawer({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authProvider);

    return NavigationDrawer(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
          child: userState.when(
            data: (user) => user != null
                ? _buildUserHeader(context, user)
                : const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Text(ErrorHandler.getErrorMessage(error)),
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 0, 28, 8),
          child: Divider(),
        ),
        ...destinations.map((destination) => NavigationDrawerDestination(
              icon: destination.icon,
              selectedIcon: destination.selectedIcon,
              label: Text(destination.label),
            )),
        const Padding(
          padding: EdgeInsets.fromLTRB(28, 8, 28, 8),
          child: Divider(),
        ),
      ],
    );
  }

  Widget _buildUserHeader(BuildContext context, AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UserAvatar(
          photoUrl: user.photoUrl,
          radius: 24,
        ),
        const SizedBox(height: 8),
        Text(
          user.name ?? 'User',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        if (user.email != null)
          Text(
            user.email!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
      ],
    );
  }
}

class DrawerDestination {
  const DrawerDestination(this.label, this.icon, this.selectedIcon);

  final String label;
  final Widget icon;
  final Widget selectedIcon;
}

const List<DrawerDestination> destinations = <DrawerDestination>[
  DrawerDestination(
    'Notes',
    Icon(Icons.note_outlined),
    Icon(Icons.note),
  ),
  DrawerDestination(
    'Favorites',
    Icon(Icons.favorite_outline),
    Icon(Icons.favorite),
  ),
  DrawerDestination(
      'Archive', Icon(Icons.archive_outlined), Icon(Icons.archive)),
  DrawerDestination(
    'Trash',
    Icon(Icons.delete_outline),
    Icon(Icons.delete),
  ),
  DrawerDestination(
    'Settings',
    Icon(Icons.settings_outlined),
    Icon(Icons.settings),
  ),
];
