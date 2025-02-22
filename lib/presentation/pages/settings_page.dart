import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/theme/theme_provider.dart';
import 'package:keepit/data/providers/auth_provider.dart';
import 'package:keepit/presentation/providers/settings_provider.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/presentation/widgets/user_avatar.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final settingsAsync = ref.watch(settingsProvider);
    final themeMode = ref.watch(appThemeModeProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        surfaceTintColor: colorScheme.surface,
      ),
      body: settingsAsync.when(
        data: (settings) => ListView(
          children: [
            if (user != null) ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    UserAvatar(
                      photoUrl: user.photoUrl,
                      radius: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'User',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (user.email != null)
                            Text(
                              user.email!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],

            // Appearance Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Theme Mode',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode),
                          ),
                        ],
                        selected: {themeMode},
                        onSelectionChanged: (Set<ThemeMode> selection) {
                          ref
                              .read(appThemeModeProvider.notifier)
                              .setThemeMode(selection.first);
                        },
                        showSelectedIcon: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'View Type',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'grid',
                            icon: Icon(Icons.grid_view),
                          ),
                          ButtonSegment(
                            value: 'list',
                            icon: Icon(Icons.view_list),
                          ),
                        ],
                        selected: {settings.viewStyle},
                        onSelectionChanged: (Set<String> selection) {
                          ref
                              .read(settingsProvider.notifier)
                              .setViewStyle(selection.first);
                        },
                        showSelectedIcon: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sync Settings
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Sync',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.primary,
                    ),
              ),
            ),
            Material(
              color: colorScheme.surface,
              surfaceTintColor: colorScheme.surfaceTint,
              elevation: 0,
              child: SwitchListTile.adaptive(
                value: settings.syncEnabled,
                onChanged: (_) =>
                    ref.read(settingsProvider.notifier).toggleSync(),
                title: const Text('Sync Notes'),
                subtitle: Text(settings.syncEnabled
                    ? 'Notes will sync when online'
                    : 'Working in offline mode'),
                secondary: Icon(
                  Icons.sync,
                  color: colorScheme.primary,
                ),
              ),
            ),

            if (user != null) ...[
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton.tonal(
                  onPressed: () => _showSignOutDialog(context, ref),
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading settings: $error',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ),
    );
  }

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut ?? false) {
      await ref.read(authProvider.notifier).signOut();
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }
}
