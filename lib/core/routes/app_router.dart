import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/pages/archive_page.dart';
import 'package:keepit/presentation/pages/favorites_page.dart';
import 'package:keepit/presentation/pages/home_page.dart';
import 'package:keepit/presentation/pages/login_page.dart';
import 'package:keepit/presentation/pages/note_view_page.dart';
import 'package:keepit/presentation/pages/settings_page.dart';
import 'package:keepit/presentation/pages/trash_page.dart';
import 'package:keepit/presentation/pages/add_note_page.dart';
import 'package:keepit/data/providers/auth_provider.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String archive = '/archive';
  static const String favorites = '/favorites';
  static const String trash = '/trash';
  static const String settings = '/settings';
  static const String addNote = '/add-note';
  static const String note = '/note';
}

class AppRouter {
  static Widget initialRoute(BuildContext context, WidgetRef ref) {
    return ref.watch(authProvider).when(
      data: (user) {
        if (user != null) {
          return const HomePage();
        }
        return const LoginPage();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const LoginPage(),
    );
  }

  /// Do not include the home route ("/") in the routes table
  static Map<String, Widget Function(BuildContext)> routes = {
    AppRoutes.home: (context) => Consumer(
          builder: (context, ref, _) {
            return ref.watch(authProvider).when(
                  data: (user) =>
                      user != null ? const HomePage() : const LoginPage(),
                  loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Scaffold(
                    body: Center(child: Text('Error: $error')),
                  ),
                );
          },
        ),
    AppRoutes.login: (context) => const LoginPage(),
    AppRoutes.archive: (context) => const ArchivePage(),
    AppRoutes.favorites: (context) => const FavoritesPage(),
    AppRoutes.trash: (context) => const TrashPage(),
    AppRoutes.settings: (context) => const SettingsPage(),
    AppRoutes.addNote: (context) => const AddNotePage(),
    AppRoutes.note: (context) {
      final noteId = ModalRoute.of(context)?.settings.arguments as String?;
      if (noteId == null) return const HomePage();
      return NotePage(noteId: noteId);
    },
  };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeBuilder = routes[settings.name];
    if (routeBuilder != null) {
      return MaterialPageRoute(
        builder: routeBuilder,
        settings: settings,
      );
    }
    return onUnknownRoute(settings);
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text('No route defined for ${settings.name}'),
        ),
      ),
    );
  }
}
