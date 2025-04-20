import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/core/theme/theme_provider.dart';
import 'package:keepit/data/providers/auth_provider.dart';
import 'package:keepit/data/providers/settings_provider.dart';
import 'package:keepit/core/routes/app_router.dart';
import 'package:keepit/presentation/widgets/user_avatar.dart';
import 'package:keepit/core/theme/app_theme.dart';
import 'package:keepit/domain/models/settings.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;
    final settings = ref.watch(settingsProvider);
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
      body: ListView(
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
                            .read(settingsProvider.notifier)
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

                // Dynamic colors toggle
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Use dynamic colors'),
                  subtitle: const Text('Match colors to your device theme'),
                  value: settings.useDynamicColors,
                  onChanged: (bool value) {
                    ref.read(settingsProvider.notifier).updateSetting(
                          useDynamicColors: value,
                        );
                  },
                ),

                // Accent color picker (only shown when dynamic colors are off)
                if (!settings.useDynamicColors)
                  ListTile(
                    title: const Text('Accent color'),
                    subtitle: Text(
                      AppTheme.colorNames[settings.accentColorIndex],
                    ),
                    trailing: Container(
                      width: MediaQuery.of(context).size.width * 0.08,
                      height: MediaQuery.of(context).size.width * 0.08,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColors[settings.accentColorIndex],
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.outline,
                          width: 1.5,
                        ),
                      ),
                    ),
                    onTap: () => _showColorPicker(context, ref, settings),
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
                  ref.read(settingsProvider.notifier).updateSetting(
                        syncEnabled: !settings.syncEnabled,
                      ),
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

  void _showColorPicker(BuildContext context, WidgetRef ref, Setting settings) {
    // Calculate a size that works well for color grid items
    final gridItemSize = MediaQuery.of(context).size.width * 0.12;

    showDialog(
      context: context,
      builder: (context) {
        return Consumer(builder: (context, ref, _) {
          final currentSettings = ref.watch(settingsProvider);

          return AlertDialog(
            title: const Text('Choose accent color'),
            contentPadding: const EdgeInsets.all(16.0),
            content: SizedBox(
              width: double.maxFinite,
              child: GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12, // Increased spacing
                  crossAxisSpacing: 12, // Increased spacing
                  childAspectRatio: 1,
                ),
                itemCount: AppTheme.accentColors.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      ref.read(settingsProvider.notifier).updateSetting(
                            accentColorIndex: index,
                          );
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.accentColors[index],
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: currentSettings.accentColorIndex == index
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: gridItemSize * 0.5, // Dynamic icon size
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CANCEL'),
              ),
            ],
          );
        });
      },
    );
  }
}
