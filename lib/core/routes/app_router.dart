import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keepit/presentation/pages/home_page.dart';
import 'package:keepit/presentation/pages/login_page.dart';
import 'package:keepit/presentation/pages/note_page.dart';
import 'package:keepit/presentation/pages/settings_page.dart';
import 'package:keepit/data/providers/auth_provider.dart';

class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
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
      loading: () {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, stack) {
        return const LoginPage();
      },
    );
  }

  // Create a provider to handle route guards
  static final routeGuardProvider =
      Provider<Widget Function(BuildContext, Widget)>(
    (ref) => (context, child) {
      return ref.watch(authProvider).when(
            data: (user) {
              if (user == null &&
                  ModalRoute.of(context)?.settings.name != AppRoutes.login) {
                debugPrint(
                    'RouteGuard: Unauthorized access - redirecting to login');
                return const LoginPage();
              }
              return child;
            },
            loading: () => const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
            error: (_, __) => const LoginPage(),
          );
    },
  );

  /// Updated routes map with route guard
  static Map<String, Widget Function(BuildContext)> routes = {
    AppRoutes.login: (context) => const LoginPage(),
    AppRoutes.home: (context) => Consumer(
          builder: (context, ref, child) {
            final guard = ref.watch(routeGuardProvider);
            return guard(context, const HomePage());
          },
        ),
    AppRoutes.settings: (context) => const SettingsPage(),
    AppRoutes.addNote: (context) => const NotePage(
          heroTag: 'add_note_fab',
        ),
    AppRoutes.note: (context) {
      final noteId = ModalRoute.of(context)?.settings.arguments as String?;
      if (noteId == null) return const HomePage();

      return Consumer(
        builder: (context, ref, child) {
          final guard = ref.watch(routeGuardProvider);
          return guard(
            context,
            NotePage(
              noteId: noteId,
              heroTag: 'note_$noteId',
            ),
          );
        },
      );
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
