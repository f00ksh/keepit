import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/providers/auth_provider.dart';
import 'package:keepit/core/routes/app_router.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: FloatingActionButton.small(
          heroTag: 'settings_back_button',
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back),
        ),
      ),
      body: ListView(
        children: [
          // Profile Section
          Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundImage: user?.photoUrl != null
                        ? NetworkImage(user!.photoUrl!)
                        : null,
                    child: user?.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(user?.name ?? 'User'),
                  subtitle: Text(user?.email ?? ''),
                ),
              ],
            ),
          ),

          // Settings Section
          const Card(
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.color_lens_outlined),
                  title: Text('Theme'),
                  // Add theme switcher here
                ),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text('Language'),
                  // Add language switcher here
                ),
              ],
            ),
          ),

          // Account Section
          Card(
            margin: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Sign Out'),
                  onTap: () async {
                    final shouldSignOut = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out'),
                        content:
                            const Text('Are you sure you want to sign out?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );

                    if (shouldSignOut ?? false) {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        Navigator.pushReplacementNamed(
                            context, AppRoutes.login);
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
