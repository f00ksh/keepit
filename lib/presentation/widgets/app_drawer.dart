import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/providers/auth_provider.dart';
import 'package:keepit/presentation/widgets/navigation_drawer_destination_item.dart';
import 'package:keepit/presentation/widgets/loading_overlay.dart';
import 'package:keepit/core/utils/error_handler.dart';

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
                ? _buildUserHeader(context, user.email)
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

  Widget _buildUserHeader(BuildContext context, String email) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 24,
          child: Icon(Icons.person),
        ),
        const SizedBox(height: 8),
        Text(
          email,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
