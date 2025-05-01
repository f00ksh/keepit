import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/core/services/navigation_service.dart';
import 'package:keepit/data/providers/auth_provider.dart';
import 'package:keepit/core/utils/error_handler.dart';
import 'package:keepit/data/providers/labels_provider.dart';
import 'package:keepit/domain/models/user.dart';
import 'package:keepit/presentation/providers/selected_label_provider.dart';
import 'package:keepit/presentation/widgets/user_avatar.dart';
import 'package:collection/collection.dart';

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
    final labels = ref.watch(labelsProvider);
    final selectedLabel = ref.watch(selectedLabelProvider);

    // Calculate selected index
    int selectedIndex = currentIndex;
    if (selectedLabel != null) {
      // Find the label index and add offset for base items
      final labelIndex = labels.indexWhere((l) => l.id == selectedLabel);
      if (labelIndex != -1) {
        selectedIndex = labelIndex + 2; // +2 for Notes and Favorites
      }
    } else if (currentIndex >= 2) {
      // Adjust index for Archive, Trash, Settings
      selectedIndex =
          currentIndex + labels.length + 1; // +1 for "Create new label"
    }

    debugPrint(
        'AppDrawer selectedIndex: $selectedIndex, currentIndex: $currentIndex, selectedLabel: $selectedLabel');

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        debugPrint('AppDrawer: Destination selected: $index');
        final totalBaseItems = 2; // Notes and Favorites
        final labelsCount = labels.length;

        if (index < totalBaseItems) {
          // Notes and Favorites
          debugPrint('AppDrawer: Selecting base item: $index');
          NavigationService.handleDestinationChange(
            context,
            ref,
            index,
            onIndexChanged: onDestinationSelected,
          );
        } else if (index < totalBaseItems + labelsCount) {
          // Labels
          final labelIndex = index - totalBaseItems;
          debugPrint('AppDrawer: Selecting label at index: $labelIndex');
          NavigationService.handleDestinationChange(
            context,
            ref,
            index,
            onIndexChanged: onDestinationSelected,
            labelData: {'labelId': labels[labelIndex].id},
          );
        } else if (index == totalBaseItems + labelsCount) {
          // Create new label
          debugPrint('AppDrawer: Creating new label');
          NavigationService.handleDestinationChange(
            context,
            ref,
            index,
            onIndexChanged: onDestinationSelected,
            labelData: {'isCreateNew': true},
          );
        } else {
          // Archive, Trash, Settings
          final remainingIndex = index - (totalBaseItems + labelsCount + 1);
          final finalIndex = remainingIndex + totalBaseItems;
          debugPrint('AppDrawer: Selecting remaining item: $finalIndex');
          NavigationService.handleDestinationChange(
            context,
            ref,
            finalIndex,
            onIndexChanged: onDestinationSelected,
          );
        }
      },
      children: [
        // User header
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

        // Notes and Favorites
        ...destinations
            .take(2)
            .map((destination) => NavigationDrawerDestination(
                  icon: destination.icon,
                  label: Text(destination.label),
                )),

        const Padding(
          padding: EdgeInsets.fromLTRB(28, 8, 28, 8),
          child: Divider(),
        ),

        // Labels header
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Labels'),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.labels);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(48, 24),
                ),
                child: const Text('Edit'),
              ),
            ],
          ),
        ),

        // Labels list
        ...labels.mapIndexed((index, label) => NavigationDrawerDestination(
              icon: const Icon(Icons.label_outline),
              selectedIcon: const Icon(Icons.label),
              label: Text(label.name),
            )),

        // Create new label button
        NavigationDrawerDestination(
          icon: const Icon(Icons.add),
          selectedIcon: const Icon(Icons.add),
          label: const Text('Create new label'),
        ),

        const Padding(
          padding: EdgeInsets.fromLTRB(28, 8, 28, 8),
          child: Divider(),
        ),

        // Archive, Trash, Settings
        ...destinations
            .skip(2)
            .map((destination) => NavigationDrawerDestination(
                  icon: destination.icon,
                  label: Text(destination.label),
                )),
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
  const DrawerDestination(
    this.label,
    this.icon,
  );

  final String label;
  final Widget icon;
}

const List<DrawerDestination> destinations = <DrawerDestination>[
  DrawerDestination(
    'Notes',
    Icon(Icons.lightbulb_outline),
  ),
  DrawerDestination(
    'Favorites',
    Icon(Icons.favorite_outline_outlined),
  ),
  DrawerDestination(
    'Archive',
    Icon(Icons.archive_outlined),
  ),
  DrawerDestination(
    'Trash',
    Icon(Icons.delete_outline),
  ),
  DrawerDestination(
    'Settings',
    Icon(Icons.settings_outlined),
  ),
];
